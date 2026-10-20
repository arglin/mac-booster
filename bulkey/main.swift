import ApplicationServices
import CoreGraphics
import Foundation
import IOKit.hidsystem

/// Replacement keys are posted into the HID system, the same layer Carbon hotkeys
/// read. The event tap still catches the physical key.
///
/// Enter, keypad Enter, and Backslash: a tap sends Return. Holding any of them, or
/// pressing another key while it is down, is Left Control+Left Shift+Left Command.
///
/// If a modifier is already down when one of them is pressed, it passes through
/// unchanged.
///
/// Section (§): types Backslash.
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
/// or pressing another key while it is down, is Left Option+Left Command+Left Shift,
/// and those three stay down until Right Shift is released.
///
/// Tab: with no counted finger, a tap is Tab. With one counted finger, a tap is
/// Right Shift+Tab. Holding it, or pressing another key while it is down, is
/// Left Option+Left Command+Left Shift, and those three stay down until Tab is
/// released. Two or more counted fingers, or a modifier already down, leave Tab
/// alone.
///
/// One counted finger also turns the text-edit letters into their editing sequences.
/// Left Shift changes Q, Y, and O. A, I, T, B, E, and G allow Left Shift. Any other
/// modifier leaves the letter alone.
///
/// Caps Lock: a tap is Escape. Holding it while pressing another key is
/// Control+Option+Command. While bulkey runs, Caps Lock is mapped to F18 in the
/// HID system so macOS never toggles Caps Lock itself.

private let returnKey: Int64 = 36
private let keypadEnter: Int64 = 76
private let backslashKey: Int64 = 42
private let sectionKey: Int64 = 10
private var tapPort: CFMachPort?
private let arrowByKey: [Int64: Int64] = [
    4: 123, // h -> left
    37: 124, // l -> right
    38: 125, // j -> down
    40: 126, // k -> up
]
private var heldArrow: [Int64: Int64] = [:]
private let capsKey: Int64 = 79 // F18, which Caps Lock is mapped to
private let capsLockUsage: UInt64 = 0x7_0000_0039
private let f18Usage: UInt64 = 0x7_0000_006D
private let mappingSrcKey = "HIDKeyboardModifierMappingSrc"
private let mappingDstKey = "HIDKeyboardModifierMappingDst"
private let hidEventSystem = IOHIDEventSystemClientCreateSimpleClient(kCFAllocatorDefault)

/// Adds or removes Caps Lock -> F18 in the user key mapping, leaving any other
/// entries in place.
private func setCapsLockRemap(_ enabled: Bool) {
    let key = "UserKeyMapping" as CFString
    let current = IOHIDEventSystemClientCopyProperty(hidEventSystem, key) as? [[String: Any]] ?? []
    var mapping = current.filter { entry in
        (entry[mappingSrcKey] as? NSNumber)?.uint64Value != capsLockUsage
    }
    if enabled {
        mapping.append([mappingSrcKey: capsLockUsage, mappingDstKey: f18Usage])
    }
    if !IOHIDEventSystemClientSetProperty(hidEventSystem, key, mapping as CFArray) {
        fputs("bulkey: could not \(enabled ? "map" : "unmap") Caps Lock\n", stderr)
    }
}
private let escapeKey: Int64 = 53
private let hyperFlags: CGEventFlags = [.maskControl, .maskAlternate, .maskCommand]
private var capsHeld = false
private var capsUsed = false
private var capsFlagsPosted = false

private func postExtraFlags(_ extra: CGEventFlags, enabled: Bool) {
    var flags = currentModifierFlags()
    if enabled {
        flags.formUnion(extra)
    } else {
        flags.subtract(extra)
    }
    postHID(type: hidFlagsChanged, key: UInt16(leftControlKey), flags: hidFlags(from: flags))
}

/// AltTab folds every modifier update together and treats a missing
/// Option, Command, or Shift as the hold being released. While Tab or Enter
/// is held, events that continue keep exactly those three. Letter keys are
/// posted again at the HID layer so a shortcut such as Option+Command+Shift+N
/// is the same event as holding those keys.
private func postExactFlags(_ flags: CGEventFlags) {
    postHID(type: hidFlagsChanged, key: UInt16(leftControlKey), flags: hidFlags(from: flags))
}

