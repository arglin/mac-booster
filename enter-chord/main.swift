import ApplicationServices
import CoreGraphics
import Foundation

/// Replacement keys are posted into the HID system, the same layer Carbon hotkeys
/// read. The event tap still catches the physical key.
///
/// Return and keypad Enter follow the Karabiner rule. A release within 200ms,
/// with no other key, sends Return. Holding it and pressing another key sends
/// that key with Control+Option+Command. A hold longer than 200ms with no other
/// key sends nothing. Other modifiers do not block the rule.
///
/// A finger resting in the top-left quarter of the built-in trackpad (a contact,
/// not a click) turns H J K L into Left, Down, Up, and Right. The quarter is the
/// left half and the upper half, nearest the keyboard. Shift may be held.
/// Command, Option, Control, and Fn leave the letters alone.
///
/// Left Command: a tap sends Left Shift+Control+Option+Right Arrow. Holding it,
/// or pressing another key while it is down, is Left Command. If another
/// modifier is already down, Left Command is left unchanged.
///
/// Right Command: a tap sends Right Shift+Control+Option+Left Arrow. Holding it,
/// or pressing another key while it is down, is Right Command. If another
/// modifier is already down, Right Command is left unchanged.
///
/// Right Shift: a tap sends Right Command+Right Option+Right Shift+N. Holding it,
/// or pressing another key while it is down, is Left Control+Left Shift+Left Command.
///
/// Tab: with no counted finger, a tap is Tab. With one counted finger, a tap is
/// Right Shift+Tab. Holding it, or pressing another key while it is down, is
/// Right Option+Right Command+Right Shift. Two or more counted fingers leave Tab alone.
///
/// One counted finger also turns the text-edit letters into their editing sequences.
/// Left Shift changes Q, Y, and O. A, I, T, B, E, and G allow Left Shift. Any other
/// modifier leaves the letter alone.
///
/// Caps Lock: no counted finger, hold is Control+Option+Command and a tap is
/// Escape. One counted finger, hold is Control+Option+Shift and a tap sends
/// nothing.

private let returnKey: Int64 = 36
private let keypadEnter: Int64 = 76
private let postedByUs: Int64 = 0x454E5401
private let chord: CGEventFlags = [.maskControl, .maskAlternate, .maskCommand]

private enum Phase {
    case idle
    case pending
    case held
    case chord
}

private final class Gate {
    var phase = Phase.idle
    var generation = 0
}

private let gate = Gate()
private var tapPort: CFMachPort?
private let arrowByKey: [Int64: Int64] = [
    4: 123, // h -> left
    37: 124, // l -> right
    38: 125, // j -> down
    40: 126, // k -> up
]
private var heldArrow: [Int64: Int64] = [:]
private let capsKeys: Set<Int64> = [57, 79] // Caps Lock, and F18 when hidutil maps Caps Lock there
private let escapeKey: Int64 = 53
private let hyperFlags: CGEventFlags = [.maskControl, .maskAlternate, .maskCommand]
private let shiftedFlags: CGEventFlags = [.maskControl, .maskAlternate, .maskShift]

private enum CapsMode {
    case none
    case hyper
    case shifted
}

private var capsMode = CapsMode.none
private var capsUsed = false
private var capsFlagsPosted = false

private func capsModifierFlags() -> CGEventFlags {
    switch capsMode {
    case .none:
        return []
    case .hyper:
        return hyperFlags
    case .shifted:
        return shiftedFlags
    }
}

private func postExtraFlags(_ extra: CGEventFlags, enabled: Bool) {
    var flags = CGEventSource.flagsState(.hidSystemState)
    if enabled {
        flags.formUnion(extra)
    } else {
        flags.subtract(extra)
    }
    postHID(type: hidFlagsChanged, key: UInt16(leftControlKey), flags: hidFlags(from: flags))
}

private func postTap(_ key: Int64, flags: CGEventFlags = []) {
    let posted = hidFlags(from: flags)
    let restore = hidFlags(from: CGEventSource.flagsState(.hidSystemState))
    let code = UInt16(key)
    postHID(type: hidFlagsChanged, key: code, flags: posted)
    postHID(type: hidKeyDown, key: code, flags: posted)
    postHID(type: hidKeyUp, key: code, flags: posted)
    if restore != posted {
        postHID(type: hidFlagsChanged, key: code, flags: restore)
    }
}

private func releaseCapsLockIfOn() {
    DispatchQueue.main.async {
        guard CGEventSource.flagsState(.hidSystemState).contains(.maskAlphaShift) else { return }
        postTap(57)
    }
}

private let leftCommandKey: Int64 = 55
private let rightCommandKey: Int64 = 54
private let rightArrowKey: Int64 = 124
private let leftArrowKey: Int64 = 123
private let leftShiftKey: Int64 = 56
private let rightShiftKey: Int64 = 60
private let leftOptionKey: Int64 = 58
private let leftControlKey: Int64 = 59
private let leftShiftFlag = CGEventFlags(rawValue: CGEventFlags.maskShift.rawValue | 0x00000002)
private let leftControlFlag = CGEventFlags(rawValue: CGEventFlags.maskControl.rawValue | 0x00000001)
private let leftOptionFlag = CGEventFlags(rawValue: CGEventFlags.maskAlternate.rawValue | 0x00000020)

