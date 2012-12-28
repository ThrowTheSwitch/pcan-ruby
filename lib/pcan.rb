require 'pcan'

class Pcan
  def initialize(hardware)
    @pcan_hardware = hardware
  end

  def setup
  end

  # Convenience method to create a Pcan object and set it up.
  def self.create
    hardware = PcanHardware.new
    pcan = Pcan.new(hardware)
    pcan.setup
    
    return pcan
  end
end