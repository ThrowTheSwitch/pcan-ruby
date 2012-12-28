#include "ruby.h"
#include <stdio.h>
#include "pcan_usb.h"

VALUE rb_cPcanMessage;

void msg_free(void *p)
{
  free(p);
}

VALUE msg_alloc(VALUE klass)
{
  VALUE obj;
  TPCANMsg * msg;

  msg = ALLOC(TPCANMsg);
  obj = Data_Wrap_Struct(klass, 0, msg_free, msg);

  return obj;
}

VALUE msg_initialize(VALUE self)
{
  TPCANMsg * msg;
  int len;
  
  Data_Get_Struct(self, TPCANMsg, msg);
  MEMZERO(msg, TPCANMsg, 1);

  return self;
}

VALUE msg_init_copy(VALUE copy, VALUE orig)
{
  TPCANMsg *orig_msg, *copy_msg;

  if(copy == orig)
  {
    return copy;
  }

  // Check type
  if(TYPE(orig) != T_DATA || RDATA(orig)->dfree != (RUBY_DATA_FUNC)msg_free)
  {
    rb_raise(rb_eTypeError, "wrong argument type");
  }

  // Copy it
  Data_Get_Struct(orig, TPCANMsg, orig_msg);
  Data_Get_Struct(copy, TPCANMsg, copy_msg);
  MEMCPY(copy_msg, orig_msg, TPCANMsg, 1);

  return copy;
}

VALUE msg_new(VALUE class)
{
  VALUE tdata = msg_alloc(class);
  rb_obj_call_init(tdata, 0, NULL);
  return tdata;
}

VALUE msg_get_type(VALUE self)
{
  VALUE type = Qnil;
  TPCANMsg * msg;

  Data_Get_Struct(self, TPCANMsg, msg);
  switch(msg->MSGTYPE)
  {
  case MSGTYPE_STANDARD:
  case MSGTYPE_STATUS:
  case MSGTYPE_EXTENDED:
  case MSGTYPE_RTR:
    type = UINT2NUM(msg->MSGTYPE);
    break;
  default:
    rb_raise(rb_eArgError, "invalid CAN message type");
    break;
  }

  return type;
}

VALUE msg_set_type(VALUE self, VALUE type)
{
  TPCANMsg * msg;
  int val;

  Data_Get_Struct(self, TPCANMsg, msg);
  val = NUM2INT(type);
  switch(val)
  {
  case MSGTYPE_STANDARD:
  case MSGTYPE_STATUS:
  case MSGTYPE_EXTENDED:
  case MSGTYPE_RTR:
    msg->MSGTYPE = val;
    break;
  default:
    rb_raise(rb_eArgError, "invalid CAN message type");
    break;
  }

  return Qnil;
}

VALUE msg_get_id(VALUE self)
{
  TPCANMsg * msg;
  VALUE id;

  Data_Get_Struct(self, TPCANMsg, msg);
  id = UINT2NUM(msg->ID);

  return id;
}

VALUE msg_set_id(VALUE self, VALUE id)
{
  TPCANMsg * msg;
  int val = NUM2INT(id);

  Data_Get_Struct(self, TPCANMsg, msg);
  
  if(val < 0)
  {
    rb_raise(rb_eArgError, "invalid negative CAN ID value");
  }
  else if(msg->MSGTYPE == MSGTYPE_STANDARD && val > CAN_MAX_STANDARD_ID)
  {
    rb_raise(rb_eArgError, "invalid standard CAN ID value");
  }
  else if(msg->MSGTYPE == MSGTYPE_EXTENDED && val > CAN_MAX_EXTENDED_ID)
  {
    rb_raise(rb_eArgError, "invalid standard CAN ID value");
  }
  
  msg->ID = val;

  return id;
}

VALUE msg_get_data(VALUE self)
{
  int i;
  TPCANMsg * msg;
  VALUE data;

  Data_Get_Struct(self, TPCANMsg, msg);
  data = rb_ary_new();
  for(i = 0; i < msg->LEN; i++)
  {
    rb_ary_push(data, INT2NUM(msg->DATA[i]));
  }

  return data;
}

VALUE msg_set_data(VALUE self, VALUE data)
{
  TPCANMsg * msg;
  int i, len, val;
  VALUE rval;
  
  Check_Type(data, T_ARRAY);
  
  len = RARRAY(data)->len;
  
  if(len < 0 || len > 8)
  {
    rb_raise(rb_eRangeError, "CAN message data can be from 0 to 8 bytes long only");
  }
  
  Data_Get_Struct(self, TPCANMsg, msg);
  for(i = 0; i < len; i++)
  {
    rval = rb_ary_entry(data, i);
    val = NUM2INT(rval);
    if(val < 0 || val > 255)
    {
      rb_raise(rb_eRangeError, "invalid byte value");
    }
    msg->DATA[i] = (unsigned char)val;
  }
  msg->LEN = len;

  return Qnil;
}

VALUE msg_to_s(VALUE self)
{
  int i;
  TPCANMsg * msg;
  char szitem[32];
  char szmsg[128] = "";
  
  Data_Get_Struct(self, TPCANMsg, msg);
  sprintf(szmsg, "ID:0x%03X TYPE:", msg->ID);
  switch(msg->MSGTYPE)
  {
    case MSGTYPE_STANDARD:
      strcat(szmsg, "STD ");
      break;
    case MSGTYPE_STATUS:
      strcat(szmsg, "STA ");
      break;
    case MSGTYPE_EXTENDED:
      strcat(szmsg, "EXT ");
      break;
    case MSGTYPE_RTR:
      strcat(szmsg, "RTR ");
      break;
    default:
      rb_raise(rb_eRangeError, "invalid message type");
      break;
  }
  sprintf(szitem, "LEN:%1d DATA:", msg->LEN);
  strcat(szmsg, szitem);
  for(i = 0; i < msg->LEN; i++)
  {
    sprintf(szitem, "0x%02X", msg->DATA[i]);
    strcat(szmsg, szitem);
    if(i < (msg->LEN - 1))
      strcat(szmsg, ",");
  }
  
  return rb_str_new2(szmsg);
}

VALUE msg_to_raw_s(VALUE self)
{
  int i;
  TPCANMsg * msg;
  unsigned char * ptr;
  const int len = sizeof(TPCANMsg);
  char sval[8] = "";
  char bytes[sizeof(sval)*sizeof(TPCANMsg)] = "";
  
  Data_Get_Struct(self, TPCANMsg, msg);
  ptr = (char*)msg;
  for(i = 0; i < len; i++)
  {
    sprintf(sval, "0x%02X", ptr[i]);
    strcat(bytes, sval);
    if(i < (len-1))
      strcat(bytes, ",");
  }
  
  return rb_str_new2(bytes);
}

TPCANMsg * msg_get_pointer(VALUE self)
{
  TPCANMsg *msg;
  Data_Get_Struct(self, TPCANMsg, msg);
  return msg;
}
