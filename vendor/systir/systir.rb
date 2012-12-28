#!/usr/bin/ruby

# = DESCRIPTION
#
# Systir stands for "SYStem Testing In Ruby".  It's a framework for
# automating system-level tests using domain-specific language, and contains
# some tools and hints on how to construct and utilize your own domain language.
#
# The breakdown of using Systir for test automation is:
# 1. Tester defines test steps using project- and technology-specific language.
#    * Tests are written in files like +authentication+.+test+ and 
#      +order_placement+.+test+
# 2. The Toolsmith implements a driver to support the syntax of that language
#    * In a project-specific module, the Toolsmith writes an extension of the 
#      Systir::LanguageDriver class to support the macros used in *.test
# 3. The Tester's "scripts" are gathered up by Systir, executed, and a report 
#    is generated.
#    * Toolsmith writes a short script which uses Systest::Launcher to compose 
#      *.test files into a suite for execution.
#
# = TECHNICAL NOTE
# Under the hood, Systir is an extension of Test::Unit.  The output from 
# executing the test suite should therefor be familiar to a Ruby coder.  
# Additionally, it might be educational to the Toolsmith to understand that 
# LanguageDriver is a derivative of Test::Unit::TestCase, and that all *.test 
# files become test methods inside the TestCase which is then composed as a 
# Test::Unit::TestSuite
# 

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'test/unit/ui/xml/testrunner'
require 'find'
require 'stringio'
require 'ostruct'

# This disables the auto-run-at-exit feature inside test/unit.rb:
Test::Unit.run = true 

module Test
  module Unit
    class TestResult
      attr_reader :failures, :errors, :assertion_count
			attr_accessor :output
    end
  end
end

