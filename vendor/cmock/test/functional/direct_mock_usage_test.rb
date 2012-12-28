require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'cmock'

class DirectMockUsageTest < Test::Unit::TestCase
  include CMock

  def setup
    @bird = Mock.new('bird')
  end

  def teardown
  end

  #
  # TESTS
  #

  def test_verify_should_raise_verify_error_if_expected_method_not_called
    @bird.expect.flap_flap

    err = assert_raise VerifyError do
      @bird._verify
    end
    assert_match(/unmet expectations/i, err.message)
  end

  def test_verify_should_not_raise_when_expected_calls_made_in_order
    @bird.expect.flap_flap
    @bird.expect.bang
    @bird.expect.plop

    @bird.flap_flap
    @bird.bang
    @bird.plop

    @bird._verify
  end

  def test_should_raise_expectation_error_when_unexpected_method_called
    @bird.expect.flap_flap

    err = assert_raise ExpectationError do
      @bird.shoot
    end
    assert_match(/wrong method/i, err.message) 
  end

  def test_bad_argument_call
    @bird.expect.flap_flap(:swoosh)

    err = assert_raise ExpectationError do
      @bird.flap_flap(:rip)
    end
    assert_match(/wrong arguments/i, err.message) 
  end
  
  def test_verify_should_raise_verify_error_when_not_all_expected_methods_called
    @bird.expect.flap_flap
    @bird.expect.bang
    @bird.expect.plop

    @bird.flap_flap

    err = assert_raise VerifyError do
      @bird._verify
    end
    assert_match(/unmet expectations/i, err.message)
  end

  def test_should_raise_expectation_error_when_calls_made_out_of_order
    @bird.expect.flap_flap
    @bird.expect.bang
    @bird.expect.plop

    @bird.flap_flap
    err = assert_raise ExpectationError do
      @bird.plop
    end
    assert_match(/wrong method/i, err.message) 
  end

  def test_should_return_given_value_when_specified
    @bird.expect.plop.returns(':P')
    assert_equal ':P', @bird.plop
    @bird._verify

    @bird.expect.plop.returns(':x')
    assert_equal ':x', @bird.plop
    @bird._verify
  end

  def test_should_return_nil_value_when_none_specified
    @bird.expect.plop
    assert_nil @bird.plop
    @bird._verify
  end

  def test_raise_should_raise_given_exception_when_specified
    err = RuntimeError.new('shaq')
    @bird.expect.plop.raises(err)
    actual_err = assert_raise RuntimeError do
      @bird.plop
    end
    assert_same err, actual_err, 'should be the same error'
    @bird._verify
  end

  def test_raise_should_raise_given_string_wrapped_in_runtime_error
    @bird.expect.plop.raises('shaq')
    err = assert_raise RuntimeError do
      @bird.plop
    end
    assert_match(/shaq/i, err.message) 
    @bird._verify
  end

  def test_raise_should_raise_a_canned_runtime_error_if_nothing_given
    @bird.expect.plop.raises
    err = assert_raise RuntimeError do
      @bird.plop
    end
    assert_match(/error/i, err.message) 
    @bird._verify
  end

  def test_should_be_happy_with_correct_expected_arguments
    thing = Object.new
    @bird.expect.plop(:big,'one',thing)
    @bird.plop(:big,'one',thing)
    @bird._verify
  end

  def test_should_raise_expectation_error_when_wrong_number_of_arguemnts_specified
    thing = Object.new
    @bird.expect.plop(:big,'one',thing)
    err = assert_raise ExpectationError do
			# more
      @bird.plop(:big,'one',thing,:other)
    end
    assert_match(/wrong arguments/i, err.message)
    @bird._verify

    @bird.expect.plop(:big,'one',thing)
    err = assert_raise ExpectationError do
			# less
      @bird.plop(:big,'one')
    end
    assert_match(/wrong arguments/i, err.message)
    @bird._verify
		
    @bird.expect.plop
    err = assert_raise ExpectationError do
			# less
      @bird.plop(:big)
    end
    assert_match(/wrong arguments/i, err.message)
    @bird._verify
  end

  def test_should_raise_expectation_error_when_arguemnts_dont_match
    thing = Object.new
    @bird.expect.plop(:big,'one',thing)
    err = assert_raise ExpectationError do
      @bird.plop(:big,'two',thing,:other)
    end
    assert_match(/wrong arguments/i, err.message)
    @bird._verify
  end

  def test_should_yield_to_block_given
    mitt = nil
		@bird.expect.plop { mitt = :ball }
		assert_nil mitt
		@bird.plop
		assert_equal :ball, mitt, 'didnt catch the ball'
		@bird._verify

		@bird.expect.plop { raise 'ball' }
		err = assert_raise RuntimeError do
			@bird.plop
		end
		assert_match(/ball/i, err.message) 
		@bird._verify
  end

  def test_shouldnt_care_about_arguments_if_block_given
		ball = nil
		mitt = nil
		@bird.expect.plop {|arg1,arg2| 
			ball = arg1	
			mitt = arg2	
		}
		assert_nil ball
		assert_nil mitt
		@bird.plop(:ball,:mitt)
		assert_equal :ball, ball
		assert_equal :mitt, mitt
		@bird._verify
  end

  def test_should_check_arguments_if_specified_when_block_given
		ball = nil
		mitt = nil
		@bird.expect.plop(:ball,:mitt) {|arg1,arg2| 
			ball = arg1	
			mitt = arg2	
		}
		assert_nil ball
		assert_nil mitt
		@bird.plop(:ball,:mitt)
		assert_equal :ball, ball
		assert_equal :mitt, mitt
		@bird._verify

		ball = nil
		mitt = nil
		@bird.expect.plop(:bad,:stupid) {|arg1,arg2| 
			ball = arg1	
			mitt = arg2	
		}
		assert_nil ball
		assert_nil mitt
		err = assert_raise ExpectationError do
			@bird.plop(:ball,:mitt)
		end
		assert_match(/wrong arguments/i, err.message) 
		assert_nil ball
		assert_nil mitt
		@bird._verify

		ball = nil
		mitt = nil
		@bird.expect.plop(:ball,:mitt) {|arg1,arg2| 
			ball = arg1	
			mitt = arg2	
		}
		assert_nil ball
		assert_nil mitt
		err = assert_raise ExpectationError do
			@bird.plop(:ball)
		end
		assert_match(/wrong arguments/i, err.message) 
		assert_nil ball
		assert_nil mitt
		@bird._verify
  end

	def test_runtime_blocks_get_passed_to_expectation_blocks
		runtime_block_called = false
		got_arg = nil

		# Eg, bird expects someone to subscribe to :tweet using the 'when' method
		@bird.expect.when(:tweet) { |arg1, block| 
			got_arg = arg1
			block.call
		}

		@bird.when(:tweet) do 
		  runtime_block_called = true
		end

		assert_equal :tweet, got_arg, "Wrong arg"
		assert runtime_block_called, "The runtime block should have been invoked by the user block"

		@bird.expect.when(:warnk) { |e,blk| }

		err = assert_raise ExpectationError do
			@bird.when(:honk) { }
		end
		assert_match(/wrong arguments/i, err.message) 

		@bird._verify
	end

	def test_runtime_blocks_get_passed_to_expectation_blocks__no_arguments
		runtime_block_called = false
		@bird.expect.subscribe { |block| block.call }
		@bird.subscribe do 
		  runtime_block_called = true
		end
		assert runtime_block_called, "The runtime block should have been invoked by the user block"
	end

	def test_expect_runtime_block_but_none_sent
		invoked = false
		@bird.expect.kablam(:scatter) { |shot,block| 
			assert_equal :scatter, shot, "Wrong shot"
			assert_nil block, "The expectation block should get a nil block when user neglects to pass one"
			invoked = true
		}
		@bird.kablam :scatter
		assert invoked, "Expectation block not invoked"

		@bird._verify
	end

	def test_can_set_return_after_blocks
		got = nil
		@bird.expect.kablam(:scatter) { |shot|
			got = shot
		}.returns(:death)

		val = @bird.kablam :scatter 
		assert_equal :death, val, "Wrong return value"
		assert_equal :scatter, got, "Wrong argument"
		@bird._verify
	end

	def test_can_set_raises_after_blocks
		got = nil
		@bird.expect.kablam(:scatter) do |shot|
			got = shot
		end.raises "hell"

		err = assert_raise RuntimeError do
			@bird.kablam :scatter 
		end
		assert_match(/hell/i, err.message) 

		@bird._verify
	end

	def test_expectation_block_value_is_captured
		expectation = @bird.expect.kablam(:slug) { |shot|
			"The shot was #{shot}"
		}

		assert_not_nil expectation, "Expectation nil"
    assert_nil expectation.block_value, "Block value should start out nil"

		ret_val = @bird.kablam :slug 

		assert_equal "The shot was slug", expectation.block_value
		assert_equal "The shot was slug", ret_val, "Block value should also be used for return"

		@bird._verify
	end


	def test_expectation_block_value_is_used_for_return_value
		@bird.expect.kablam(:scatter) { |shot|
			"The shot was #{shot}"
		}
		val = @bird.kablam :scatter 
		assert_equal "The shot was scatter", val, "Wrong return value"
		@bird._verify
	end

	def test_expectation_is_still_returned_when_using_returns
		expectation = @bird.expect.kablam(:slug) { |shot|
			"The shot was #{shot}"
		}.returns :hosed

		assert_not_nil expectation, "Expectation nil"
    assert_nil expectation.block_value, "Block value should start out nil"

		ret_val = @bird.kablam :slug 

		assert_equal "The shot was slug", expectation.block_value
		assert_equal :hosed, ret_val, "Block value should also be used for return"

		@bird._verify
	end

	def test_expectation_is_still_returned_when_using_raises
		expectation = @bird.expect.kablam(:slug) { |shot|
			"The shot was #{shot}"
		}.raises "aiee!"

		assert_not_nil expectation, "Expectation nil"
    assert_nil expectation.block_value, "Block value should start out nil"

		err = assert_raise RuntimeError do
		 @bird.kablam :slug 
		end
		assert_match(/aiee!/i, err.message)
		assert_equal "The shot was slug", expectation.block_value
		@bird._verify
	end


	def test_expect_assignment
		@bird.expect.size = "large"
		@bird.size = "large"
		@bird._verify
	end

	def test_expect_assignment_with_raise
		@bird.expect('size=','large').raises "boom"

		err = assert_raise RuntimeError do
			@bird.size = "large"
		end
		assert_match(/boom/i, err.message) 
	end

end
