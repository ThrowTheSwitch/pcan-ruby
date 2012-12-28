require File.expand_path(File.dirname(__FILE__)) + "/../test_helper"
require 'PcanHardware'

class PcanMessageTest < Test::Unit::TestCase

  def setup
    @msg = nil
    assert_nothing_raised {@msg = PcanMessage.new}
  end
  
  def teardown
  end

  should "create CAN message object" do
    assert_not_nil(@msg)
    assert_kind_of(Object, @msg)
    assert_instance_of(PcanMessage, @msg)
  end
  
  should "initialize structure elements to zero" do
    assert_equal 0, @msg.get_id
    assert_equal 0, @msg.get_data.length
    assert_equal PcanMessage::MSGTYPE_STANDARD, @msg.get_type
  end
  
  should "report CAN ID type" do
    type = nil
    assert_nothing_raised  {type = @msg.get_type}
    assert_not_nil(type)
    assert(type == PcanMessage::MSGTYPE_STANDARD || type == PcanMessage::MSGTYPE_STATUS || type == PcanMessage::MSGTYPE_EXTENDED || type == PcanMessage::MSGTYPE_RTR)
  end
  
  should "set CAN ID type" do
    assert_nothing_raised  {@msg.set_type(PcanMessage::MSGTYPE_STANDARD)}
    assert_nothing_raised  {@msg.set_type(PcanMessage::MSGTYPE_STATUS)}
    assert_nothing_raised  {@msg.set_type(PcanMessage::MSGTYPE_EXTENDED)}
    assert_nothing_raised  {@msg.set_type(PcanMessage::MSGTYPE_RTR)}
  end
  
  should "raise exception upon invalid value passed to set_type" do
    assert_raise(ArgumentError) {@msg.set_type(3829)}
  end
  
  should "implement get ID" do
    assert_nothing_raised {@msg.get_id}
  end
  
  should "implement set ID" do
    id_expected = 5
    id_actual = @msg.set_id(id_expected)
    assert_equal id_expected, id_actual
  end
  
  should "return id set with set_id from get_id" do
    id_expected = 17
    @msg.set_id(id_expected)
    id_actual = @msg.get_id
    assert_equal(id_expected, id_actual)
  end

  should "not raise exception upon valid CAN message ID" do
    @msg.set_type(PcanMessage::MSGTYPE_STANDARD)
    assert_nothing_raised {@msg.set_id(0)}
    assert_nothing_raised {@msg.set_id(0x7ff)}
    
    @msg.set_type(PcanMessage::MSGTYPE_EXTENDED)
    assert_nothing_raised {@msg.set_id(0)}
    assert_nothing_raised {@msg.set_id(0x1fffffff)}
  end
  
  should "raise exception upon invalid CAN message ID" do
    @msg.set_type(PcanMessage::MSGTYPE_STANDARD)
    assert_raise(ArgumentError) {@msg.set_id(-1)}
    assert_raise(ArgumentError) {@msg.set_id(0x800)}
    
    @msg.set_type(PcanMessage::MSGTYPE_EXTENDED)
    assert_raise(ArgumentError) {@msg.set_id(-1)}
    assert_raise(ArgumentError) {@msg.set_id(0x20000000)}
  end
  
  should "implement get DATA[]" do
    actual_data = nil
    assert_nothing_raised {actual_data = @msg.get_data}
    assert_not_nil(actual_data)
    assert_instance_of Array, actual_data
  end
  
  should "implement set DATA[]" do
    assert_nothing_raised {@msg.set_data([255])}
    assert_nothing_raised {@msg.set_data([0,1,2,3,4,5,6,7])}
  end
  
  should "raise exception upon invalid message data type (non-array) passed to set_data" do
    assert_raise(TypeError) {@msg.set_data(0)}
    assert_raise(TypeError) {@msg.set_data("Test")}
  end
  
  should "raise exception upon invalid array length being passed to set_data" do
    assert_raise(RangeError) {@msg.set_data([0,1,2,3,4,5,6,7,8])}
  end
  
  should "raise exception upon invalid byte value being passed to set_data" do
    assert_raise(RangeError) {@msg.set_data([-1])}
    assert_raise(RangeError) {@msg.set_data([256])}
    assert_raise(RangeError) {@msg.set_data([0,1,2,3,4,5,6,1000])}
  end
  
  should "return data set with set_data from get_data" do
    expected_data = [10,9,8,7,6]
    @msg.set_data(expected_data)
    assert_equal expected_data, @msg.get_data
  end
  
  should "format structure into a string" do
    @msg.set_id(0x500)
    @msg.set_type(PcanMessage::MSGTYPE_EXTENDED)
    @msg.set_data([0,1,2,3,4,5])
    assert_equal "ID:0x500 TYPE:EXT LEN:6 DATA:0x00,0x01,0x02,0x03,0x04,0x05", @msg.to_s
  end
  
  should "format structure into a string as raw hex byte values" do
    @msg.set_id(0x123)
    @msg.set_type(PcanMessage::MSGTYPE_STANDARD)
    @msg.set_data([0x11,0x22,0x33,0x44])
    #structure output always contains all 8 bytes of message payload and 2 pad bytes to pad to word boundary
    assert_equal "0x23,0x01,0x00,0x00,0x00,0x04,0x11,0x22,0x33,0x44,0x00,0x00,0x00,0x00,0x00,0x00", @msg.to_raw_s
  end
  
end