private var leftCommandTracking = false
private var leftCommandUsed = false
private var leftCommandPosted = false
private var leftCommandGeneration = 0
private var leftCommandLatch = false
private var rightCommandTracking = false
private var rightCommandUsed = false
private var rightCommandPosted = false
private var rightCommandGeneration = 0
private var rightCommandLatch = false
private var postingScrollChord = false
private var rightShiftTracking = false
private var rightShiftUsed = false
private var rightShiftPosted = false
private var rightShiftGeneration = 0
private var rightShiftLatch = false
private let nKey: Int64 = 45
private let numLineFlags = CGEventFlags(rawValue:
    CGEventFlags.maskControl.rawValue | 0x00000001 |
    CGEventFlags.maskShift.rawValue | 0x00000002 |
    CGEventFlags.maskCommand.rawValue | 0x00000008
)
private let previousWindowFlags = CGEventFlags(rawValue:
    CGEventFlags.maskCommand.rawValue | 0x00000010 |
    CGEventFlags.maskAlternate.rawValue | 0x00000040 |
    CGEventFlags.maskShift.rawValue | 0x00000004
)
private let tabKey: Int64 = 48
private var tabTracking = false
private var tabUsed = false
private var tabPosted = false
private var tabGeneration = 0
private var tabFingers = 0
private let tabHoldFlags = CGEventFlags(rawValue:
    CGEventFlags.maskCommand.rawValue | 0x00000010 |
    CGEventFlags.maskAlternate.rawValue | 0x00000040 |
    CGEventFlags.maskShift.rawValue | 0x00000004
)
private var emittingSynthetic = false

private func beginLeftCommand() {
    guard !leftCommandTracking else { return }
    leftCommandTracking = true
    leftCommandUsed = false
    leftCommandPosted = false
    leftCommandGeneration += 1
    let generation = leftCommandGeneration
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        guard generation == leftCommandGeneration, leftCommandTracking, !leftCommandUsed else { return }
        holdLeftCommand(on: nil)
    }
}

private func holdLeftCommand(on event: CGEvent?) {
    guard leftCommandTracking else { return }
    leftCommandUsed = true
    if !leftCommandPosted {
        leftCommandPosted = true
        DispatchQueue.main.async { postExtraFlags(.maskCommand, enabled: true) }
    }
    event?.flags.formUnion(.maskCommand)
}

private func endLeftCommand() {
    guard leftCommandTracking else { return }
    let posted = leftCommandPosted
    let used = leftCommandUsed
    leftCommandTracking = false
    leftCommandUsed = false
    leftCommandPosted = false
    leftCommandGeneration += 1
    if posted {
        DispatchQueue.main.async {
            if !rightCommandPosted {
                postExtraFlags(.maskCommand, enabled: false)
            }
        }
    } else if !used {
        leftCommandLatch = true
        postClickChord()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            leftCommandLatch = false
        }
    }
}

@_silgen_name("bulkey_hid_post")
private func enterChordHIDPost(_ type: UInt32, _ key: UInt16, _ flags: UInt32) -> Int32

private var hidInjecting = 0
private var hidEchoKeys: [Int64] = []
private var hidReposted: Set<Int64> = []

private func hidFlags(from flags: CGEventFlags) -> UInt32 {
    UInt32(truncatingIfNeeded: flags.rawValue)
}

private func postHID(type: UInt32, key: UInt16, flags: UInt32) {
    hidInjecting += 1
    hidEchoKeys.append(Int64(key))
    DispatchQueue.main.async {
        hidInjecting = max(0, hidInjecting - 1)
    }
    let echoed = Int64(key)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        if let index = hidEchoKeys.firstIndex(of: echoed) {
            hidEchoKeys.remove(at: index)
        }
    }
    let result = enterChordHIDPost(type, key, flags)
    if result != 0 {
        fputs("bulkey: HID post failed \(result)\n", stderr)
    }
}

private let hidKeyDown: UInt32 = 10
private let hidKeyUp: UInt32 = 11
private let hidFlagsChanged: UInt32 = 12
private let hidControl: UInt32 = 0x00040000 | 0x00000001
private let hidOption: UInt32 = 0x00040000 | 0x00000001 | 0x00080000 | 0x00000020
private let hidHeld: UInt32 = 0x00040000 | 0x00000001 | 0x00080000 | 0x00000020 | 0x00020000 | 0x00000002

private func postClickChord() {
    // Homerow's click shortcut is a system hotkey. Ordinary posted key events
    // never reach it. These go through the HID system, after Command is up.
    postHID(type: hidFlagsChanged, key: UInt16(leftCommandKey), flags: 0)
    postHID(type: hidFlagsChanged, key: UInt16(leftControlKey), flags: hidControl)
    postHID(type: hidKeyDown, key: UInt16(leftControlKey), flags: hidControl)
    postHID(type: hidFlagsChanged, key: UInt16(leftOptionKey), flags: hidOption)
    postHID(type: hidKeyDown, key: UInt16(leftOptionKey), flags: hidOption)
    postHID(type: hidFlagsChanged, key: UInt16(leftShiftKey), flags: hidHeld)
    postHID(type: hidKeyDown, key: UInt16(leftShiftKey), flags: hidHeld)
    postHID(type: hidKeyDown, key: UInt16(rightArrowKey), flags: hidHeld)
    postHID(type: hidKeyUp, key: UInt16(rightArrowKey), flags: hidHeld)
    postHID(type: hidKeyUp, key: UInt16(leftShiftKey), flags: hidOption)
    postHID(type: hidFlagsChanged, key: UInt16(leftShiftKey), flags: hidOption)
    postHID(type: hidKeyUp, key: UInt16(leftOptionKey), flags: hidControl)
    postHID(type: hidFlagsChanged, key: UInt16(leftOptionKey), flags: hidControl)
    postHID(type: hidKeyUp, key: UInt16(leftControlKey), flags: 0)
    postHID(type: hidFlagsChanged, key: UInt16(leftControlKey), flags: 0)
    fputs("bulkey: left command tap\n", stderr)
}

private func beginRightCommand() {
    guard !rightCommandTracking else { return }
    rightCommandTracking = true
    rightCommandUsed = false
    rightCommandPosted = false
    rightCommandGeneration += 1
    let generation = rightCommandGeneration
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        guard generation == rightCommandGeneration, rightCommandTracking, !rightCommandUsed else { return }
        holdRightCommand(on: nil)
    }
}

