#ifndef PCAN_HARDWARE_H_
#define PCAN_HARDWARE_H_

extern VALUE rb_cPcanHardware;

//VALUE hw_initialize(VALUE self, VALUE baud, VALUE id_type);
VALUE hw_initialize(int argc, VALUE* argv);
VALUE hw_close(VALUE self);
VALUE hw_get_status_string(VALUE self);
VALUE hw_get_version_string(VALUE self);
VALUE hw_transmit_message(VALUE self, VALUE message);
VALUE hw_flush_receive_queue(VALUE self);
VALUE hw_receive_message(VALUE self);

#endif /*PCAN_HARDWARE_H_*/
