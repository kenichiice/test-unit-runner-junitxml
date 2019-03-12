require "stringio"
require 'rexml/document'
require "test/unit"
require "test/unit/ui/junitxml/testrunner"

module Test
  module Unit
    module UI
      module JUnitXml
        class TestXml < Test::Unit::TestCase

          def test_1
            test_case = Class.new(Test::Unit::TestCase) do
              test "success" do
                assert_equal(1, 1)
              end

              def test_failure
                assert_equal(1, 2)
              end

              def test_error
                raise "hello"
              end

              def test_omission
                omit
              end

              def test_pending
                pend
              end
            end

            output = StringIO.new
            runner = TestRunner.new(test_case.suite, :output => output)
            runner.start

            output.rewind
            doc = REXML::Document.new(output)

            testsuites = doc.get_elements("testsuites")
            assert_equal(1, testsuites.size)
            testsuite_array = testsuites.first.get_elements("testsuite")
            assert_equal(1, testsuite_array.size)
            testsuite = testsuite_array.first
            check_testsuite(testsuite, "", 5, 1, 1, 2)

            check_testcase(
              testsuite.elements["testcase[@name='success']"],
              "", 1, :success)
            check_testcase(
              testsuite.elements["testcase[@name='test_failure()']"],
              "", 1, :failure)
            check_testcase(
              testsuite.elements["testcase[@name='test_error()']"],
              "", 0, :error)
            check_testcase(
              testsuite.elements["testcase[@name='test_omission()']"],
              "", 0, :skipped)
            check_testcase(
              testsuite.elements["testcase[@name='test_pending()']"],
              "", 0, :skipped)
          end

          private

          def check_testsuite(testsuite, name, tests, errors, failures, skipped)
            assert_equal(name, testsuite.attribute("name").value)
            assert_equal(tests, testsuite.get_elements("testcase").size)
            assert_equal(tests.to_s, testsuite.attribute("tests").value)
            assert_equal(errors.to_s, testsuite.attribute("errors").value)
            assert_equal(failures.to_s, testsuite.attribute("failures").value)
            assert_equal(skipped.to_s, testsuite.attribute("skipped").value)
            assert_compare(0, "<", Float(testsuite.attribute("time").value))
          end

          def check_testcase(testcase, class_name, assertions, result_type)
            assert_equal(class_name, testcase.attribute("classname").value)
            assert_equal(assertions.to_s, testcase.attribute("assertions").value)
            assert_compare(0, "<", Float(testcase.attribute("time").value))

            failures = testcase.get_elements("failure")
            case result_type
            when :failure
              assert_equal(1, failures.size)
              assert_not_nil(failures.first.attribute("message"))
              assert_true(failures.first.has_text?)
            when :success, :error, :skipped
              assert_equal(0, failures.size)
            else
              raise "invalid result_type: #{result_type}"
            end

            errors = testcase.get_elements("error")
            case result_type
            when :error
              assert_equal(1, errors.size)
              assert_not_nil(errors.first.attribute("message"))
              assert_not_nil(errors.first.attribute("type"))
              assert_true(errors.first.has_text?)
            when :success, :failure, :skipped
              assert_equal(0, errors.size)
            else
              raise "invalid result_type: #{result_type}"
            end

            skippeds = testcase.get_elements("skipped")
            case result_type
            when :skipped
              assert_equal(1, skippeds.size)
            when :success, :failure, :error
              assert_equal(0, skippeds.size)
            else
              raise "invalid result_type: #{result_type}"
            end
          end
        end
      end
    end
  end
end