private func holdRightCommand(on event: CGEvent?) {
    guard rightCommandTracking else { return }
    rightCommandUsed = true
    if !rightCommandPosted {
        rightCommandPosted = true
        DispatchQueue.main.async { postExtraFlags(.maskCommand, enabled: true) }
    }
    event?.flags.formUnion(.maskCommand)
}

private func endRightCommand() {
    guard rightCommandTracking else { return }
    let posted = rightCommandPosted
    let used = rightCommandUsed
    rightCommandTracking = false
    rightCommandUsed = false
    rightCommandPosted = false
    rightCommandGeneration += 1
    if posted {
        DispatchQueue.main.async {
            if !leftCommandPosted {
                postExtraFlags(.maskCommand, enabled: false)
            }
        }
    } else if !used {
        rightCommandLatch = true
        postScrollChord()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            rightCommandLatch = false
        }
    }
}

private let hidScrollHeld: UInt32 = 0x00040000 | 0x00000001 | 0x00080000 | 0x00000020 | 0x00020000 | 0x00000004

private func postScrollChord() {
    // Same HID path as the left-command click chord. Right Shift is the
    // device-dependent shift bit 0x4; Control and Option stay on the left keys.
    // Those Right Shift events come back through this tap, so the remapper
    // must pass them through instead of treating them as a new gesture.
    postingScrollChord = true
    defer { postingScrollChord = false }
    postHID(type: hidFlagsChanged, key: UInt16(rightCommandKey), flags: 0)
    postHID(type: hidFlagsChanged, key: UInt16(leftControlKey), flags: hidControl)
    postHID(type: hidKeyDown, key: UInt16(leftControlKey), flags: hidControl)
    postHID(type: hidFlagsChanged, key: UInt16(leftOptionKey), flags: hidOption)
    postHID(type: hidKeyDown, key: UInt16(leftOptionKey), flags: hidOption)
    postHID(type: hidFlagsChanged, key: UInt16(rightShiftKey), flags: hidScrollHeld)
    postHID(type: hidKeyDown, key: UInt16(rightShiftKey), flags: hidScrollHeld)
    postHID(type: hidKeyDown, key: UInt16(leftArrowKey), flags: hidScrollHeld)
    postHID(type: hidKeyUp, key: UInt16(leftArrowKey), flags: hidScrollHeld)
    postHID(type: hidKeyUp, key: UInt16(rightShiftKey), flags: hidOption)
    postHID(type: hidFlagsChanged, key: UInt16(rightShiftKey), flags: hidOption)
    postHID(type: hidKeyUp, key: UInt16(leftOptionKey), flags: hidControl)
    postHID(type: hidFlagsChanged, key: UInt16(leftOptionKey), flags: hidControl)
    postHID(type: hidKeyUp, key: UInt16(leftControlKey), flags: 0)
    postHID(type: hidFlagsChanged, key: UInt16(leftControlKey), flags: 0)
    fputs("bulkey: right command tap\n", stderr)
}

private func beginRightShift() {
    guard !rightShiftTracking else { return }
    rightShiftTracking = true
    rightShiftUsed = false
    rightShiftPosted = false
    rightShiftGeneration += 1
    let generation = rightShiftGeneration
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        guard generation == rightShiftGeneration, rightShiftTracking, !rightShiftUsed else { return }
        holdRightShift(on: nil)
    }
}

private func holdRightShift(on event: CGEvent?) {
    guard rightShiftTracking else { return }
    rightShiftUsed = true
    if !rightShiftPosted {
        rightShiftPosted = true
        DispatchQueue.main.async { postExtraFlags(numLineFlags, enabled: true) }
    }
    event?.flags.formUnion(numLineFlags)
}

private func endRightShift() {
    guard rightShiftTracking else { return }
    let posted = rightShiftPosted
    let used = rightShiftUsed
    rightShiftTracking = false
    rightShiftUsed = false
    rightShiftPosted = false
    rightShiftGeneration += 1
    if posted {
        DispatchQueue.main.async {
            var extra = numLineFlags
            if leftCommandPosted || rightCommandPosted {
                extra.subtract(.maskCommand)
            }
            postExtraFlags(extra, enabled: false)
        }
    } else if !used {
        rightShiftLatch = true
        postPreviousWindow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            rightShiftLatch = false
        }
    }
}

private func postPreviousWindow() {
    var held = CGEventSource.flagsState(.hidSystemState)
    held.formUnion(previousWindowFlags)
    postTap(nKey, flags: held)
    fputs("bulkey: right shift tap\n", stderr)
}

private func beginTab(fingers: Int) {
    guard !tabTracking else { return }
    tabTracking = true
    tabUsed = false
    tabPosted = false
    tabFingers = fingers
    tabGeneration += 1
    let generation = tabGeneration
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        guard generation == tabGeneration, tabTracking, !tabUsed else { return }
        holdTab(on: nil)
    }
}

private func holdTab(on event: CGEvent?) {
    guard tabTracking else { return }
    tabUsed = true
    if !tabPosted {
        tabPosted = true
        DispatchQueue.main.async { postExtraFlags(tabHoldFlags, enabled: true) }
    }
    event?.flags.formUnion(tabHoldFlags)
}

private func endTab() {
    guard tabTracking else { return }
    let posted = tabPosted
    let used = tabUsed
    let fingers = tabFingers
    tabTracking = false
    tabUsed = false
    tabPosted = false
    tabGeneration += 1
    if posted {
        DispatchQueue.main.async {
            var extra = tabHoldFlags
            if leftCommandPosted || rightCommandPosted {
                extra.subtract(.maskCommand)
            }
            if rightShiftPosted {
                extra.subtract(.maskShift)
            }
            if capsFlagsPosted {
                extra.subtract(capsModifierFlags())
            }
            postExtraFlags(extra, enabled: false)
        }
    } else if !used {
        if fingers == 0 {
            postTap(tabKey, flags: aloneTabFlags())
        } else {
            postShiftTab()
        }
        fputs("bulkey: tab tap fingers=\(fingers)\n", stderr)
    }
}