private let modifierKeyCodes: Set<Int64> = [54, 55, 56, 58, 59, 60, 61, 62, 63]

private func pass(_ event: CGEvent) -> Unmanaged<CGEvent> {
    if tabPosted || rightShiftPosted {
        event.flags = tabHoldFlags
    }
    return Unmanaged.passUnretained(event)
}

private struct ModifierKey {
    let key: UInt16
    let mask: UInt64
    let device: UInt64
    var flags: UInt64 { mask | device }
}

/// Listed in the order they are pressed.
private let leftModifierKeys = [
    ModifierKey(key: 59, mask: CGEventFlags.maskControl.rawValue, device: 0x1),
    ModifierKey(key: 58, mask: CGEventFlags.maskAlternate.rawValue, device: 0x20),
    ModifierKey(key: 56, mask: CGEventFlags.maskShift.rawValue, device: 0x2),
    ModifierKey(key: 55, mask: CGEventFlags.maskCommand.rawValue, device: 0x8),
    ModifierKey(key: 63, mask: CGEventFlags.maskSecondaryFn.rawValue, device: 0),
]
private let rightModifierKey: [UInt64: ModifierKey] = [
    CGEventFlags.maskControl.rawValue: ModifierKey(key: 62, mask: CGEventFlags.maskControl.rawValue, device: 0x2000),
    CGEventFlags.maskAlternate.rawValue: ModifierKey(key: 61, mask: CGEventFlags.maskAlternate.rawValue, device: 0x40),
    CGEventFlags.maskShift.rawValue: ModifierKey(key: 60, mask: CGEventFlags.maskShift.rawValue, device: 0x4),
    CGEventFlags.maskCommand.rawValue: ModifierKey(key: 54, mask: CGEventFlags.maskCommand.rawValue, device: 0x10),
]
private let allModifierBits = (leftModifierKeys + Array(rightModifierKey.values)).reduce(UInt64(0)) { $0 | $1.flags }

/// The physical keys behind `flags`. A modifier with no side bit is the left key.
private func modifierKeys(in flags: CGEventFlags) -> [ModifierKey] {
    let raw = flags.rawValue
    var keys: [ModifierKey] = []
    for left in leftModifierKeys where raw & left.mask != 0 {
        let right = rightModifierKey[left.mask]
        let hasRight = right.map { raw & $0.device != 0 } ?? false
        if raw & left.device != 0 || !hasRight {
            keys.append(left)
        }
        if hasRight, let right {
            keys.append(right)
        }
    }
    return keys
}

private let modifierKeyByCode: [UInt16: ModifierKey] = Dictionary(
    uniqueKeysWithValues: (leftModifierKeys + Array(rightModifierKey.values)).map { ($0.key, $0) }
)
/// Command and Right Shift are handled by bulkey's own tap/hold logic and are
/// counted through the `...Posted` flags instead.
private let trackedModifierCodes: Set<UInt16> = [56, 58, 59, 61, 62, 63]
private var physicalModifiers: Set<UInt16> = []

/// Follows the physical modifier keys. Event flags also carry the modifiers
/// bulkey is holding, so a set bit is not proof the key went down: a change
/// with the bit set toggles, one with the bit clear is always a release.
/// A key press resyncs the sided modifiers from its flags while bulkey holds
/// nothing, so a missed release heals on the next keystroke. Fn is left out of
/// the resync: arrow and function keys always carry it.
private func trackPhysicalModifier(_ type: CGEventType, _ event: CGEvent, keyCode: Int64) {
    let raw = event.flags.rawValue
    if type == .flagsChanged {
        let code = UInt16(truncatingIfNeeded: keyCode)
        guard trackedModifierCodes.contains(code), let modifier = modifierKeyByCode[code] else { return }
        let bitSet = modifier.device != 0 ? raw & modifier.device != 0 : event.flags.contains(.maskSecondaryFn)
        if bitSet && !physicalModifiers.contains(code) {
            physicalModifiers.insert(code)
        } else {
            physicalModifiers.remove(code)
        }
    } else if type == .keyDown, !bulkeyHoldsModifiers() {
        for code in trackedModifierCodes {
            guard let modifier = modifierKeyByCode[code], modifier.device != 0 else { continue }
            if raw & modifier.device != 0 {
                physicalModifiers.insert(code)
            } else {
                physicalModifiers.remove(code)
            }
        }
    }
}

