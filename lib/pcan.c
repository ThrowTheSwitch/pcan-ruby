#include "ruby.h"
#include <stdio.h>
#include "pcan_usb.h"
#include "pcan_message.h"
#include "pcan_hardware.h"

void Init_PcanHardware(void)
{
  // Create PcanMessage class and define its methods
  rb_cPcanMessage = rb_define_class("PcanMessage", rb_cObject);
  rb_define_alloc_func(rb_cPcanMessage, msg_alloc);
  rb_define_singleton_method(rb_cPcanMessage, "new", msg_new, 0);
  rb_define_method(rb_cPcanMessage, "initialize", msg_initialize, 0);
  rb_define_method(rb_cPcanMessage, "get_type", msg_get_type, 0);
  rb_define_method(rb_cPcanMessage, "set_type", msg_set_type, 1);
  rb_define_method(rb_cPcanMessage, "get_id", msg_get_id, 0);
  rb_define_method(rb_cPcanMessage, "set_id", msg_set_id, 1);
  rb_define_method(rb_cPcanMessage, "get_data", msg_get_data, 0);
  rb_define_method(rb_cPcanMessage, "set_data", msg_set_data, 1);
  rb_define_method(rb_cPcanMessage, "to_s", msg_to_s, 0);
  rb_define_method(rb_cPcanMessage, "to_raw_s", msg_to_raw_s, 0);
  rb_define_const(rb_cPcanMessage, "MSGTYPE_STANDARD", INT2NUM(MSGTYPE_STANDARD));
  rb_define_const(rb_cPcanMessage, "MSGTYPE_STATUS", INT2NUM(MSGTYPE_STATUS));
  rb_define_const(rb_cPcanMessage, "MSGTYPE_EXTENDED", INT2NUM(MSGTYPE_EXTENDED));
  rb_define_const(rb_cPcanMessage, "MSGTYPE_RTR", INT2NUM(MSGTYPE_RTR));

  // Create PcanHardware class and define its methods
  rb_cPcanHardware = rb_define_class("PcanHardware", rb_cObject);
  rb_define_method(rb_cPcanHardware, "initialize", hw_initialize, -1);
  rb_define_method(rb_cPcanHardware, "close", hw_close, 0);
  rb_define_method(rb_cPcanHardware, "get_status_string", hw_get_status_string, 0);
  rb_define_method(rb_cPcanHardware, "get_version_string", hw_get_version_string, 0);
  rb_define_method(rb_cPcanHardware, "transmit_message", hw_transmit_message, 1);
  rb_define_method(rb_cPcanHardware, "flush_receive_queue", hw_flush_receive_queue, 0);
  rb_define_method(rb_cPcanHardware, "receive_message", hw_receive_message, 1);
}