private func aloneTabFlags(extra: CGEventFlags = []) -> CGEventFlags {
    var flags = CGEventSource.flagsState(.hidSystemState)
    flags.formUnion(extra)
    if capsMode != .none {
        flags.formUnion(capsModifierFlags())
    }
    if gate.phase == .chord {
        flags.formUnion(chord)
    }
    if leftCommandPosted || rightCommandPosted {
        flags.formUnion(.maskCommand)
    }
    if rightShiftPosted {
        flags.formUnion(numLineFlags)
    }
    return flags
}

private func postShiftTab() {
    let rightShift = CGEventFlags(rawValue: CGEventFlags.maskShift.rawValue | 0x00000004)
    postTap(tabKey, flags: aloneTabFlags(extra: rightShift))
}

private struct EditKey {
    var key: Int64
    var flags: CGEventFlags
}

private let editCommand = CGEventFlags(rawValue: CGEventFlags.maskCommand.rawValue | 0x00000008)
private let editShift = CGEventFlags(rawValue: CGEventFlags.maskShift.rawValue | 0x00000002)
private let editOption = CGEventFlags(rawValue: CGEventFlags.maskAlternate.rawValue | 0x00000020)
private let editControl = CGEventFlags(rawValue: CGEventFlags.maskControl.rawValue | 0x00000001)
private let editCommandShift = CGEventFlags(rawValue:
    CGEventFlags.maskCommand.rawValue | 0x00000008 | CGEventFlags.maskShift.rawValue | 0x00000002
)
private let editControlShift = CGEventFlags(rawValue:
    CGEventFlags.maskControl.rawValue | 0x00000001 | CGEventFlags.maskShift.rawValue | 0x00000002
)
private var textEditHeld: Set<Int64> = []

private func textEditSteps(keyCode: Int64, flags: CGEventFlags) -> [EditKey]? {
    if !flags.intersection([.maskControl, .maskAlternate, .maskCommand, .maskSecondaryFn]).isEmpty {
        return nil
    }
    let shift = flags.contains(.maskShift)
    let leftShift = shift && (flags.rawValue & 0x2) != 0 && (flags.rawValue & 0x4) == 0
    if shift && !leftShift {
        return nil
    }
    switch keyCode {
    case 12 where leftShift: // q: end, select to start, cut
        return [EditKey(key: 124, flags: editCommand), EditKey(key: 123, flags: editCommandShift), EditKey(key: 7, flags: editCommand)]
    case 12 where !shift: // q: end, delete to start
        return [EditKey(key: 124, flags: editCommand), EditKey(key: 51, flags: editCommand)]
    case 6 where !shift: // z: delete previous word
        return [EditKey(key: 51, flags: editOption)]
    case 9 where !shift: // v: delete next word
        return [EditKey(key: 117, flags: editOption)]
    case 13 where !shift: // w: previous word, delete next word
        return [EditKey(key: 123, flags: editOption), EditKey(key: 117, flags: editOption)]
    case 0: // a, shift optional: end of line
        return [EditKey(key: 124, flags: editCommand)]
    case 34: // i, shift optional: start of line
        return [EditKey(key: 123, flags: editCommand)]
    case 15 where !shift: // r: redo
        return [EditKey(key: 6, flags: editCommandShift)]
    case 17: // t, shift optional: start of document
        return [EditKey(key: 126, flags: editCommand)]
    case 16 where leftShift: // y: select all, copy, right
        return [EditKey(key: 0, flags: editCommand), EditKey(key: 8, flags: editCommand), EditKey(key: 124, flags: [])]
    case 16 where !shift: // y: select line, copy, move to end
        return [
            EditKey(key: 0, flags: editControl),
            EditKey(key: 14, flags: editControlShift),
            EditKey(key: 8, flags: editCommand),
            EditKey(key: 14, flags: editControl),
        ]
    case 32 where !shift: // u: undo
        return [EditKey(key: 6, flags: editCommand)]
    case 1 where !shift: // s: backspace
        return [EditKey(key: 51, flags: [])]
    case 7 where !shift: // x: forward delete
        return [EditKey(key: 117, flags: [])]
    case 2 where !shift: // d: delete to start of line
        return [EditKey(key: 51, flags: editCommand)]
    case 8 where !shift: // c: select to end of line, delete
        return [EditKey(key: 124, flags: editCommandShift), EditKey(key: 51, flags: [])]
    case 11: // b, shift optional: previous word
        return [EditKey(key: 123, flags: editOption)]
    case 14: // e, shift optional: next word
        return [EditKey(key: 124, flags: editOption)]
    case 5: // g, shift optional: end of document
        return [EditKey(key: 125, flags: editCommand)]
    case 31 where leftShift: // o: start of line, newline above
        return [EditKey(key: 123, flags: editCommand), EditKey(key: 36, flags: editShift), EditKey(key: 126, flags: [])]
    case 31 where !shift: // o: end of line, newline
        return [EditKey(key: 124, flags: editCommand), EditKey(key: 36, flags: editShift)]
    default:
        return nil
    }
}

