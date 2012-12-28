require 'mkmf'

dir_config('pcan')

# have_library('pcan_usb')
# This turd is here because have_library('pcan_usb') is
# insufficient to append the library on a windows computer.
# TODO: fix this?
$libs = append_library($libs, 'pcan_usb')

create_makefile('pcan/PcanHardware', 'lib')
