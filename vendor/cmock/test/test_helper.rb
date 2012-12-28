here = File.expand_path(File.dirname(__FILE__))
$: << here

require "#{here}/../config/environment"
require 'test/unit'
require 'fileutils'
require 'logger'
require 'find'
require 'yaml'
require 'set'
require 'ostruct'

class Test::Unit::TestCase
  include FileUtils

  def poll(time_limit) 
    (time_limit * 10).to_i.times do 
      return true if yield
      sleep 0.1
    end
    return false
  end
end
