#!/usr/bin/env ruby

#
# Copyright (c) 2005, Gregory D. Fast
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
# 
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

require 'test/unit/ui/testrunnermediator'
require 'test/unit/ui/testrunnerutilities'
require 'test/unit/ui/console/testrunner'
require 'test/unit/autorunner'
require 'rexml/document'

module Test
  module Unit
    module UI
      module XML

        #
        # XML::TestRunner - generate xml output for test results
        #
        # Example use:
        #
        #   $ ruby -rtest/unit/ui/xml/testrunner test/test_1.rb --runner=xml
        #
        # By default, XML::TestRunner will output to stdout.
        # You can set the environment variable $XMLTEST_OUTPUT to
        # a filename to send the output to that file.
        #
        # The summary file created by this testrunner is XML, but 
        # this module also includes a stylesheet
        # (test/unit/ui/xml/xmltestrunner.xslt) which converts it to
        # HTML.  Copy the XSLT file into the same directory as the 
        # test results file, and open the results file with a browser.
        #
        # --- 
        # 
        # (todo: use with rake)
        #
        class TestRunner < Test::Unit::UI::Console::TestRunner

          def initialize(suite, output_level=NORMAL, io=STDOUT)
            super(suite)
						if io.is_a? String
              fn = io
              puts "Writing to #{fn}"
              @io = File.open( fn, "w" )
              @using_stdout = false
            else
              @io = io
              @using_stdout = true
            end
            create_document
          end

          def create_document
            @doc = REXML::Document.new
            @doc << REXML::XMLDecl.new
            
            pi = REXML::Instruction.new(
                   "xml-stylesheet",
                   "type='text/xsl' href='xmltestrunner.xslt' "
            )
            @doc << pi

            e = REXML::Element.new("testsuite")
            e.attributes['rundate'] = Time.now
            @doc << e
          end

          def to_s
            @doc.to_s
          end

          def start
            @current_test = nil
            # setup_mediator
            @mediator = TestRunnerMediator.new( @suite )
            suite_name = @suite.to_s
            if @suite.kind_of?(Module)
              suite_name = @suite.name
            end
            @doc.root.attributes['name'] = suite_name
            # attach_to_mediator - define callbacks
            @mediator.add_listener( TestResult::FAULT, 
                                    &method(:add_fault) )
            @mediator.add_listener( TestRunnerMediator::STARTED,
                                    &method(:started) )
            @mediator.add_listener( TestRunnerMediator::FINISHED,
                                    &method(:finished) )
            @mediator.add_listener( TestCase::STARTED, 
                                    &method(:test_started) )
            @mediator.add_listener( TestCase::FINISHED, 
                                    &method(:test_finished) )
            # return start_mediator
            return @mediator.run_suite
          end

          # callbacks

          def add_fault( fault )
            ##STDERR.puts "Fault:"
            @faults << fault
            e = REXML::Element.new( "fault" )
            e << REXML::CData.new( fault.long_display ) 
            @current_test << e
          end

          def started( result )
            #STDERR.puts "Started"
            @result = result
          end

          def finished( elapsed_time )
            #STDERR.puts "Finished"
            res = REXML::Element.new( "result" )
            summ = REXML::Element.new( "summary" )
            summ.text = @result
            res << summ
            # @result is a Test::Unit::TestResults
            res.attributes['passed'] = @result.passed?
            res.attributes['testcount'] = @result.run_count
            res.attributes['assertcount'] = @result.assertion_count
            res.attributes['failures'] = @result.failure_count
            res.attributes['errors'] = @result.error_count
            @doc.root << res

            e = REXML::Element.new( "elapsed-time" )
            e.text = elapsed_time
            @doc.root << e
            @io.puts( @doc.to_s )
            
            unless @using_stdout
              puts @result
            end
          end
          
          def test_started( name )
            #STDERR.puts "Test: #{name} started"
            e = REXML::Element.new( "test" )
            e.attributes['name'] = name
            #e.attributes['status'] = "failed"
            @doc.root << e
            @current_test = e
          end

          def test_finished( name )
            #STDERR.puts "Test: #{name} finished"
            # find //test[@name='name']
            @current_test = nil
          end

        end
      end
    end
  end
end

# "plug in" xmltestrunner into autorunner's list of known runners
# This enables the "--runner=xml" commandline option.
Test::Unit::AutoRunner::RUNNERS[:xml] = proc do |r|
  require 'test/unit/ui/xml/testrunner'
  Test::Unit::UI::XML::TestRunner
end

if __FILE__ == $0
  Test::Unit::UI::XML::TestRunner.start_command_line_test
end