private func clearAllKeyboardState() {
    let capsPosted = capsFlagsPosted
    let capsExtra = capsModifierFlags()
    let enterPosted = gate.phase == .chord
    let stuckArrows = Array(heldArrow.values)
    capsMode = .none
    capsUsed = false
    capsFlagsPosted = false
    leftCommandTracking = false
    leftCommandUsed = false
    leftCommandPosted = false
    leftCommandLatch = false
    leftCommandGeneration += 1
    rightCommandTracking = false
    rightCommandUsed = false
    rightCommandPosted = false
    rightCommandLatch = false
    rightCommandGeneration += 1
    rightShiftTracking = false
    rightShiftUsed = false
    rightShiftPosted = false
    rightShiftLatch = false
    rightShiftGeneration += 1
    tabTracking = false
    tabUsed = false
    tabPosted = false
    tabGeneration += 1
    textEditHeld.removeAll()
    let reposted = hidReposted
    hidReposted.removeAll()
    emittingSynthetic = false
    gate.phase = .idle
    gate.generation += 1
    heldArrow.removeAll()
    DispatchQueue.main.async {
        if capsPosted {
            postExtraFlags(capsExtra, enabled: false)
        }
        if enterPosted {
            postChord(false)
        }
        for arrow in stuckArrows {
            postHID(type: hidKeyUp, key: UInt16(arrow), flags: 0)
        }
        for key in reposted {
            postHID(type: hidKeyUp, key: UInt16(key), flags: 0)
        }
        var flags = CGEventSource.flagsState(.hidSystemState)
        flags.subtract([.maskCommand, .maskShift, .maskControl, .maskAlternate])
        postHID(type: hidFlagsChanged, key: UInt16(escapeKey), flags: hidFlags(from: flags))
    }
}

private func engageCapsModifiers(on event: CGEvent?) {
    guard capsMode != .none else { return }
    capsUsed = true
    let extra = capsModifierFlags()
    if !capsFlagsPosted {
        capsFlagsPosted = true
        DispatchQueue.main.async { postExtraFlags(extra, enabled: true) }
    }
    event?.flags.formUnion(extra)
}
private struct MTPoint {
    var x: Float
    var y: Float
}

private struct MTVector {
    var position: MTPoint
    var velocity: MTPoint
}

/// Layout matches MultitouchSupport's contact record. Normalized x is 0 at the
/// left edge and 1 at the right. Normalized y is 0 at the bottom edge and 1 at
/// the top edge, next to the keyboard.
private struct MTTouch {
    var frame: Int32
    var timestamp: Double
    var identifier: Int32
    var state: Int32
    var unknown1: Int32
    var unknown2: Int32
    var normalized: MTVector
    var size: Float
    var unknown3: Int32
    var angle: Float
    var majorAxis: Float
    var minorAxis: Float
    var absolute: MTVector
    var unknown4: Int32
    var unknown5: Int32
    var density: Float
}

private struct DeviceTouches {
    var total: Int
    var topLeft: Int
}

private let touchLock = NSLock()
private var touchesByDevice: [UInt: DeviceTouches] = [:]
private var lastLoggedTouch = ""

private func isTopLeftQuarter(x: Float, y: Float) -> Bool {
    x >= 0 && x < 0.5 && y >= 0.5 && y <= 1
}

private func isIgnoredSide(x: Float) -> Bool {
    // Left quarter and right quarter are easy to brush while typing.
    x < 0.25 || x >= 0.75
}

private func countedFingerCount(touches: UnsafeMutableRawPointer?, count: Int) -> Int {
    guard let touches, count > 0, count < 16 else { return 0 }
    let stride = MemoryLayout<MTTouch>.stride
    var counted = 0
    for index in 0..<count {
        let touch = touches.advanced(by: index * stride).load(as: MTTouch.self)
        let point = touch.normalized.position
        if !isIgnoredSide(x: point.x) {
            counted += 1
        }
    }
    return counted
}

private func topLeftCount(touches: UnsafeMutableRawPointer?, count: Int) -> Int {
    guard let touches, count > 0, count < 16 else { return 0 }
    let stride = MemoryLayout<MTTouch>.stride
    var inside = 0
    for index in 0..<count {
        let touch = touches.advanced(by: index * stride).load(as: MTTouch.self)
        let point = touch.normalized.position
        if !isIgnoredSide(x: point.x) && isTopLeftQuarter(x: point.x, y: point.y) {
            inside += 1
        }
    }
    return inside
}

private func touchState() -> DeviceTouches {
    touchLock.lock()
    defer { touchLock.unlock() }
    return touchesByDevice.values.reduce(DeviceTouches(total: 0, topLeft: 0)) { partial, device in
        DeviceTouches(total: partial.total + device.total, topLeft: partial.topLeft + device.topLeft)
    }
}
private let holdSeconds: Double = {
    if CommandLine.arguments.count > 1, let ms = Double(CommandLine.arguments[1]), ms > 0 {
        return ms / 1000
    }
    return 0.20
}()

private func postChord(_ down: Bool) {
    var flags = CGEventSource.flagsState(.hidSystemState)
    if down {
        flags.formUnion(chord)
    } else {
        flags.subtract(chord)
    }
    postHID(type: hidFlagsChanged, key: UInt16(leftControlKey), flags: hidFlags(from: flags))
}

private func postReturn() {
    let restore = hidFlags(from: CGEventSource.flagsState(.hidSystemState))
    postHID(type: hidKeyDown, key: UInt16(returnKey), flags: 0)
    postHID(type: hidKeyUp, key: UInt16(returnKey), flags: 0)
    if restore != 0 {
        postHID(type: hidFlagsChanged, key: UInt16(returnKey), flags: restore)
    }
}

private func beginChord() {
    guard gate.phase == .pending || gate.phase == .held else { return }
    gate.phase = .chord
    gate.generation += 1
    DispatchQueue.main.async { postChord(true) }
}

private func armHoldTimer() {
    let generation = gate.generation
    DispatchQueue.main.asyncAfter(deadline: .now() + holdSeconds) {
        guard gate.generation == generation, gate.phase == .pending else { return }
        gate.phase = .held
    }
}

