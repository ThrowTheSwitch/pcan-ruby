require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'cmock'

class ExpectorTest < Test::Unit::TestCase
	include CMock

	class MyControl
		attr_reader :added
		def add_expectation(expectation)
			@added ||= []
			@added << expectation
		end
	end

	class ExpBuilder
		attr_reader :options
		def build_expectation(options)
			@options = options
			"dummy expectation"
		end
	end

	#
	# TESTS
	#

  def test_method_missing
		mock = Object.new
		mock_control = MyControl.new
		builder = ExpBuilder.new

		exp = Expector.new(mock, mock_control, builder)
    output = exp.wonder_bread(:with, 1, 'sauce')

		assert_same mock, builder.options[:mock]
		assert_equal :wonder_bread, builder.options[:method]
		assert_equal [:with,1,'sauce'], builder.options[:arguments]
		assert_nil builder.options[:block]
		assert_equal [ "dummy expectation" ], mock_control.added,
		  "Wrong expectation added to control"

		assert_equal "dummy expectation", output, "Expectation should have been returned"
  end


end
