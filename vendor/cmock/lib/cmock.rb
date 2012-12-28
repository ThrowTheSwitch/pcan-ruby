# CMock is a mock-objects library for unit testing Ruby code.
#
#
# The basic procedure for using CMock in your tests is:
#
# * Include CMock in your test
# * Create some mock objects using create_mocks
# * Setup expectations by calling Mock#expect on your mock objects
# * Execute the code under test
# * Verify your expectations have been met with verify_mocks
# 
# The expectations you set when using mocks are <b>strict</b> and <b>ordered</b>.
# Expectations you declare by creating and using mocks are all considered together.
#
# Eg,
#   create_mocks :garage, :car
#
#   # Set some expectations
#   @garage.expect.open_door
#   @car.expect.start(:choke)
#   @car.expect.drive(:reverse, 5.mph)
#
#   # Execute the code (this code is usually, obviously, in your class under test)
#   @garage.open_door  
#   @car.start :choke
#   @car.drive :reverse, 5.mph
#
#   verify_mocks
#
# Expects <tt>@garage.open_door</tt>, <tt>@car.start(:choke)</tt> and <tt>@car.drive(:reverse, 5.mph)</tt> to be called in that relative order, with those specific arguments.
# * Violations of expectations, such as mis-ordered calls, calls on wrong objects, or incorrect methods result in CMock::ExpectationError
# * <tt>verify_mocks</tt> will raise VerifyError if not all expectations have been met.
# 
#
module CMock

  # Create one or more new Mock instances in your test suite. 
  # Once created, the Mocks are accessible as instance variables in your test.
  # Newly built Mocks are added to the full set of Mocks for this test, which will
  # be verified when you call verify_mocks.
	#
	#   create_mocks :donkey, :cat # Your test now has @donkey and @cat
	#   create_mock  :dog          # Test now has @donkey, @cat and @dog
	#   
	# The first call returned a hash { :donkey => @donkey, :cat => @cat }
	# and the second call returned { :dog => @dog }
  #
	# For more info on how to use your mocks, see Mock and SimpleExpectation
	#
  def create_mocks(*mock_names)
    @main_mock_control ||= MockControl.new

    mocks = {}
    mock_names.each do |mock_name|
      mock_name = mock_name.to_s
      mock_object = Mock.new(mock_name, @main_mock_control)
      mocks[mock_name.to_sym] = mock_object
      self.instance_variable_set "@#{mock_name}", mock_object
    end
    @all_mocks ||= {}
    @all_mocks.merge! mocks

    return mocks.clone
  end

  alias :create_mock :create_mocks

	# Ensures that all expectations have been met.  If not, VerifyException is
	# raised.
	#
	# * +force+ -- if +false+, and a VerifyError or ExpectationError has already occurred, this method will not raise.  This is to help you suppress repeated errors when if you're calling #verify_mocks in the teardown method of your test suite.  BE WARNED - only use this if you're sure you aren't obscuring useful information.  Eg, if your code handles exceptions internally, and an ExpectationError gets gobbled up by your +rescue+ block, the cause of failure for your test may be hidden from you.  For this reason, #verify_mocks defaults to force=true as of CMock 1.0.1
	def verify_mocks(force=true)
    return unless @main_mock_control
    return if @main_mock_control.disappointed? and !force
    @main_mock_control.verify
  end

  module Utils #:nodoc:
    def fmt_call(mock,mname,args)
      arg_string = args.map { |a| a.inspect }.join(', ')
      call_text = "#{mock._name}.#{mname}(#{arg_string})"
    end
  end

	# Mock is used to set expectations in your test.  Most of the time you'll use
	# <tt>#expect</tt> to create expectations.
	#
	# Aside from the scant few control methods (like +expect+, +trap+ and +_verify+) 
	# all calls made on a Mock instance will be immediately applied to the internal
	# expectation mechanism.
	#
	# * If the method call was expected and all the parameters match properly, execution continues
	# * If the expectation was configured with an expectation block, the block is invoked
	# * If the expectation was set up to raise an error, the error is raised now
	# * If the expectation was set up to return a value, it is returned
	# * If the method call was _not_ expected, or the parameter values are wrong, an ExpectationError is raised.
  class Mock
		# Create a new Mock instance with a name and a MockControl to support it.
    # If not given, a MockControl is made implicitly for this Mock alone; this means
		# expectations for this mock are not tied to other expectations in your test.
		#
		# It's not recommended to use a Mock directly; see CMock and
		# CMock#create_mocks for the more wholistic approach.
    def initialize(name, mock_control=nil)
      @name = name
      @control = mock_control || MockControl.new
			@expectation_builder = ExpectationBuilder.new
    end

		# Begin declaring an expectation for this Mock.
		#
		# == Simple Examples
		# Expect the +customer+ to be queried for +account+, and return <tt>"The
		# Account"</tt>: 
		#   @customer.expect.account.returns "The Account"
		#
		# Expect the +withdraw+ method to be called, and raise an exception when it
		# is (see SimpleExpectation#raises for more info):
		#   @cash_machine.expect.withdraw(20,:dollars).raises("not enough money")
		#
		# Expect +customer+ to have its +user_name+ set
		#   @customer.expect.user_name = 'Big Boss'
		#   
		# Expect +customer+ to have its +user_name+ set, and raise a RuntimeException when
		# that happens:
		#   @customer.expect('user_name=', "Big Boss").raises "lost connection"
		#
		# Expect +evaluate+ to be passed a block, and when that happens, pass a value
		# to the block (see SimpleExpectation#yields for more info):
		#   @cruncher.expect.evaluate.yields("some data").returns("some results")
		#
		#
		# == Expectation Blocks
		# To do special handling of expected method calls when they occur, you
		# may pass a block to your expectation, like:
		#   @page_scraper.expect.handle_content do |address,request,status|
		#     assert_not_nil address, "Can't abide nil addresses"
		#     assert_equal "http-get", request.method, "Can only handle GET"
		#     assert status > 200 and status < 300, status, "Failed status"
		#     "Simulated results #{request.content.downcase}"
		#   end
		# In this example, when <tt>page_scraper.handle_content</tt> is called, its
		# three arguments are passed to the <i>expectation block</i> and evaluated
		# using the above assertions.  The last value in the block will be used 
		# as the return value for +handle_content+
		#
		# You may specify arguments to the expected method call, just like any normal
		# expectation, and those arguments will be pre-validated before being passed
		# to the expectation block.  This is useful when you know all of the
		# expected values but still need to do something programmatic.
		#
		# If the method being invoked on the mock accepts a block, that block will be
		# passed to your expectation block as the last (or only) argument.  Eg, the 
		# convenience method +yields+ can be replaced with the more explicit:
		#   @cruncher.expect.evaluate do |block|
	  #     block.call "some data"
		#     "some results"
		#   end
		#
		# The result value of the expectation block becomes the return value for the
		# expected method call. This can be overidden by using the +returns+ method:
		#   @cruncher.expect.evaluate do |block|
	  #     block.call "some data"
		#     "some results"
		#   end.return("the actual value")
		# 
		# <b>Additionally</b>, the resulting value of the expectation block is stored
		# in the +block_value+ field on the expectation.  If you've saved a reference 
		# to your expectation, you may retrieve the block value once the expectation
		# has been met.
		#
		#   evaluation_event = @cruncher.expect.evaluate do |block|
	  #     block.call "some data"
		#     "some results"
		#   end.return("the actual value")
		#
		#   result = @cruncher.evaluate do |input|
		#     puts input  # => 'some data'
		#   end
		#   # result is 'the actual value'
    #   
		#   evaluation_event.block_value # => 'some results'
		#
    def expect(*args, &block)
			expector = Expector.new(self,@control,@expectation_builder)
			# If there are no args, we return the Expector
			return expector if args.empty?
			# If there ARE args, we set up the expectation right here and return it
			expector.send(args.shift.to_sym, *args, &block)
    end

		# Special-case convenience: #trap sets up an expectation for a method
		# that will take a block.  That block, when sent to the expected method, will
		# be trapped and stored in the expectation's +block_value+ field.
		# The SimpleExpectation#trigger method may then be used to invoke that block.
		#
		# Like +expect+, the +trap+ mechanism can be followed by +raises+ or +returns+.
    #
		# _Unlike_ +expect+, you may not use an expectation block with +trap+.  If 
		# the expected method takes arguments in addition to the block, they must
		# be specified in the arguments to the +trap+ call itself.
		#
		# == Example
		# 
		#   create_mocks :address_book, :editor_form
    #
		#   # Expect a subscription on the :person_added event for @address_book:
		#   person_event = @address_book.trap.subscribe(:person_added)
		#
		#   # The runtime code would look like:
		#   @address_book.subscribe :person_added do |person_name|
		#     @editor_form.name = person_name
		#   end
		#
		#   # At this point, the expectation for 'subscribe' is met and the 
		#   # block has been captured.  But we're not done:
		#   @editor_form.expect.name = "David"
		#
		#   # Now invoke the block we trapped earlier:
		#	  person_event.trigger "David"
		#
		#   verify_mocks
		def trap(*args)
			Trapper.new(self,@control,ExpectationBuilder.new)
		end

    def method_missing(mname,*args) #:nodoc:
      block = nil
      block = Proc.new if block_given?
      @control.apply_method_call(self,mname,args,block)
    end

    def _control #:nodoc:
      @control
    end

    def _name #:nodoc:
      @name
    end

		# Verify that all expectations are fulfilled.  NOTE: this method triggers
		# validation on the _control_ for this mock, so all Mocks that share the
		# MockControl with this instance will be included in the verification.
		#
		# <b>Only use this method if you are managing your own Mocks and their controls.</b>
		#
		# Normal usage of CMock doesn't require you to call this; let
		# CMock#verify_mocks do it for you.
		def _verify
      @control.verify
    end
  end

  class Expector #:nodoc:
    def initialize(mock,mock_control,expectation_builder)
      @mock = mock
      @mock_control = mock_control
      @expectation_builder = expectation_builder
    end

    def method_missing(mname, *args, &block)
      expectation = @expectation_builder.build_expectation(
        :mock => @mock, 
        :method => mname, 
        :arguments => args, 
        :block => block)

      @mock_control.add_expectation expectation
      expectation
    end
  end

  class Trapper #:nodoc:
    def initialize(mock,mock_control,expectation_builder)
      @mock = mock
      @mock_control = mock_control
      @expectation_builder = expectation_builder
    end

    def method_missing(mname, *args)
			if block_given?
				raise ExpectationError.new("Don't pass blocks when using 'trap' (setting exepectations for '#{mname}')")
			end
			
      the_block = lambda { |target_block| target_block }
      expectation = @expectation_builder.build_expectation(
        :mock => @mock, 
        :method => mname, 
        :arguments => args, 
				:suppress_arguments_to_block => true,
        :block => the_block)

      @mock_control.add_expectation expectation
      expectation
    end
  end

  class ExpectationBuilder #:nodoc:
    def build_expectation(options)
      SimpleExpectation.new(options)
    end
  end

  class SimpleExpectation
    include Utils
    attr_reader :block_value

    def initialize(options) #:nodoc:
      @options = options
    end

    def apply_method_call(mock,mname,args,block) #:nodoc:
      unless @options[:mock].equal?(mock)
        raise anger("Wrong object", mock,mname,args)
      end
      unless @options[:method] == mname
        raise anger("Wrong method",mock,mname,args)
      end

      # Tester-defined block to invoke at method-call-time:
      expectation_block = @options[:block]

      expected_args = @options[:arguments]
      # if we have a block, we can skip the argument check if none were specified
      unless (expected_args.nil? || expected_args.empty?) && expectation_block && !@options[:suppress_arguments_to_block]
        unless expected_args == args
          raise anger("Wrong arguments",mock,mname,args)
        end
      end

      relayed_args = args.dup
      if block
        if expectation_block.nil?
          # Can't handle a runtime block without an expectation block
          raise ExpectationError.new("Unexpected block provided to #{to_s}")
        else
					# Runtime blocks are passed as final argument to the expectation block
					unless @options[:suppress_arguments_to_block]
						relayed_args << block
					else
						# Arguments suppressed; send only the block
						relayed_args = [block]
					end
        end
      end

      # Run the expectation block:
      @block_value = expectation_block.call(*relayed_args) if expectation_block

      raise @options[:raises] if @options[:raises]
      @options[:returns] || @block_value
    end

		# Set the return value for an expected method call.
		# Eg,
		#   @cash_machine.expects.withdraw(20,:dollars).returns(20.00)
    def returns(val)
      @options[:returns] = val
			self
    end

		# Rig an expected method to raise an exception when the mock is invoked.
		#
		# Eg,
		#   @cash_machine.expects.withdraw(20,:dollars).raises "Insufficient funds"
		#
		# The argument can be:
		# * an Exception -- will be used directly
		# * a String -- will be used as the message for a RuntimeError
		# * nothing -- RuntimeError.new("An Error") will be raised
    def raises(err=nil)
      case err
      when Exception
        @options[:raises] = err
      when String
        @options[:raises] = RuntimeError.new(err)
      else
        @options[:raises] = RuntimeError.new("An Error")
      end
			self
    end

    # Convenience method: assumes +block_value+ is set, and is set to a Proc
    # (or anything that responds to 'call')
		#
		#   light_event = @traffic_light.trap.subscribe(:light_changes)
	  #
		#   # This code will meet the expectation:
		#   @traffic_light.subscribe :light_changes do |color|
	  #     puts color
	  #   end
		#
		# The color-handling block is now stored in <tt>light_event.block_value</tt>
		#
		# The block can be invoked like this:
		#
		#   light_event.trigger :red
		# 
		# See Mock#trap and Mock#expect for information on using expectation objects 
		# after they are set.
		#
    def trigger(*block_arguments)
      unless block_value
        raise ExpectationError.new("No block value is currently set for expectation #{to_s}")
      end
      unless block_value.respond_to?(:call)
        raise ExpectationError.new("Can't apply trigger to #{block_value} for expectation #{to_s}")
      end
      block_value.call *block_arguments
    end

		# Used when an expected method accepts a block at runtime.  
		# When the expected method is invoked, the block passed to
		# that method will be invoked as well.
		#
		# NOTE: ExpectationError will be thrown upon running the expected method
		# if the arguments you set up in +yields+ do not properly match up with
		# the actual block that ends up getting passed.
		# 
		# == Examples
		# <b>Single invocation</b>: The block passed to +lock_down+ gets invoked
		# once with no arguments:
		#
		#   @safe_zone.expect.lock_down.yields
		#
		#   # (works on code that looks like:)
		#   @safe_zone.lock_down do 
	  #     # ... this block invoked once
		#   end
		# 
		# <b>Multi-parameter blocks:</b> The block passed to +each_item+ gets
		# invoked twice, with <tt>:item1</tt> the first time, and with
		# <tt>:item2</tt> the second time:
		# 
		#   @fruit_basket.expect.each_with_index.yields [:apple,1], [:orange,2]
		#
		#   # (works on code that looks like:)
		#   @fruit_basket.each_with_index do |fruit,index|
	  #     # ... this block invoked with fruit=:apple, index=1, 
		#     # ... and then with fruit=:orange, index=2
		#   end
		#
		# <b>Arrays can be passed as arguments too</b>... if the block 
		# takes a single argument and you want to pass a series of arrays into it,
		# that will work as well:
		#
		#   @list_provider.expect.each_list.yields [1,2,3], [4,5,6]
		#
		#   # (works on code that looks like:)
		#   @list_provider.each_list do |list|
		#     # ... list is [1,2,3] the first time
		#     # ... list is [4,5,6] the second time
		#   end
		#
		# <b>Return value</b>: You can set the return value for the method that
		# accepts the block like so: 
		#
		#   @cruncher.expect.do_things.yields(:bean1,:bean2).returns("The Results")
		#
		# <b>Raising errors</b>: You can set the raised exception for the method that
		# accepts the block. NOTE: the error will be raised _after_ the block has
		# been invoked.
		#
		#   # :bean1 and :bean2 will be passed to the block, then an error is raised:
		#   @cruncher.expect.do_things.yields(:bean1,:bean2).raises("Too crunchy")
		#
		def yields(*items)
			@options[:suppress_arguments_to_block] = true
			if items.empty?
				# Yield once
				@options[:block] = lambda do |block|
					if block.arity != 0 and block.arity != -1
						raise ExpectationError.new("Can't pass #{item.inspect} to block with arity #{block.arity} to <#{to_s}>")
					end
					block.call
				end
			else
				# Yield one or more specific items
				@options[:block] = lambda do |block|
					items.each do |item|
						if item.kind_of?(Array) 
							if block.arity == item.size
								# Unfold the array into the block's arguments:
								block.call *item
							elsif block.arity == 1
								# Just pass the array in
								block.call item
							else
								# Size mismatch
								raise ExpectationError.new("Can't pass #{item.inspect} to block with arity #{block.arity} to <#{to_s}>")
							end
						else
							if block.arity != 1
								# Size mismatch
								raise ExpectationError.new("Can't pass #{item.inspect} to block with arity #{block.arity} to <#{to_s}>")
							end
							block.call item
						end
					end
				end
			end
			self
		end

    def to_s # :nodoc:
      fmt_call(@options[:mock],@options[:method],@options[:arguments])
    end

    private 
    def anger(msg, mock,mname,args)
      ExpectationError.new("#{msg}: expected call <#{to_s}> but was <#{fmt_call(mock,mname,args)}>")
    end
  end

  class MockControl #:nodoc:
    include Utils
    attr_accessor :name

    def initialize
      @expectations = []
      @disappointed = false
    end

    def happy?
      @expectations.empty?
    end

    def disappointed?
      @disappointed
    end

    def add_expectation(expectation)
      @expectations << expectation
    end

    def apply_method_call(mock,mname,args,block)
      # Are we even expecting any sort of call?
      if happy?
        @disappointed = true
        raise ExpectationError.new("Surprise call to #{fmt_call(mock,mname,args)}")
      end

      begin
        @expectations.shift.apply_method_call(mock,mname,args,block)
      rescue Exception => ouch
        @disappointed = true
        raise ouch
      end
    end

    def verify
      @disappointed = !happy?
      raise VerifyError.new("Unmet expectations", @expectations) unless happy?
    end
  end

  class ExpectationError < StandardError; end

  class VerifyError < StandardError
    def initialize(msg,unmet_expectations)
      super("#{msg}:" + unmet_expectations.map { |ex| "\n * #{ex.to_s}" }.join)
    end
  end
	
  # A better 'assert_raise'.  +patterns+ can be one or more Regexps, or a literal String that 
	# must match the entire error message.
	def assert_error(err_type,*patterns,&block)
		assert_not_nil block, "assert_error requires a block"
		assert((err_type and err_type.kind_of?(Class)), "First argument to assert_error has to be an error type")
		err = assert_raise(err_type) do
			block.call
		end
		patterns.each do |pattern|
			case pattern
			when Regexp
				assert_match(pattern, err.message) 
			else
				assert_equal pattern, err.message
			end
		end
	end
  
end