private let callback: CGEventTapCallBack = { _, type, event, _ in
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tapPort {
            CGEvent.tapEnable(tap: tapPort, enable: true)
        }
        return Unmanaged.passUnretained(event)
    }

    if emittingSynthetic || event.getIntegerValueField(.eventSourceUserData) == postedByUs {
        return Unmanaged.passUnretained(event)
    }

    let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
    if hidInjecting > 0 || hidEchoKeys.contains(keyCode) {
        if let index = hidEchoKeys.firstIndex(of: keyCode) {
            hidEchoKeys.remove(at: index)
        }
        return Unmanaged.passUnretained(event)
    }
    let isReturn = keyCode == returnKey || keyCode == keypadEnter
    let repeatKey = event.getIntegerValueField(.keyboardEventAutorepeat) != 0

    if keyCode == escapeKey && type == .keyDown && !repeatKey {
        clearAllKeyboardState()
        return Unmanaged.passUnretained(event)
    }

    if type == .keyUp, hidReposted.remove(keyCode) != nil {
        var flags = event.flags
        if gate.phase == .chord {
            flags.formUnion(chord)
        }
        postHID(type: hidKeyUp, key: UInt16(keyCode), flags: hidFlags(from: flags))
        return nil
    }

    if capsKeys.contains(keyCode) {
        if type == .keyDown, tabTracking {
            holdTab(on: nil)
        }
        if type == .keyDown {
            if repeatKey || capsMode != .none {
                return nil
            }
            let fingers = touchState().total
            // F18, which is what Caps Lock is mapped to, arrives with the Fn flag set.
            // That is not the user holding Fn.
            let heldModifiers = event.flags.intersection([
                .maskShift, .maskControl, .maskAlternate, .maskCommand,
            ])
            if fingers == 0 && heldModifiers.isEmpty {
                capsMode = .hyper
            } else if fingers == 1 && heldModifiers.isEmpty {
                capsMode = .shifted
            } else {
                fputs(
                    "bulkey: caps skipped fingers=\(fingers) flags=\(event.flags.rawValue)\n",
                    stderr
                )
                return Unmanaged.passUnretained(event)
            }
            capsUsed = false
            capsFlagsPosted = false
            fputs("bulkey: caps fingers=\(fingers) mode=\(capsMode)\n", stderr)
            releaseCapsLockIfOn()
            return nil
        }
        if type == .keyUp {
            let mode = capsMode
            if mode == .none {
                return Unmanaged.passUnretained(event)
            }
            let used = capsUsed
            let posted = capsFlagsPosted
            let extra = capsModifierFlags()
            capsMode = .none
            capsUsed = false
            capsFlagsPosted = false
            if posted {
                DispatchQueue.main.async { postExtraFlags(extra, enabled: false) }
            } else if mode == .hyper && !used {
                DispatchQueue.main.async { postTap(escapeKey) }
            }
            fputs("bulkey: caps up mode=\(mode) used=\(used)\n", stderr)
            return nil
        }
    }

    if !capsKeys.contains(keyCode), keyCode != leftCommandKey, keyCode != rightCommandKey, capsMode != .none, type == .keyDown {
        engageCapsModifiers(on: event)
    }

    if keyCode == leftCommandKey {
        let leftCommandPress = type == .keyDown
            || (type == .flagsChanged && event.flags.contains(.maskCommand))
        if leftCommandPress, tabTracking {
            holdTab(on: nil)
        }
        let otherModifier = !event.flags.intersection([
            .maskShift, .maskControl, .maskAlternate, .maskSecondaryFn,
        ]).isEmpty || (event.flags.rawValue & 0x10) != 0
            || rightCommandTracking || rightShiftTracking || capsMode != .none
        if !leftCommandTracking && otherModifier {
            if rightCommandTracking {
                holdRightCommand(on: nil)
            }
            if rightShiftTracking {
                holdRightShift(on: nil)
            }
            if capsMode != .none {
                engageCapsModifiers(on: nil)
            }
            return Unmanaged.passUnretained(event)
        }
        if rightCommandTracking {
            holdRightCommand(on: event)
        }
        if rightShiftTracking {
            holdRightShift(on: event)
        }
        if leftCommandLatch {
            return Unmanaged.passUnretained(event)
        }
        if type == .flagsChanged {
            if event.flags.contains(.maskCommand) {
                if !leftCommandTracking {
                    beginLeftCommand()
                }
                return nil
            }
            if leftCommandTracking {
                endLeftCommand()
                return Unmanaged.passUnretained(event)
            }
            return Unmanaged.passUnretained(event)
        }
        if type == .keyDown {
            if repeatKey || leftCommandTracking {
                return nil
            }
            beginLeftCommand()
            return nil
        }
        if type == .keyUp {
            if leftCommandTracking {
                endLeftCommand()
            }
            return Unmanaged.passUnretained(event)
        }
    }

    if keyCode == rightCommandKey {
        let rightCommandPress = type == .keyDown || (type == .flagsChanged && (event.flags.rawValue & 0x10) != 0)
        if rightCommandPress, tabTracking {
            holdTab(on: nil)
        }
        let otherModifier = !event.flags.intersection([
            .maskShift, .maskControl, .maskAlternate, .maskSecondaryFn,
        ]).isEmpty || (event.flags.rawValue & 0x08) != 0
            || leftCommandTracking || rightShiftTracking || capsMode != .none
        if !rightCommandTracking && otherModifier {
            if leftCommandTracking {
                holdLeftCommand(on: nil)
            }
            if rightShiftTracking {
                holdRightShift(on: nil)
            }
            if capsMode != .none {
                engageCapsModifiers(on: nil)
            }
            return Unmanaged.passUnretained(event)
        }
        if leftCommandTracking {
            holdLeftCommand(on: event)
        }
        if rightShiftTracking {
            holdRightShift(on: event)
        }
        let rightCommandDown = (event.flags.rawValue & 0x10) != 0
        if rightCommandLatch {
            return Unmanaged.passUnretained(event)
        }
        if type == .flagsChanged {
            if rightCommandDown {
                if !rightCommandTracking {
                    beginRightCommand()
                }
                return nil
            }
            if rightCommandTracking {
                endRightCommand()
                return Unmanaged.passUnretained(event)
            }
            return Unmanaged.passUnretained(event)
        }
        if type == .keyDown {
            if repeatKey || rightCommandTracking {
                return nil
            }
            beginRightCommand()
            return nil
        }
        if type == .keyUp {
            if rightCommandTracking {
                endRightCommand()
            }
            return Unmanaged.passUnretained(event)
        }
    }

    if leftCommandTracking, keyCode != leftCommandKey, type == .keyDown || type == .flagsChanged {
        holdLeftCommand(on: event)
    }

    if rightCommandTracking, keyCode != rightCommandKey, type == .keyDown || type == .flagsChanged {
        holdRightCommand(on: event)
    }

    if keyCode == rightShiftKey {
        let rightShiftPress = type == .keyDown || (type == .flagsChanged && (event.flags.rawValue & 0x4) != 0)
        if rightShiftPress, tabTracking {
            holdTab(on: nil)
        }
        if postingScrollChord || rightCommandLatch || rightShiftLatch {
            return Unmanaged.passUnretained(event)
        }
        let rightShiftDown = (event.flags.rawValue & 0x4) != 0
        if type == .flagsChanged {
            if rightShiftDown {
                if !rightShiftTracking {
                    beginRightShift()
                }
                return nil
            }
            if rightShiftTracking {
                endRightShift()
                return Unmanaged.passUnretained(event)
            }
            return Unmanaged.passUnretained(event)
        }
        if type == .keyDown {
            if repeatKey || rightShiftTracking {
                return nil
            }
            beginRightShift()
            return nil
        }
        if type == .keyUp {
            if rightShiftTracking {
                endRightShift()
            }
            return Unmanaged.passUnretained(event)
        }
    }

    if rightShiftTracking, keyCode != rightShiftKey, type == .keyDown || type == .flagsChanged {
        holdRightShift(on: event)
    }

    if keyCode == tabKey, type == .keyDown || type == .keyUp {
        let fingers = touchState().total
        if type == .keyDown {
            if repeatKey || tabTracking {
                return tabTracking ? nil : Unmanaged.passUnretained(event)
            }
            if fingers < 2 {
                if gate.phase == .pending || gate.phase == .held {
                    beginChord()
                }
                beginTab(fingers: fingers)
                return nil
            }
        } else if tabTracking {
            endTab()
            return nil
        }
    }

    if tabTracking, keyCode != tabKey, type == .keyDown || type == .flagsChanged {
        holdTab(on: event)
    }

    if type == .keyDown || type == .keyUp, touchState().total == 1 || textEditHeld.contains(keyCode) {
        if type == .keyUp {
            if textEditHeld.remove(keyCode) != nil {
                return nil
            }
        } else if touchState().total == 1, let steps = textEditSteps(keyCode: keyCode, flags: event.flags) {
            if gate.phase == .pending || gate.phase == .held {
                beginChord()
            }
            textEditHeld.insert(keyCode)
            if !repeatKey {
                fputs("bulkey: text edit \(keyCode)\n", stderr)
            }
            for step in steps {
                postTap(step.key, flags: step.flags)
            }
            return nil
        } else {
            textEditHeld.remove(keyCode)
        }
    }

    if isReturn {
        if type == .keyDown {
            if tabTracking {
                holdTab(on: nil)
            }
            if repeatKey || gate.phase != .idle {
                return nil
            }
            gate.phase = .pending
            gate.generation += 1
            armHoldTimer()
            return nil
        }
        if type == .keyUp {
            let phase = gate.phase
            if phase == .idle {
                return Unmanaged.passUnretained(event)
            }
            gate.phase = .idle
            gate.generation += 1
            if phase == .pending {
                DispatchQueue.main.async { postReturn() }
            } else if phase == .chord {
                DispatchQueue.main.async { postChord(false) }
            }
            return nil
        }
    }

    if type == .keyDown, gate.phase == .pending || gate.phase == .held || gate.phase == .chord {
        if gate.phase != .chord {
            beginChord()
        }
        event.flags.formUnion(chord)
        hidReposted.insert(keyCode)
        postHID(type: hidKeyDown, key: UInt16(keyCode), flags: hidFlags(from: event.flags))
        return nil
    }

    if let arrow = arrowByKey[keyCode] {
        let blocked = event.flags.intersection([
            .maskControl, .maskAlternate, .maskCommand, .maskSecondaryFn,
        ])
        if type == .keyDown {
            let freshPress = !repeatKey && heldArrow[keyCode] == nil
            let touches = touchState()
            if freshPress && blocked.isEmpty && gate.phase == .idle && touches.topLeft > 0 {
                heldArrow[keyCode] = arrow
            }
            if let mapped = heldArrow[keyCode] {
                postHID(type: hidKeyDown, key: UInt16(mapped), flags: hidFlags(from: event.flags))
                return nil
            }
        } else if type == .keyUp, let mapped = heldArrow.removeValue(forKey: keyCode) {
            postHID(type: hidKeyUp, key: UInt16(mapped), flags: hidFlags(from: event.flags))
            return nil
        }
    }
    return Unmanaged.passUnretained(event)
}

