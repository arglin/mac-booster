#include <IOKit/hidsystem/IOHIDLib.h>
#include <IOKit/hidsystem/IOHIDShared.h>
#include <mach/mach.h>
#include <string.h>

static io_connect_t connect;

int bulkey_hid_post(unsigned int type, unsigned short key, unsigned int flags) {
    if (!connect) {
        io_service_t service = IOServiceGetMatchingService(
            kIOMainPortDefault, IOServiceMatching(kIOHIDSystemClass));
        if (!service) {
            return 1;
        }
        kern_return_t opened = IOServiceOpen(service, mach_task_self(), kIOHIDParamConnectType, &connect);
        IOObjectRelease(service);
        if (opened != KERN_SUCCESS) {
            connect = 0;
            return opened;
        }
    }
    NXEventData data;
    memset(&data, 0, sizeof(data));
    data.key.keyCode = key;
    IOGPoint location = {0, 0};
    return IOHIDPostEvent(
        connect, type, location, &data, kNXEventDataVersion, flags, kIOHIDSetGlobalEventFlags);
}