#
# Systir contains classes and modules to support writing and launching
# high-level test scripts.
#
module Systir

  VERSION = '0.5'

  #
  # Systir::LanguageDriver is a special derivative of TestCase designed to
  # contain user code written to support more macro-fied testing scripts.
  #
  class LanguageDriver < Test::Unit::TestCase
		attr_accessor :params

    # == Description
    # Installs a back-reference from this Driver instance into the specified Helper
    # and returns a reference to that Helper.  Typically thismethod is called
    # on the same line you return the helper from once it's built.
    #
    # == Params
    # +helper+ :: The Helper instance you're handing control over to
    #
    # == Return
    # The same +helper+ reference that was sent in as a parameter.
    # 
    # == Details
    #
    # Since Helpers are usually built as support for domain-level syntax,
    # they usually require a direct reference to macro functions built into
    # the driver.  Additionally, the Helper may need to make assertions
    # defined in the driver, or test/unit itself, and only the Driver may
    # count assertions; the Helper must use a special internal implementation
    # of 'add_assertion' in order to increment the test's assertion count.
    #
    # Some aliases have been added to aid readability
    #
    def associate_helper(helper)
      unless helper.respond_to? :driver=
        raise "helper doesn't support 'driver=' method"
      end
      helper.driver = self
      return helper
    end
    alias_method :return_helper, :associate_helper
    alias_method :hand_off_to, :associate_helper

    # (INTERNAL USE) 
    # Sneaky trick to expose the private mix-in method +add_assertion+ from
    # Test::Unit::Assertions.  Helpers derivatives that make assertions are
    # able to have them counted because of this method.  
    # (See associate_helper.)
    def collect_assertion
      add_assertion
    end
  end

  # = Description 
  #  Imports test scripts into the given driver class
  # and produces a TestSuite ready for execution
  class Builder
    def initialize(driver_class)
			raise 'driver class must be a Systir::LanguageDriver' unless driver_class < Systir::LanguageDriver
      @driver_class = driver_class
      remove_test_methods
    end

    # Read contents from_file, wrap text in 'def', 
    # add the resulting code as a new method on the target driver class
    def import_test(test)
      # Transform the test script into a test method inside
      # the driver class:
      text = File.readlines(test.path)
      text = "def test_#{test.fullname}\n#{text}\nend\n";

      # Dynamically define the method:
      @driver_class.class_eval(text, File.basename(test.path), 0)
			test_case = @driver_class.new("test_#{test.fullname}")
			test_case.params = test.params
			test_case
    end

    def suite_for_directory(dir)
			list = TestList.new
      Find.find(dir) do |path|
        if File.basename(path) =~ /\.test$/
          list.add :test => path 
        end
        if File.directory? path
          next
        end
      end
      suite_for_test_list list
    end

    def suite_for_file(filename,params=nil)
			list = TestList.new
			list.add :test => filename, :params => params
			suite_for_test_list list
    end

    def suite_for_list(file_list)
			list = TestList.new
			file_list.each do |path|
				list.add :test => path
			end
			suite_for_test_list list
    end

		def suite_for_test_list(test_list)
			suite = Test::Unit::TestSuite.new(@driver_class.name)
			test_list.tests.each do |test|
				suite << import_test(test)
			end
			suite
		end

    def remove_test_methods
      methods = @driver_class.public_instance_methods.select { |m| 
        m =~ /^test_/ 
      }
      methods.each do |method|
        @driver_class.send(:undef_method,method)
      end
    end
  end

	class TestList #:nodoc:
		attr_reader :tests

		def initialize
			@tests = []
		end

		def add(args)
			test = OpenStruct.new
			test.path = args[:test]
			test.params = args[:params]
			test.name = File.basename(test.path).sub(/\.test$/, '')
			test.fullname = test.name + (args[:name_suffix] ? "_#{args[:name_suffix]}" : '')
			@tests << test
		end
	end
	
  # = Description
  # Launcher is the utility for launching Systir test scripts.
  #
  class Launcher
		#
		# Creates a new Launcher, the following arguments may be specified in a hash
		# 
		# :stdout - true or false, whether to send test reporting output to stdout (default true)
		# :format - :console or :xml, format of test reporting output (default :xml)
		#
		# note: output is available via the TestResult returned from the following methods:
		# * find_and_run_all_tests
		# * run_test
		# * run_test_list
		# * run_suite
		#
    def initialize(args={})
			@stdout = args[:stdout].nil? ? true : args[:stdout]
      @format = args[:format].nil? ? :console : args[:format]
    end

    # 
    # Find and run all the system test scripts in the given directory.
    # Tests are identified by the .test file extension.
    #
    def find_and_run_all_tests(driver_class, dir='.')
      raise 'dir cannot be nil' if dir.nil?
      raise 'dir does not exist' unless File.directory?(dir)
      b = Builder.new(driver_class)
      execute b.suite_for_directory(dir)
    end

    #
    # Run a specific test, optionally providing parameters to be available 
		# within the driver instance.
		#
		#   Systir::Launcher.new.run_test(MyDriver, './tests/foo.test')
		#
		#   Systir::Launcher.new.run_test(MyDriver, './tests/foo.test', :opt1 => 'thinger', :another => 'bar')
		# 
		# given parameters are available via the <tt>params</tt> method on the 
		# driver instance which returns the hash passed to run_test.
		#
		# returns TestResult
    #
    def run_test(driver_class, filename, params=nil)
      raise 'filename cannot be nil' if filename.nil?
      raise 'filename does not exist' unless File.exists?(filename)
      b = Builder.new(driver_class)
      execute b.suite_for_file(filename,params)
    end

    #
    # Run a specific list of tests
    #
		# returns TestResult
    #
    def run_test_list(driver_class, file_list)
      raise 'file_list cannot be nil' if file_list.nil?
      raise 'file_list cannot be empty' if file_list.empty?
      b = Builder.new(driver_class)
      execute b.suite_for_list(file_list)
    end

		#
		# Run a suite of tests defined by a given block.
		#
		#   launcher.run_suite(MyDriver) do |suite|
		#     suite.add :test => './tests/run_me_twice.test'
		#     suite.add :test => './tests/run_me_twice.test', :name_suffix => 'other_one'
		#     suite.add :test => './tests/specific_parameters.test', :params => {:one => 'mine', :two => 'also mine'}
		#   end
		#
		# :test - path to the systir test file
		# :name_suffix - (optional) string appended to the end of the test name in 
		#                this suite run.this option is useful when running multiple 
		#                tests from the same file.
		# :params - (optional) hash of parameters to be set on the driver instance
		#           for the execution of this test
		#
		# returns TestResult
    #
		def run_suite(driver_class)
			b = Builder.new(driver_class)
			suite = TestList.new
			yield suite
			execute b.suite_for_test_list(suite)
		end

    #
    # Use console test runner to execute the given suite
    #
    def execute(suite)
      buffer = StringIO.new
			ios = []
			ios << STDOUT if @stdout
			ios << buffer
      io = MethodMulticaster.new(ios)
			level = Test::Unit::UI::NORMAL

      runner = case @format
        when :console
          Test::Unit::UI::Console::TestRunner
        when :xml
          Test::Unit::UI::XML::TestRunner
        else
          raise "don't know anything about runner: [#{@runner}]"
      end

			result = runner.new(suite, level, io).start
      buffer.rewind
      result.output = buffer.read
      result
    end
  end

  class MethodMulticaster #:nodoc:
    def initialize(targets)
      @targets = targets
    end

    def method_missing(method,*args)
      @targets.each do |target|
        target.send(method,*args)
      end
    end
  end


  # = DESCRIPTION 
  # Systir::Helper is a module intended for mixing-in to classes defined 
  # to assist a project-specific Systir::LanguageDriver.
  # 
  #
  module Helper
    include Test::Unit::Assertions

    #
    # Construct a new Helper with a back reference to the language driver.
    # NOTE: the +driver+ argument is optional if you utilize <code>driver=</code>
    # or Systir::LanguageDriver.associate_helper
    # 
    def initialize(driver=nil)
      @_driver = driver
    end

    #
    # Returns a reference to our owning LanguageDriver instance.
    #
    def driver
      unless @_driver
        raise "Implementation error: helper has no back reference to the language driver!" 
      end
      return @_driver
    end

    #
    # Sets the owning reference to a LanguageDriver.
    # This method is used by Systir::LanguageDriver#associate_helper.
    #
    def driver=(dr)
      @_driver = dr
    end

    # == Description
    # Installs a back-reference from this Driver instance into the specified Helper
    # and returns a reference to that Helper.  Typically thismethod is called
    # on the same line you return the helper from once it's built.
    #
    # == Params
    # +helper+ :: The Helper instance you're handing control over to
    #
    # == Return
    # The same +helper+ reference that was sent in as a parameter.
    # 
    # == Details
    #
    # Since Helpers are usually built as support for domain-level syntax,
    # they usually require a direct reference to macro functions built into
    # the driver.  Additionally, the Helper may need to make assertions
    # defined in the driver, or test/unit itself, and only the Driver may
    # count assertions; the Helper must use a special internal implementation
    # of 'add_assertion' in order to increment the test's assertion count.
    #
    # Some aliases have been added to aid readability
    #
    def associate_helper(helper)
      unless helper.respond_to? :driver=
        raise "helper doesn't support 'driver=' method"
      end
      helper.driver = self.driver
      return helper
    end
    alias_method :return_helper, :associate_helper
    alias_method :hand_off_to, :associate_helper

    # 
    # Redirects assertion counting into our owning LanguageDriver.
    # Assertions module will automatically attempt to store the count
    # within a Helper otherwise, leading to incorrect results.
    #
    private
    def add_assertion
      unless driver.respond_to? :collect_assertion
        raise "Implementation error: driver needs a 'collect_assertion' method"
      end
      driver.collect_assertion
    end
  end
end