private let contactFrame: @convention(c) (
    UnsafeMutableRawPointer?,
    UnsafeMutableRawPointer?,
    Int32,
    Double,
    Int32
) -> Int32 = { device, touches, numTouches, _, _ in
    let key = device.map { UInt(bitPattern: $0) } ?? 0
    let count = Int(max(numTouches, 0))
    let topLeft = topLeftCount(touches: touches, count: count)
    let counted = countedFingerCount(touches: touches, count: count)
    var sample = ""
    if let touches, count > 0 {
        let touch = touches.load(as: MTTouch.self)
        sample = String(format: " x=%.2f y=%.2f", touch.normalized.position.x, touch.normalized.position.y)
    }
    touchLock.lock()
    touchesByDevice[key] = DeviceTouches(total: counted, topLeft: topLeft)
    let total = touchesByDevice.values.reduce(0) { $0 + $1.total }
    let zone = touchesByDevice.values.reduce(0) { $0 + $1.topLeft }
    touchLock.unlock()
    let line = "fingers \(total) topLeft \(zone)\(sample)"
    if line != lastLoggedTouch {
        lastLoggedTouch = line
        fputs("bulkey: \(line)\n", stderr)
    }
    return 0
}

private func startTrackpad() {
    typealias CreateList = @convention(c) () -> Unmanaged<CFArray>?
    typealias IsBuiltIn = @convention(c) (UnsafeMutableRawPointer) -> Int32
    typealias Register = @convention(c) (
        UnsafeMutableRawPointer,
        @convention(c) (
            UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, Int32, Double, Int32
        ) -> Int32
    ) -> Void
    typealias Start = @convention(c) (UnsafeMutableRawPointer, Int32) -> Int32

    guard let handle = dlopen(
        "/System/Library/PrivateFrameworks/MultitouchSupport.framework/MultitouchSupport",
        RTLD_NOW
    ) else {
        fputs("bulkey: trackpad library did not load\n", stderr)
        return
    }
    guard
        let createSym = dlsym(handle, "MTDeviceCreateList"),
        let builtInSym = dlsym(handle, "MTDeviceIsBuiltIn"),
        let registerSym = dlsym(handle, "MTRegisterContactFrameCallback"),
        let startSym = dlsym(handle, "MTDeviceStart")
    else {
        fputs("bulkey: trackpad symbols missing\n", stderr)
        return
    }

    let createList = unsafeBitCast(createSym, to: CreateList.self)
    let isBuiltIn = unsafeBitCast(builtInSym, to: IsBuiltIn.self)
    let register = unsafeBitCast(registerSym, to: Register.self)
    let start = unsafeBitCast(startSym, to: Start.self)

    guard let list = createList()?.takeRetainedValue() else {
        fputs("bulkey: no trackpad devices\n", stderr)
        return
    }

    let count = CFArrayGetCount(list)
    var devices: [UnsafeMutableRawPointer] = []
    for index in 0..<count {
        guard let value = CFArrayGetValueAtIndex(list, index) else { continue }
        let device = UnsafeMutableRawPointer(mutating: value)
        if isBuiltIn(device) != 0 {
            devices.append(device)
        }
    }
    if devices.isEmpty {
        for index in 0..<count {
            guard let value = CFArrayGetValueAtIndex(list, index) else { continue }
            devices.append(UnsafeMutableRawPointer(mutating: value))
        }
    }

    for device in devices {
        register(device, contactFrame)
        _ = start(device, 0)
    }
    fputs(
        "bulkey: tracking \(devices.count) trackpad(s), touch stride \(MemoryLayout<MTTouch>.stride)\n",
        stderr
    )
}

