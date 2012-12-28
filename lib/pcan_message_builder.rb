require 'PcanHardware'

module PcanMessageBuilder
  
  def create_bit(name, index)
  
    if(get_data.length == 0)
      raise(IndexError, "no CAN message payload exists")
    elsif((index / 8) >= get_data.length)
      raise(IndexError, "invalid bit index specified")
    end
    
    create_method("#{name}") { get_bit(index) }
    create_method("#{name}=") { |value| set_bit(index, value) }
    
  end
  
  def create_field(name, index, length)
  
    start_byte_offset = index / 8
    end_byte_offset = (index + length - 1) / 8
    
    if(get_data.length == 0)
      raise(IndexError, "no CAN message payload exists")
    elsif(start_byte_offset >= get_data.length)
      raise(IndexError, "invalid field start index specified")
    elsif(end_byte_offset >= get_data.length)
      raise(IndexError, "invalid field start index and length specified")
    end
    
    create_method("#{name}") { get_field(index, length) }
    create_method("#{name}=") { |value| set_field(index, length, value) }    
    
  end
  
  private
  
  def create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end
  
  def get_bit_info(index)
    byte_offset = index / 8
    bit_pos = index % 8
    bit_mask = 0x80 >> bit_pos
    return byte_offset, bit_mask
  end

  def get_bit(index)
    byte_offset, bit_mask = get_bit_info(index)
    return ((get_data[byte_offset] & bit_mask) > 0)
  end
  
  def set_bit(index, value)
    byte_offset, bit_mask = get_bit_info(index)
  
    data = get_data
    
    if(value == true || value == 1)
      data[byte_offset] |= bit_mask
    elsif(value == false || value == 0)
      data[byte_offset] &= ~bit_mask
    else
      raise ArgumentError, "Invalid CAN message bit value specified (true|false)"
    end
    
    set_data(data)
    
    nil
  end
  
  def get_field(index, length)
    
    value = 0
    
    0.upto(length-1) do |i|
      value = value << 1
      value += 1 if(get_bit(index+i))
    end
    
    return value
    
  end
  
  def set_field(index, length, value)
  
    if(value < 0 || value >= (2 ** length))
      raise RangeError, "specified field value is out of range"
    end
    
    0.upto(length-1) do |i|
      bit = (value & (0x01 << (length-1-i))) > 0
      set_bit(index+i, bit)
    end
    
    return nil
    
  end

end
