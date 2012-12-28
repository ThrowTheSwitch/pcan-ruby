require File.expand_path(File.dirname(__FILE__)) + "/../test_helper"
require 'PcanHardware'

class PcanHardwareTest < Test::Unit::TestCase

  def setup
    @hw = nil
    assert_nothing_raised {@hw = PcanHardware.new}
  end
  
  def teardown
    @hw.close
  end

  should "create class instance with defualt settings" do
    @hw = nil
    assert_nothing_raised {@hw = PcanHardware.new}
    assert_not_nil(@hw)
    assert_kind_of(Object, @hw)
  end
  
  should "create class instance with specified baud rate" do
    @hw = nil
    assert_nothing_raised {@hw = PcanHardware.new(500000)}
    assert_not_nil(@hw)
    assert_kind_of(Object, @hw)
	
    @hw = nil
    assert_nothing_raised {@hw = PcanHardware.new(10000)}
    assert_not_nil(@hw)
    assert_kind_of(Object, @hw)
  end
  
  should "create class instance with specified baud rate and message id type" do
    @hw = nil
    assert_nothing_raised {@hw = PcanHardware.new(250000, :msg_type_std)}
    assert_not_nil(@hw)
    assert_kind_of(Object, @hw)
	
    @hw = nil
    assert_nothing_raised {@hw = PcanHardware.new(5000, :msg_type_ext)}
    assert_not_nil(@hw)
    assert_kind_of(Object, @hw)
  end
  
  should "report version information" do
    info = @hw.get_version_string
    assert_not_nil info
    assert info.length > 0
    assert_match(
    /^PCAN_USB 2\.48\.\d+\.0 \n\(WDM version\) \nCopyright \(C\) 1995-200[5-7] by\nPEAK-System Technik GmbH, Darmstadt\nFirmware-Version: 2\.8$/,
    info)
  end
  
  should "send CAN message" do
    msg = PcanMessage.new
    msg.set_id 0x503
    msg.set_type PcanMessage::MSGTYPE_STANDARD;
    msg.set_data [0xA2,0x31,0x72]
    result = @hw.transmit_message msg
    if(result != nil)
      flunk sprintf("Error 0x%04X returned when sending CAN message", result[:error])
    end
  end
  
  should "receive CAN message" do
    result = @hw.receive_message(5.0)
    assert_not_nil result
    if(result.instance_of? PcanMessage)
      assert "ID:0x500 TYPE:STD LEN:3 DATA:0x01,0x02,0x03", result.to_s
    elsif(result.instance_of? Hash)
      flunk(sprintf("Error 0x%04X returned when waiting for CAN message", result[:error]))
    else
      flunk "Invalid type returned from receive_message"
    end
  end
  
  should "raise exception when trying to send non-PcanMessage object" do
    error_hash = nil
    assert_raise(TypeError) {error_hash = @hw.transmit_message [2,3,4]}
  end

end