private func installTap() -> Bool {
    let mask = (1 << CGEventType.keyDown.rawValue)
        | (1 << CGEventType.keyUp.rawValue)
        | (1 << CGEventType.flagsChanged.rawValue)
    guard
        let port = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: callback,
            userInfo: nil
        )
    else { return false }

    tapPort = port
    let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
    CGEvent.tapEnable(tap: port, enable: true)
    return true
}

private func promptForTrust() {
    let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
    let options = [key: true] as CFDictionary
    _ = AXIsProcessTrustedWithOptions(options)
}

signal(SIGINT, SIG_IGN)
signal(SIGTERM, SIG_IGN)
let stop = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
stop.setEventHandler { CFRunLoopStop(CFRunLoopGetCurrent()) }
stop.resume()
let stopTerm = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)
stopTerm.setEventHandler { CFRunLoopStop(CFRunLoopGetCurrent()) }
stopTerm.resume()

private func relaunchQuietly() -> Never {
    let path = CommandLine.arguments[0]
    var parts = [path]
    for arg in CommandLine.arguments.dropFirst() where arg != "--waited" {
        parts.append(arg)
    }
    parts.append("--waited")
    let cStrings = parts.map { strdup($0) }
    var argv: [UnsafeMutablePointer<CChar>?] = cStrings
    argv.append(nil)
    execv(path, &argv)
    fputs("bulkey: relaunch failed\n", stderr)
    exit(1)
}

fputs("bulkey: hold threshold \(Int(holdSeconds * 1000))ms\n", stderr)
startTrackpad()

let alreadyAsked = CommandLine.arguments.contains("--waited")
if !AXIsProcessTrusted() && !alreadyAsked {
    fputs("bulkey: Accessibility is not granted. Enable bulkey, then it will reload.\n", stderr)
    promptForTrust()
    Thread.sleep(forTimeInterval: 2)
    relaunchQuietly()
}

var announcedTapBlock = false
var untrustedWaits = 0
while !installTap() {
    if AXIsProcessTrusted() {
        if !announcedTapBlock {
            fputs("bulkey: Accessibility is granted, but the keyboard tap is still blocked\n", stderr)
            announcedTapBlock = true
        }
    } else {
        untrustedWaits += 1
        if untrustedWaits == 5 {
            relaunchQuietly()
        }
    }
    CFRunLoopRunInMode(.defaultMode, 1.0, false)
}

fputs("bulkey: listening\n", stderr)
var flags = CGEventSource.flagsState(.hidSystemState)
flags.subtract([.maskCommand, .maskShift, .maskControl, .maskAlternate])
postHID(type: hidFlagsChanged, key: UInt16(leftControlKey), flags: hidFlags(from: flags))
CFRunLoopRun()
