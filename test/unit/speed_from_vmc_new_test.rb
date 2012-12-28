require File.expand_path(File.dirname(__FILE__)) + "/../test_helper"
require File.expand_path(File.dirname(__FILE__)) + "/speed_from_vmc_new"

class SpeedFromVmcNewTest < Test::Unit::TestCase

  def setup
    @msg = SpeedFromVmcNew.new
  end
  
  def teardown
  end    
  
  should "initialize all values appropriately" do
    assert_equal 0x500, @msg.get_id
    assert_equal 3, @msg.get_data.length
    assert_equal [0,0,0], @msg.get_data
    assert_equal PcanMessage::MSGTYPE_STANDARD, @msg.get_type
  end
  
  should "report formatted message" do
    assert @msg.respond_to?(:to_s)
  end
  
  should "implement data bit field" do
    @msg.auto = true
    assert_equal [SpeedFromVmcNew::BIT_AUTO,0x00,0x00], @msg.get_data
    assert_equal true, @msg.auto
    @msg.auto = false
    assert_equal [0x00,0x00,0x00], @msg.get_data
    assert_equal false, @msg.auto
  end
  
  should "implement dir bit field" do
    @msg.dir = true
    assert_equal [SpeedFromVmcNew::BIT_DIR,0x00,0x00], @msg.get_data
    assert_equal true, @msg.dir
    @msg.dir = false
    assert_equal [0x00,0x00,0x00], @msg.get_data
    assert_equal false, @msg.dir
  end
  
end
