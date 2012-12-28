require File.expand_path(File.dirname(__FILE__)) + "/../test_helper"
require 'pcan_message_builder'

class PcanMessageBuilderTest < Test::Unit::TestCase

  def setup
    @msg = PcanMessage.new.extend PcanMessageBuilder
  end
  
  def teardown
  end
  
  should "create CAN message object" do
    assert_instance_of(PcanMessage, @msg)
  end
  
  should "derive from CanMessage" do
    assert_kind_of(PcanMessage, @msg)
  end
  
  should "create zero length message with all fields initialized to zero as default" do
    assert_equal 0, @msg.get_id
    assert_equal 0, @msg.get_data.length
    assert_equal PcanMessage::MSGTYPE_STANDARD, @msg.get_type
  end
  
  should "have method to create custom bit accessors" do
    assert(@msg.respond_to?(:create_bit, false))
  end
  
  should "throw exception when trying to define bit before specifying length" do
    assert_raise(IndexError) {@msg.create_bit("test_bit", 0)}
  end
  
  should "throw exception when trying to define bit outside of payload bounds" do
    @msg.set_data([0,0])
    assert_raise(IndexError) {@msg.create_bit("test_bit", 16)}
  end
  
  should "not throw exception when bit defined within message payload" do
    @msg.set_data([0,0])
    assert_nothing_raised {@msg.create_bit("test_bit", 12)}
  end
  
  should "create custom bit accessor methods" do
    @msg.set_data([0,0])
    @msg.create_bit("test_bit", 12)
    assert(@msg.respond_to?(:test_bit, false), "test_bit() method does not exist")
    assert(@msg.respond_to?(:test_bit=, false), "test_bit() method does not exist")
  end
  
  should "get and set bit defined by custom bit definition for bit zero" do
    @msg.set_data([0,0,0])
    @msg.create_bit("test_bit", 0)
    @msg.test_bit = true
    assert_equal([0x80,0x00,0x00], @msg.get_data)
    @msg.test_bit = false
    assert_equal([0x00,0x00,0x00], @msg.get_data)
  end

  should "get and set bit defined by custom bit definition for other bits" do
    @msg.set_data([0,0,0])
    @msg.create_bit("test_bit2", 12)
    @msg.test_bit2 = true
    assert_equal([0x00,0x08,0x00], @msg.get_data)
    @msg.test_bit2 = false
    assert_equal([0x00,0x00,0x00], @msg.get_data)

    @msg.create_bit("test_bit3", 16)
    @msg.test_bit3 = true
    assert_equal([0x00,0x00,0x80], @msg.get_data)
    @msg.test_bit3 = false
    assert_equal([0x00,0x00,0x00], @msg.get_data)
  end
  
  should "accept 0/1 for bit value but report true/false" do
    @msg.set_data([0,0,0])
    assert_nothing_raised {@msg.create_bit("test_bit", 12)}
    @msg.test_bit = 1
    assert_equal(true, @msg.test_bit)
    @msg.test_bit = 0
    assert_equal(false, @msg.test_bit)
  end
  
  should "raise exception upon invalid value being specified for custom bit" do
    @msg.set_data([0,0])
    @msg.create_bit("test_bit", 4)
    assert_raise(ArgumentError) {@msg.test_bit = 2}
  end
  
  should "have method to create custom field accessors" do
    assert(@msg.respond_to?(:create_field, false))
  end
  
  should "throw exception when trying to define field before specifying length" do
    assert_raise(IndexError) {@msg.create_field("test_field", 0, 4)}
  end
  
  should "throw exception when trying to define field starting outside of payload bounds" do
    @msg.set_data([0,0])
    assert_raise(IndexError) {@msg.create_field("test_field", 16, 4)}
  end
  
  should "not throw exception when defining a field starting and ending within payload bounds" do
    @msg.set_data([0,0])
    assert_nothing_raised {@msg.create_field("test_field", 12, 4)}
  end
  
  should "throw exception when trying to define field starting in message payload but extending beyond" do
    @msg.set_data([0,0])
    assert_raise(IndexError) {@msg.create_field("test_field", 13, 4)}
  end
  
  should "create custom field accessor methods" do
    @msg.set_data([0,0])
    @msg.create_field("test_field", 12, 4)
    assert(@msg.respond_to?(:test_field, false), "test_field() method does not exist")
    assert(@msg.respond_to?(:test_field=, false), "test_field() method does not exist")
  end
  
  should "get custom field contents from payload appropriately when passed valid index" do
    @msg.set_data([0x00,0x55])
    @msg.create_field("test_field", 12, 4)
    assert_equal(0x05, @msg.test_field)
  end
  
  should "set custom field contents in payload appropriately when passed valid value" do
    @msg.set_data([0,0])
    @msg.create_field("test_field", 12, 4)
    assert_equal([0,0], @msg.get_data)
    assert_nothing_raised {@msg.test_field = 0x0F}
    assert_equal([0x00,0x0F], @msg.get_data)
  end
  
  should "report field set with custom accessor as assigned" do
    @msg.set_data([0,0])
    @msg.create_field("test_field", 12, 4)
    assert_nothing_raised {@msg.test_field = 0x0A}
    assert_nothing_raised {result = @msg.test_field}
    assert_equal(0x0A, @msg.test_field)
  end
  
  should "support field overlapping byte boundary" do
    @msg.set_data([0,0])
    @msg.create_field("test_field", 4, 6)
    assert_nothing_raised {@msg.test_field = 0x2A}
    assert_nothing_raised {result = @msg.test_field}
    assert_equal(0x2A, @msg.test_field)
    assert_equal([0xA,0x80], @msg.get_data)
  end

end
