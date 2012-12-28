require 'PcanHardware'

class SpeedFromVmcNew < PcanMessage

  BIT_AUTO = 0x01
  BIT_DIR = 0x02
  BIT_BRAKE_RELEASE = 0x04
  BIT_COORD_STEER = 0x08
  BIT_LINE_ON = 0x10
  BIT_RESET_STEER_BOARDS = 0x80

  def initialize
	self.extend PcanMessageBuilder
    self.set_id(0x500)
    self.set_type(PcanMessage::MSGTYPE_STANDARD)
    self.set_data([0,0,0])
    self.create_bit("auto", 7)
    self.create_bit("dir", 6)
    self.create_bit("brake_release", 5)
    self.create_bit("coord_steer", 4)
    self.create_bit("line_on", 3)
    self.create_bit("reset_steer_boards", 0)
  end
  
  def to_s
    message =  "auto:#{@auto}"
    message << " dir:#{@dir}"
    message << " brake_release:#{@brake_release}"
    message << " coord_steer:#{@coord_steer}"
    message << " reset_steer_boards:#{@reset_steer_boards}"
    message << " speed:#{@speed}"
  end
  
end
