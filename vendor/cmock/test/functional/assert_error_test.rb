require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'cmock'

class AssertErrorTest < Test::Unit::TestCase
	include CMock

	def setup
	end

	def teardown
	end

	#
	# TESTS
	# 

	def test_assert_error
		assert_error RuntimeError, "Too funky" do
			raise RuntimeError.new("Too funky")
		end
	end

	def test_assert_error_message_doesnt_match
		err = assert_raise Test::Unit::AssertionFailedError do
			assert_error RuntimeError, "not good" do
				raise RuntimeError.new("Too funky")
			end
		end
		assert_match(/not good/i, err.message) 
		assert_match(/too funky/i, err.message) 
	end

	def test_assert_error_type_doesnt_match
		err = assert_raise Test::Unit::AssertionFailedError do
			assert_error StandardError, "Too funky" do
				raise RuntimeError.new("Too funky")
			end
		end
		assert_match(/StandardError/i, err.message) 
		assert_match(/RuntimeError/i, err.message) 
	end

	def test_assert_error_regexp_matching 
		assert_error StandardError, /too/i, /funky/i do
			raise StandardError.new("Too funky")
		end
	end

	def test_assert_error_regexp_matching_fails
		err = assert_raise Test::Unit::AssertionFailedError do
			assert_error StandardError, /way/i, /too/i, /funky/i do
				raise StandardError.new("Too funky")
			end
		end
		assert_match(/way/i, err.message) 
	end

	def test_assert_error_no_matchine
		assert_error StandardError do 
		  raise StandardError.new("ooof")
		end
	end

end
