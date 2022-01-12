require 'erb'
require 'stringio'
require 'test/unit/ui/testrunner'
require 'test/unit/ui/testrunnermediator'

module Test
  module Unit
    module UI
      module JUnitXml

        # Runs a Test::Unit::TestSuite and outputs JUnit XML format.
        class TestRunner < UI::TestRunner
          include ERB::Util

          def initialize(suite, options={})
            super
            @junit_test_suites = []
          end

          private

          def attach_to_mediator
            @mediator.add_listener(TestSuite::STARTED_OBJECT,
                                   &method(:test_suite_started))
            @mediator.add_listener(TestSuite::FINISHED_OBJECT,
                                   &method(:test_suite_finished))
            @mediator.add_listener(TestCase::STARTED_OBJECT,
                                   &method(:test_started))
            @mediator.add_listener(TestCase::FINISHED_OBJECT,
                                   &method(:test_finished))
            @mediator.add_listener(TestResult::PASS_ASSERTION,
                                   &method(:result_pass_assertion))
            @mediator.add_listener(TestResult::FAULT,
                                   &method(:result_fault))
            @mediator.add_listener(TestRunnerMediator::FINISHED,
                                   &method(:finished))
          end

          def test_suite_started(suite)
            if suite.test_case
              @junit_test_suites << JUnitTestSuite.new(suite.name)
            end
          end

          def test_suite_finished(suite)
            if suite.test_case
              @junit_test_suites.last.time = suite.elapsed_time
            end
          end

          def test_started(test)
            test_case = JUnitTestCase.new(test.class.name, test.description)
            @junit_test_suites.last << test_case
            unless @options[:junitxml_disable_output_capture]
              @stdout_org = $stdout
              @stderr_org = $stderr
              $stdout = test_case.stdout
              $stderr = test_case.stderr
            end
          end

          def test_finished(test)
            @junit_test_suites.last.test_cases.last.time = test.elapsed_time
            unless @options[:junitxml_disable_output_capture]
              $stdout = @stdout_org
              $stderr = @stderr_org
            end
          end

          def result_pass_assertion(result)
            @junit_test_suites.last.test_cases.last.assertion_count += 1
          end

          def result_fault(fault)
            @junit_test_suites.last.test_cases.last << fault
          end

          def finished(elapsed_time)
            # open ERB template
            template = File.read(File.expand_path("xml.erb",
                                                  File.dirname(__FILE__)))
            if ERB.instance_method(:initialize).parameters.assoc(:key)
              erb = ERB.new(template, trim_mode: "%")
            else
              erb = ERB.new(template, nil, "%")
            end

            # output
            output = if @options[:junitxml_output_file]
                       File.open(@options[:junitxml_output_file], "w")
                     elsif @options[:output_file_descriptor]
                       IO.new(@options[:output_file_descriptor], "w")
                     elsif @options[:output]
                       @options[:output]
                     else
                       STDOUT
                     end
            output.write(erb.result(binding))
            output.flush
            output.close if @options[:junitxml_output_file]
          end
        end

        class JUnitTestSuite
          attr_reader :name, :test_cases
          attr_accessor :time

          def initialize(name)
            @name = name
            @time = 0
            @test_cases = []
          end

          def <<(test_case)
            @test_cases << test_case
          end

          def failures
            @test_cases.map(&:failure).compact
          end

          def errors
            @test_cases.map(&:error).compact
          end
        end

        class JUnitTestCase
          attr_reader :class_name, :name
          attr_reader :failure, :error, :omission, :pending
          attr_reader :stdout, :stderr
          attr_accessor :assertion_count, :time

          def initialize(class_name, name)
            @class_name = class_name
            @name = name
            @stdout = StringIO.new
            @stderr = StringIO.new
            @assertion_count = 0
            @time = 0
          end

          def <<(fault)
            # Notification is ignored
            case fault
            when Failure
              @failure = fault
            when Error
              @error = fault
            when Omission
              @omission = fault
            when Pending
              @pending = fault
            end
          end

          def skipped?
            @omission || @pending
          end
        end

      end
    end
  end
end
