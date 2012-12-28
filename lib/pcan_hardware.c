#include "ruby.h"
#include <stdio.h>
#include "pcan_usb.h"
#include "pcan_message.h"

VALUE rb_cPcanHardware;

VALUE hw_initialize(int argc, VALUE* argv)
{
  VALUE baud, id_type;
  DWORD status = CAN_ERR_OK;
  WORD baudreg;
  int msg_type;

  rb_scan_args(argc, argv, "02", &baud, &id_type);

  if(NIL_P(baud))
  {
    baudreg = 125000;
  }
  else
  {
    switch (NUM2INT(baud))
    {
    case 1000000:
      baudreg = CAN_BAUD_1M;
      break;
    case 500000:
      baudreg = CAN_BAUD_500K;
      break;
    case 250000:
      baudreg = CAN_BAUD_250K;
      break;
    case 125000:
      baudreg = CAN_BAUD_125K;
      break;
    case 100000:
      baudreg = CAN_BAUD_100K;
      break;
    case 50000:
      baudreg = CAN_BAUD_50K;
      break;
    case 20000:
      baudreg = CAN_BAUD_20K;
      break;
    case 10000:
      baudreg = CAN_BAUD_10K;
      break;
    case 5000:
      baudreg = CAN_BAUD_5K;
      break;
    default:
      rb_raise(rb_eLoadError, "invalid baud rate specified for PCAN hardware");
    }
  }
  
  if ((NIL_P(id_type)) || (SYM2ID(id_type) == rb_intern("msg_type_std")) || (NUM2INT(id_type) == CAN_INIT_TYPE_ST))
    msg_type = CAN_INIT_TYPE_ST;
  else if ((SYM2ID(id_type) == rb_intern("msg_type_ext")) || (NUM2INT(id_type) == CAN_INIT_TYPE_ST))
    msg_type = CAN_INIT_TYPE_EX;
  else
    rb_raise(rb_eLoadError, "invalid CAN ID type specified for PCAN hardware");
  
  status = CAN_Init(baudreg, msg_type);
  
  if(status != CAN_ERR_OK)
    rb_raise(rb_eLoadError, "unable to configure PCAN hardware");
  
  return Qnil;
}

VALUE hw_close(VALUE self)
{
  DWORD status = CAN_ERR_OK;
  
  sleep(0.5);
  status = CAN_Close();
  
  if(status != CAN_ERR_OK)
    rb_raise(rb_eIOError, "unable to close connection to PCAN hardware");
  
  return Qnil;
}

#define IS_ERROR_SET(status, mask) (((status & mask) == mask) ? TRUE : FALSE)

VALUE hw_get_status_string(VALUE self)
{
  DWORD status = CAN_ERR_OK;
  char details[256] = "";
  
  status = CAN_Status();
  
  if (status == CAN_ERR_OK)
    return rb_str_new2("OK");
  
  if (IS_ERROR_SET(status, CAN_ERR_XMTFULL))
    strcat(details, "XMTFULL ");
  if (IS_ERROR_SET(status, CAN_ERR_OVERRUN))
    strcat(details, "OVERRUN ");
  if (IS_ERROR_SET(status, CAN_ERR_BUSLIGHT))
    strcat(details, "BUSLIGHT ");
  if (IS_ERROR_SET(status, CAN_ERR_BUSHEAVY))
    strcat(details, "BUSHEAVY ");
  if (IS_ERROR_SET(status, CAN_ERR_BUSOFF))
    strcat(details, "BUSOFF ");
  if (IS_ERROR_SET(status, CAN_ERR_QRCVEMPTY))
    strcat(details, "QRCVEMPTY ");
  if (IS_ERROR_SET(status, CAN_ERR_QOVERRUN))
    strcat(details, "QOVERRUN ");
  if (IS_ERROR_SET(status, CAN_ERR_QXMTFULL))
    strcat(details, "QXMTFULL ");
  if (IS_ERROR_SET(status, CAN_ERR_REGTEST))
    strcat(details, "REGTEST ");
  if (IS_ERROR_SET(status, CAN_ERR_NOVXD))
    strcat(details, "NOVXD ");
  if (IS_ERROR_SET(status, CAN_ERR_RESOURCE))
    strcat(details, "RESOURCE ");
  
  details[strlen(details)-1] = '\0';
  
  return rb_str_new2(details);
}

VALUE collect_error_hash(int error)
{
  VALUE result = rb_hash_new();

  if (error)
    rb_hash_aset(result, ID2SYM(rb_intern("error")), INT2NUM(error));

  return result;
}

VALUE collect_error_and_value_hash(int error, VALUE the_value)
{
  VALUE result = rb_hash_new();

  if (error)
    rb_hash_aset(result, ID2SYM(rb_intern("error")), INT2NUM(error));
  else
    rb_hash_aset(result, ID2SYM(rb_intern("value")), the_value);

  return result;
}

// Public functions.

VALUE hw_get_version_string(VALUE self)
{
  DWORD error = CAN_ERR_OK;
  char message[256];

  error = CAN_VersionInfo(message);
  
  if (error)
    return collect_error_hash(error);

  return rb_str_new2(message);
}

VALUE hw_transmit_message(VALUE self, VALUE message)
{
  int error = CAN_ERR_OK, i;
  
  // Check message type
  if (!rb_obj_is_instance_of(message, rb_cPcanMessage))
    rb_raise(rb_eTypeError, "type is not PcanMessage");
  
  // Send the contructed CAN message
  error = CAN_Write(msg_get_pointer(message));
  if (error)
    return collect_error_hash(error);

  return Qnil;
}

VALUE hw_flush_receive_queue(VALUE self)
{
  TPCANMsg msg_struct;
  while(CAN_Read(&msg_struct) == CAN_ERR_OK){}
  return Qnil;
}

VALUE hw_receive_message(VALUE self, VALUE timeout)
{
  int error = CAN_ERR_OK;
  float ftimeout, fdelay = 0.05f, felapsed;
  TPCANMsg * msg_struct;
  VALUE message = Qnil;

  message = rb_class_new_instance(0, 0, rb_cPcanMessage);
  msg_struct = msg_get_pointer(message);

  if(timeout == Qnil)
  {
    // Check for a received CAN message
    error = CAN_Read(msg_struct);
  }
  else
  {
    // Check message type
    if(TYPE(timeout) != T_FIXNUM && TYPE(timeout) != T_FLOAT)
      rb_raise(rb_eTypeError, "type is not PcanMessage");
    
    ftimeout = (float)NUM2DBL(timeout);
    
    for(felapsed = 0.0f; felapsed < ftimeout; felapsed += fdelay)
    {
      sleep(fdelay);
      
      // Check for a received CAN message
      error = CAN_Read(msg_struct);
      
      if(error != CAN_ERR_QRCVEMPTY)
        break;
    }
  }

  if(error)
    return collect_error_hash(error);

  return message;
}
