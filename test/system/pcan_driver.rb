require 'systir'
require 'PcanHardware'

class PcanDriver < Systir::LanguageDriver

  def setup
    @pcan = PcanHardware.new
  end
  
  def teardown
    @pcan.close
  end

  def check_pcan_version_report
    info = @pcan.get_version_string
    assert_not_nil info
    assert info.length > 0
    assert_match(
      /^PCAN_USB 2\.48\.\d+\.0 \n\(WDM version\) \nCopyright \(C\) 1995-200[5-7] by\nPEAK-System Technik GmbH, Darmstadt\nFirmware-Version: 2\.8$/,
      info)
  end
  
  def pcan_send_sample_message(id,payload)
    msg = PcanMessage.new
    msg.set_id(id)
    msg.set_type(PcanMessage::MSGTYPE_STANDARD)
    msg.set_data(payload)
    result = @pcan.transmit_message(msg)
    flunk sprintf("Error 0x%04X returned when sending CAN message", result[:error]) unless result.nil?
  end
  
  def pcan_receive_sample_message(id,payload)
    result = @pcan.receive_message(5.0)
    assert_not_nil result
    if(result.instance_of? PcanMessage)
      assert_equal(PcanMessage::MSGTYPE_STANDARD, result.get_type)
      assert_equal(id, result.get_id)
      assert_equal(payload, result.get_data)
    elsif(result.instance_of? Hash)
      flunk(sprintf("Error 0x%04X returned when waiting for CAN message", result[:error]))
    else
      flunk "Invalid object type returned from receive_message"
    end
  end
end