private func bulkeyHoldsModifiers() -> Bool {
    leftCommandPosted || rightCommandPosted || rightShiftPosted || capsFlagsPosted
        || tabPosted || returnPosted || sequenceInFlight
}

/// The modifiers held right now: physical keys plus the holds bulkey posted.
/// Read from bulkey's own state, because the HID state can still show a
/// modifier bulkey released a moment ago, and restoring it would leave it stuck.
private func currentModifierFlags() -> CGEventFlags {
    var flags = CGEventFlags(rawValue: physicalModifiers.reduce(UInt64(0)) { raw, code in
        raw | (modifierKeyByCode[code]?.flags ?? 0)
    })
    if leftCommandPosted || rightCommandPosted {
        flags.formUnion(.maskCommand)
    }
    if returnPosted {
        flags.formUnion(numLineFlags)
    }
    if capsFlagsPosted {
        flags.formUnion(hyperFlags)
    }
    if tabPosted || rightShiftPosted {
        flags.formUnion(tabHoldFlags)
    }
    if CGEventSource.flagsState(.hidSystemState).contains(.maskAlphaShift) {
        flags.formUnion(.maskAlphaShift)
    }
    return flags
}

/// Presses and releases modifier keys one at a time, as typing them would.
private func postModifierChange(from: CGEventFlags, to: CGEventFlags) {
    let target = modifierKeys(in: to)
    var held = modifierKeys(in: from)
    let others = from.rawValue & ~allModifierBits
    func heldFlags() -> UInt32 {
        hidFlags(from: CGEventFlags(rawValue: held.reduce(others) { $0 | $1.flags }))
    }
    for key in held.reversed() where !target.contains(where: { $0.key == key.key }) {
        held.removeAll { $0.key == key.key }
        postHID(type: hidFlagsChanged, key: key.key, flags: heldFlags())
    }
    for key in target where !held.contains(where: { $0.key == key.key }) {
        held.append(key)
        postHID(type: hidFlagsChanged, key: key.key, flags: heldFlags())
    }
}

private func postTap(_ key: Int64, flags: CGEventFlags = []) {
    postSequence([EditKey(key: key, flags: flags)])
}

/// Editors such as Electron apps move the cursor asynchronously, so a key sent
/// immediately after another can act on the old cursor position.
private let sequenceStepDelay: Double = 0.005
/// True from the first key of a sequence until its modifiers are released.
private var sequenceInFlight = false

/// Types the keys in order, moving straight from one key's modifiers to the
/// next. The held modifiers are read once: right after posting, the HID state
/// may not yet show the release of the previous key's modifiers.
private func postSequence(_ steps: [EditKey]) {
    guard !steps.isEmpty else { return }
    sequenceInFlight = true
    let base = (tabPosted || rightShiftPosted) ? tabHoldFlags : currentModifierFlags()
    var previous = base
    for (index, step) in steps.enumerated() {
        let from = previous
        let isLast = index == steps.count - 1
        let send = {
            let code = UInt16(step.key)
            postModifierChange(from: from, to: step.flags)
            postHID(type: hidKeyDown, key: code, flags: hidFlags(from: step.flags))
            postHID(type: hidKeyUp, key: code, flags: hidFlags(from: step.flags))
            if isLast {
                postModifierChange(from: step.flags, to: base)
                sequenceInFlight = false
            }
        }
        if index == 0 {
            send()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + sequenceStepDelay * Double(index), execute: send)
        }
        previous = step.flags
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
    CGEventFlags.maskCommand.rawValue | 0x00000008 |
    CGEventFlags.maskAlternate.rawValue | 0x00000020 |
    CGEventFlags.maskShift.rawValue | 0x00000002
)

