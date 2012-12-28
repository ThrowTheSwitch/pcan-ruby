require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'cmock'

class ExpectationBuilderTest < Test::Unit::TestCase
	include CMock
	
  def test_build_expectation
		builder = ExpectationBuilder.new
		
		ex = builder.build_expectation( :stuff => 'inside' )
		assert_not_nil ex, "Didn't build an expectation"
		assert_kind_of SimpleExpectation, ex, "Wrong type!"

		# Shhhh... fragile, yes, whatever.  The functional tests do the 
		# real testing of this anyway
		assert_equal({:stuff => 'inside'}, ex.instance_variable_get('@options'), "Hash not sent to SimpleExpectation constructor")
  end

end
