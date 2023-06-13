from configs.path import VM_QT_DIR, VM_STATUS_DESKTOP

LD_LIBRARY_PATH = [
    f'{VM_QT_DIR}/5.15.2/gcc_64/lib',
    f'{VM_STATUS_DESKTOP}/vendor/DOtherSide/build/qzxing/',
    f'{VM_STATUS_DESKTOP}/vendor/status-go/build/bin',
    f'{VM_STATUS_DESKTOP}/vendor/status-keycard-go/build/libkeycard'
]

variables = {'LD_LIBRARY_PATH': ':'.join(LD_LIBRARY_PATH)}
