#ifndef PCAN_MESSAGE_H_
#define PCAN_MESSAGE_H_

extern VALUE rb_cPcanMessage;

void       msg_free(void *p);
VALUE      msg_alloc(VALUE klass);
VALUE      msg_initialize(VALUE self);
VALUE      msg_init_copy(VALUE copy, VALUE orig);
VALUE      msg_new(VALUE class);
VALUE      msg_get_type(VALUE self);
VALUE      msg_set_type(VALUE self, VALUE type);
VALUE      msg_get_id(VALUE self);
VALUE      msg_set_id(VALUE self, VALUE id);
VALUE      msg_get_data(VALUE self);
VALUE      msg_set_data(VALUE self, VALUE data);
VALUE      msg_to_s(VALUE self);
VALUE      msg_to_raw_s(VALUE self);
TPCANMsg * msg_get_pointer(VALUE self);

#endif /*PCAN_MESSAGE_H_*/
