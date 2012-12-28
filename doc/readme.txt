PEAK/Grid-Connect PCAN-USB Ruby Wrapper
===============================================================================
This wrapper provides a Ruby interface to the PCAN-Light API for the PEAK 
PCAN-USB CAN interface supplied by PEAK-System Technik GmbH.


PcanMessage class
-------------------------------------------------------------------------------
Description: This class creates an object that represents a single CAN message 
object.

new() - Creates a new PcanMessage instance

get_type() - Returns the type of the CAN message

set_type(type) - Sets the type of the CAN message to 'type'

- Valid CAN message types are:
  MSGTYPE_STANDARD (default)
  MSGTYPE_STATUS
  MSGTYPE_EXTENDED
  MSGTYPE_RTR

get_id() - Returns the CAN message ID

set_id(value) - Sets the CAN message ID to 'value'

get_data() - Returns the CAN message payload as a byte array up to 8 bytes long.

set_data(data) - Sets the CAN message payload to the specified byte array (up to 8 bytes long)

to_s - Returns a string representation of the CAN message


PcanHardware class
-------------------------------------------------------------------------------
Description: This class provides a connection-based interface to the PCAN-USB
hardware by wrapping the functions provided in the PCAN_USB.dll

new() - Creates a new PcanHardware instance and connects to the PCAN-USB hardware (Defaults to 125kbps and standard message IDs)
new(baud_rate) - Creates a new PcanHardware instance configured at 'baud_rate' and connects to the PCAN-USB hardware (Defaults to standard message IDs)
new(baud_rate, msg_id_type) - Creates a new PcanHardware instance configured at 'baud_rate' and 'msg_id_type' and connects to the PCAN-USB hardware

baud_rate: Valid values are 1000000, 500000, 250000, 125000, 100000, 50000, 20000, 10000 and 5000 bps
msg_id_type: Valid values are ':msg_type_std' and ':msg_type_ext'

close() - Closes connection to the PCAN-USB hardware

get_status_string() - Returns a string representation of the PCAN-USB status
- Valid PCAN status items are:
	XMTFULL
  OVERRUN
  BUSLIGHT
  BUSHEAVY
  BUSOFF
  QRCVEMPTY
  QOVERRUN
  QXMTFULL
  REGTEST
  NOVXD
  RESOURCE
		
get_version_string() - Returns the version string reported from the PCAN-USB hardware

flush_receive_queue() - Flushes all buffered messages from the PCAN-USB receive queue

receive_message(timeout) - Returns the next available message from the PCAN-USB 
    receive queue. Waits up to timeout seconds for the message to arrive.
		
transmit_message(message) - Transmits the specified PcanMessage 'message'


PcanMessageBuilder module
-------------------------------------------------------------------------------
Description: This module contains methods that allow definitions of named
regions within a PcanMessage object's data field. These methods must be
appended to a given PcanMessage object by using the object's 'extend' method.

NOTE: The index value used are interpreted as the ordering of the bits in the
order they tracel across the CAN bus physical interface. (i.e. MSb to LSb)

create_bit(name, index) - Creates a single boolean bit-wide field 'name' at the
		specified bit 'index'.
  
create_field(name, index, length) - Creates a field 'name' starting at the
    specified 'index and 'length' bits long.


		
EXAMPLE USAGE:
-------------------------------------------------------------------------------

require 'PcanHardware'
require 'pcan_message_builder'

pcan = PcanHardware.new(100000, :msg_type_std)
command = PcanMessage.new

command.extend PcanMessageBuilder
command.set_data([0x01, 0x02, 0x03])

command.create_field('Voltage', 8, 4) #create 4-bit long field starting at bit 8

command.Voltage = 5 #=> message data of [0x01, 0x52, 0x03]

pcan.transmit_mesage(command)

response = pcan.receive_message(2.)

response.extend PcanMessageBuilder #e.g. message ID=0x527 & data=0x23
response.create_field('Status', 0, 8)
puts "Status=" + response.Status #=> Status=8
puts response #=> ID:0x527 TYPE:STD LEN:1 DATA:0x23