private func beginLeftCommand() {
    guard !leftCommandTracking else { return }
    leftCommandTracking = true
    leftCommandUsed = false
    leftCommandPosted = false
    leftCommandGeneration += 1
    let generation = leftCommandGeneration
    DispatchQueue.main.asyncAfter(deadline: .now() + holdSeconds) {
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
    DispatchQueue.main.asyncAfter(deadline: .now() + holdSeconds) {
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
    DispatchQueue.main.asyncAfter(deadline: .now() + holdSeconds) {
        guard generation == rightShiftGeneration, rightShiftTracking, !rightShiftUsed else { return }
        holdRightShift(on: nil)
    }
}

private func holdRightShift(on event: CGEvent?) {
    guard rightShiftTracking else { return }
    rightShiftUsed = true
    if !rightShiftPosted {
        rightShiftPosted = true
        postExactFlags(tabHoldFlags)
    }
    event?.flags = tabHoldFlags
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
        if !tabPosted {
            DispatchQueue.main.async { releaseLayerFlags() }
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
    var held = currentModifierFlags()
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
    DispatchQueue.main.asyncAfter(deadline: .now() + holdSeconds) {
        guard generation == tabGeneration, tabTracking, !tabUsed else { return }
        holdTab(on: nil)
    }
}

private func holdTab(on event: CGEvent?) {
    guard tabTracking else { return }
    tabUsed = true
    if !tabPosted {
        tabPosted = true
        postExactFlags(tabHoldFlags)
    }
    event?.flags = tabHoldFlags
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
    if posted && !rightShiftPosted {
        DispatchQueue.main.async { releaseLayerFlags() }
    } else if !used {
        if fingers == 0 {
            postTap(tabKey, flags: aloneTabFlags())
        } else {
            postShiftTab()
        }
        fputs("bulkey: tab tap fingers=\(fingers)\n", stderr)
    }
}

private var returnTracking = false
private var returnUsed = false
private var returnPosted = false
/// Enter-like keys pressed while a modifier was down; they pass through unchanged
/// until released.
private var returnPassed: Set<Int64> = []
/// Modifiers that make Tab and the Enter-like keys pass through unchanged.
private let passModifiers: CGEventFlags = [
    .maskShift, .maskControl, .maskAlternate, .maskCommand, .maskSecondaryFn,
]
private var returnGeneration = 0

private func beginReturn() {
    guard !returnTracking else { return }
    returnTracking = true
    returnUsed = false
    returnPosted = false
    returnGeneration += 1
    let generation = returnGeneration
    DispatchQueue.main.asyncAfter(deadline: .now() + holdSeconds) {
        guard generation == returnGeneration, returnTracking, !returnUsed else { return }
        holdReturn(on: nil)
    }
}

private func holdReturn(on event: CGEvent?) {
    guard returnTracking else { return }
    returnUsed = true
    if !returnPosted {
        returnPosted = true
        DispatchQueue.main.async { postExtraFlags(numLineFlags, enabled: true) }
    }
    event?.flags.formUnion(numLineFlags)
}

private func endReturn() {
    guard returnTracking else { return }
    let posted = returnPosted
    let used = returnUsed
    returnTracking = false
    returnUsed = false
    returnPosted = false
    returnGeneration += 1
    if posted {
        DispatchQueue.main.async {
            var extra = numLineFlags
            if leftCommandPosted || rightCommandPosted {
                extra.subtract(.maskCommand)
            }
            if tabPosted || rightShiftPosted {
                extra.subtract(tabHoldFlags)
            }
            postExtraFlags(extra, enabled: false)
        }
    } else if !used {
        postReturn()
        fputs("bulkey: enter tap\n", stderr)
    }
}

/// Lifts the Tab and Right Shift layer, keeping any modifier another held key still owns.
private func releaseLayerFlags() {
    var extra = tabHoldFlags
    if leftCommandPosted || rightCommandPosted {
        extra.subtract(.maskCommand)
    }
    if returnPosted {
        extra.subtract(numLineFlags)
    }
    if capsFlagsPosted {
        extra.subtract(hyperFlags)
    }
    postExtraFlags(extra, enabled: false)
}

private func aloneTabFlags(extra: CGEventFlags = []) -> CGEventFlags {
    var flags = currentModifierFlags()
    flags.formUnion(extra)
    if capsHeld {
        flags.formUnion(hyperFlags)
    }
    if leftCommandPosted || rightCommandPosted {
        flags.formUnion(.maskCommand)
    }
    if returnPosted {
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
private let editOptionFn = CGEventFlags(rawValue: editOption.rawValue | CGEventFlags.maskSecondaryFn.rawValue)
private let editControl = CGEventFlags(rawValue: CGEventFlags.maskControl.rawValue | 0x00000001)
private let editCommandShift = CGEventFlags(rawValue:
    CGEventFlags.maskCommand.rawValue | 0x00000008 | CGEventFlags.maskShift.rawValue | 0x00000002
)
private let editControlShift = CGEventFlags(rawValue:
    CGEventFlags.maskControl.rawValue | 0x00000001 | CGEventFlags.maskShift.rawValue | 0x00000002
)
/// Text-edit keys still down, with the steps chosen when each was pressed.
/// Repeats replay those steps: a repeat can carry modifiers bulkey itself is
/// holding mid-sequence, such as Command, and must never reach the app as
/// Command+Q.
private var textEditHeld: [Int64: [EditKey]] = [:]
/// Text-edit keys that repeat while held: S, X, Z, V, W, B, E. The rest fire
/// once per press; their steps hold Command, and repeating them can leave it stuck.
private let repeatableTextEditKeys: Set<Int64> = [1, 7, 6, 9, 13, 11, 14]
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
    case 13 where !shift: // w: Option+Left, then Option+Fn+Backspace (Option+Forward Delete)
        return [EditKey(key: 123, flags: editOption), EditKey(key: 117, flags: editOptionFn)]
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
    let stuckArrows = Array(heldArrow.values)
    capsHeld = false
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
    returnTracking = false
    returnUsed = false
    returnPosted = false
    returnGeneration += 1
    returnPassed.removeAll()
    textEditHeld.removeAll()
    heldArrow.removeAll()
    DispatchQueue.main.async {
        if capsPosted {
            postExtraFlags(hyperFlags, enabled: false)
        }
        for arrow in stuckArrows {
            postHID(type: hidKeyUp, key: UInt16(arrow), flags: 0)
        }
        postHID(type: hidFlagsChanged, key: UInt16(escapeKey), flags: hidFlags(from: currentModifierFlags()))
    }
}

private func engageCapsModifiers(on event: CGEvent?) {
    guard capsHeld else { return }
    capsUsed = true
    if !capsFlagsPosted {
        capsFlagsPosted = true
        DispatchQueue.main.async { postExtraFlags(hyperFlags, enabled: true) }
    }
    event?.flags.formUnion(hyperFlags)
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

private func countTouches(_ touches: UnsafeMutableRawPointer?, count: Int) -> DeviceTouches {
    var result = DeviceTouches(total: 0, topLeft: 0)
    guard let touches, count > 0, count < 16 else { return result }
    let stride = MemoryLayout<MTTouch>.stride
    for index in 0..<count {
        let point = touches.advanced(by: index * stride).load(as: MTTouch.self).normalized.position
        if isIgnoredSide(x: point.x) {
            continue
        }
        result.total += 1
        if isTopLeftQuarter(x: point.x, y: point.y) {
            result.topLeft += 1
        }
    }
    return result
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
    return 0.18
}()

private func postReturn() {
    postTap(returnKey)
}

private let callback: CGEventTapCallBack = { _, type, event, _ in
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tapPort {
            CGEvent.tapEnable(tap: tapPort, enable: true)
        }
        return pass(event)
    }

    var keyCode = event.getIntegerValueField(.keyboardEventKeycode)
    if hidInjecting > 0 || hidEchoKeys.contains(keyCode) {
        if let index = hidEchoKeys.firstIndex(of: keyCode) {
            hidEchoKeys.remove(at: index)
        }
        return pass(event)
    }
    let enterLike = keyCode == returnKey || keyCode == keypadEnter || keyCode == backslashKey
    if keyCode == sectionKey {
        event.setIntegerValueField(.keyboardEventKeycode, value: backslashKey)
        keyCode = backslashKey
    }
    trackPhysicalModifier(type, event, keyCode: keyCode)
    let repeatKey = event.getIntegerValueField(.keyboardEventAutorepeat) != 0
    if keyCode == escapeKey && type == .keyDown && !repeatKey {
        clearAllKeyboardState()
        return pass(event)
    }

    if keyCode == capsKey {
        if type == .keyDown {
            if repeatKey || capsHeld {
                return nil
            }
            capsHeld = true
            capsUsed = false
            capsFlagsPosted = false
            fputs("bulkey: caps down\n", stderr)
            releaseCapsLockIfOn()
            return nil
        }
        if type == .keyUp {
            guard capsHeld else { return pass(event) }
            let used = capsUsed
            let posted = capsFlagsPosted
            capsHeld = false
            capsUsed = false
            capsFlagsPosted = false
            if posted {
                DispatchQueue.main.async { postExtraFlags(hyperFlags, enabled: false) }
            } else if !used {
                DispatchQueue.main.async { postTap(escapeKey) }
            }
            fputs("bulkey: caps up used=\(used)\n", stderr)
            return nil
        }
    }

    if keyCode != capsKey, keyCode != leftCommandKey, keyCode != rightCommandKey, capsHeld, type == .keyDown {
        engageCapsModifiers(on: event)
    }

    if keyCode == leftCommandKey, !(tabPosted || rightShiftPosted) {
        let leftCommandPress = type == .keyDown
            || (type == .flagsChanged && event.flags.contains(.maskCommand))
        if leftCommandPress, tabTracking {
            holdTab(on: nil)
        }
        if leftCommandPress, returnTracking {
            holdReturn(on: nil)
        }
        let otherModifier = !event.flags.intersection([
            .maskShift, .maskControl, .maskAlternate, .maskSecondaryFn,
        ]).isEmpty || (event.flags.rawValue & 0x10) != 0
            || rightCommandTracking || rightShiftTracking || capsHeld
        if !leftCommandTracking && otherModifier {
            if rightCommandTracking {
                holdRightCommand(on: nil)
            }
            if rightShiftTracking {
                holdRightShift(on: nil)
            }
            if capsHeld {
                engageCapsModifiers(on: nil)
            }
            return pass(event)
        }
        if rightCommandTracking {
            holdRightCommand(on: event)
        }
        if rightShiftTracking {
            holdRightShift(on: event)
        }
        if leftCommandLatch {
            return pass(event)
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
                return pass(event)
            }
            return pass(event)
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
            return pass(event)
        }
    }

    if keyCode == rightCommandKey, !(tabPosted || rightShiftPosted) {
        let rightCommandPress = type == .keyDown || (type == .flagsChanged && (event.flags.rawValue & 0x10) != 0)
        if rightCommandPress, tabTracking {
            holdTab(on: nil)
        }
        if rightCommandPress, returnTracking {
            holdReturn(on: nil)
        }
        let otherModifier = !event.flags.intersection([
            .maskShift, .maskControl, .maskAlternate, .maskSecondaryFn,
        ]).isEmpty || (event.flags.rawValue & 0x08) != 0
            || leftCommandTracking || rightShiftTracking || capsHeld
        if !rightCommandTracking && otherModifier {
            if leftCommandTracking {
                holdLeftCommand(on: nil)
            }
            if rightShiftTracking {
                holdRightShift(on: nil)
            }
            if capsHeld {
                engageCapsModifiers(on: nil)
            }
            return pass(event)
        }
        if leftCommandTracking {
            holdLeftCommand(on: event)
        }
        if rightShiftTracking {
            holdRightShift(on: event)
        }
        let rightCommandDown = (event.flags.rawValue & 0x10) != 0
        if rightCommandLatch {
            return pass(event)
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
                return pass(event)
            }
            return pass(event)
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
            return pass(event)
        }
    }

    if leftCommandTracking, !(tabPosted || rightShiftPosted), keyCode != leftCommandKey, type == .keyDown || type == .flagsChanged {
        holdLeftCommand(on: event)
    }

    if rightCommandTracking, !(tabPosted || rightShiftPosted), keyCode != rightCommandKey, type == .keyDown || type == .flagsChanged {
        holdRightCommand(on: event)
    }

    if keyCode == rightShiftKey, rightShiftTracking || !tabPosted {
        let rightShiftPress = type == .keyDown || (type == .flagsChanged && (event.flags.rawValue & 0x4) != 0)
        if rightShiftPress, tabTracking {
            holdTab(on: nil)
        }
        if rightShiftPress, returnTracking {
            holdReturn(on: nil)
        }
        if postingScrollChord || rightCommandLatch || rightShiftLatch {
            return pass(event)
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
                return pass(event)
            }
            return pass(event)
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
            return pass(event)
        }
    }

    if rightShiftTracking, !tabPosted, keyCode != rightShiftKey, type == .keyDown || type == .flagsChanged {
        holdRightShift(on: event)
    }

    if keyCode == tabKey, type == .keyDown || type == .keyUp {
        if type == .keyDown, returnTracking {
            holdReturn(on: event)
        }
        let fingers = touchState().total
        if type == .keyDown {
            if repeatKey || tabTracking {
                return tabTracking ? nil : pass(event)
            }
            if !event.flags.intersection(passModifiers).isEmpty {
                return pass(event)
            }
            if fingers < 2 {
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

    if enterLike, returnTracking || !(tabPosted || rightShiftPosted) {
        if type == .keyDown {
            if returnPassed.contains(keyCode) {
                return pass(event)
            }
            if repeatKey || returnTracking {
                return nil
            }
            if !event.flags.intersection(passModifiers).isEmpty {
                returnPassed.insert(keyCode)
                return pass(event)
            }
            beginReturn()
            return nil
        }
        if type == .keyUp {
            if returnPassed.remove(keyCode) != nil {
                return pass(event)
            }
            if returnTracking {
                endReturn()
            }
            return nil
        }
    }

    if returnTracking, !enterLike, !(tabPosted || rightShiftPosted), type == .keyDown || type == .flagsChanged {
        holdReturn(on: event)
    }

    if type == .keyDown || type == .keyUp, touchState().total == 1 || textEditHeld[keyCode] != nil {
        if type == .keyUp {
            if textEditHeld.removeValue(forKey: keyCode) != nil {
                return nil
            }
        } else if repeatKey, let steps = textEditHeld[keyCode] {
            if !sequenceInFlight && repeatableTextEditKeys.contains(keyCode) {
                postSequence(steps)
            }
            return nil
        } else if !repeatKey, !(tabPosted || rightShiftPosted), touchState().total == 1,
            let steps = textEditSteps(keyCode: keyCode, flags: event.flags) {
            textEditHeld[keyCode] = steps
            fputs("bulkey: text edit \(keyCode)\n", stderr)
            postSequence(steps)
            return nil
        } else {
            textEditHeld.removeValue(forKey: keyCode)
        }
    }

    if (tabPosted || rightShiftPosted),
        type == .keyDown || type == .keyUp,
        !modifierKeyCodes.contains(keyCode) {
        event.flags = tabHoldFlags
        let hidType: UInt32 = type == .keyDown ? hidKeyDown : hidKeyUp
        postHID(type: hidType, key: UInt16(keyCode), flags: hidFlags(from: tabHoldFlags))
        return nil
    }

    if let arrow = arrowByKey[keyCode] {
        let blocked = event.flags.intersection([
            .maskControl, .maskAlternate, .maskCommand, .maskSecondaryFn,
        ])
        if type == .keyDown {
            let freshPress = !repeatKey && heldArrow[keyCode] == nil
            let touches = touchState()
            if freshPress && blocked.isEmpty && touches.topLeft > 0 {
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
    return pass(event)
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
    let counts = countTouches(touches, count: count)
    var sample = ""
    if let touches, count > 0 {
        let touch = touches.load(as: MTTouch.self)
        sample = String(format: " x=%.2f y=%.2f", touch.normalized.position.x, touch.normalized.position.y)
    }
    touchLock.lock()
    touchesByDevice[key] = counts
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
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: callback,
            userInfo: nil
        ) ?? CGEvent.tapCreate(
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
    fputs("bulkey: event tap installed\n", stderr)
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

setCapsLockRemap(true)
fputs("bulkey: listening\n", stderr)
postHID(type: hidFlagsChanged, key: UInt16(leftControlKey), flags: hidFlags(from: currentModifierFlags()))
CFRunLoopRun()
setCapsLockRemap(false)
