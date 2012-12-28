require File.expand_path(File.dirname(__FILE__)) + "/../config/environment"
require 'test/unit'
require 'behaviors'
require 'cmock'

class Test::Unit::TestCase
	extend Behaviors
  include CMock
end
