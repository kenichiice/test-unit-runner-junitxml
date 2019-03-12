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

            check_testcase_success(
              testsuite.elements["testcase[@name='success']"],
              "", 1)
            check_testcase_failure(
              testsuite.elements["testcase[@name='test_failure()']"],
              "", 1)
            check_testcase_error(
              testsuite.elements["testcase[@name='test_error()']"],
              "", 0)
            check_testcase_skipped(
              testsuite.elements["testcase[@name='test_omission()']"],
              "", 0)
            check_testcase_skipped(
              testsuite.elements["testcase[@name='test_pending()']"],
              "", 0)
          end

          def test_multibyte_text
            test_case = Class.new(Test::Unit::TestCase) do
              test "成功" do
                assert_equal(1, 1)
              end

              def test_failure
                assert_equal(1, 2, "失敗")
              end

              def test_error
                raise "エラー"
              end

              def test_omission
                omit("除外")
              end

              def test_pending
                pend("保留")
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

            check_testcase_success(
              testsuite.elements["testcase[@name='成功']"],
              "", 1)
            check_testcase_failure(
              testsuite.elements["testcase[@name='test_failure()']"],
              "", 1, "失敗")
            check_testcase_error(
              testsuite.elements["testcase[@name='test_error()']"],
              "", 0, "エラー")
            check_testcase_skipped(
              testsuite.elements["testcase[@name='test_omission()']"],
              "", 0, "除外")
            check_testcase_skipped(
              testsuite.elements["testcase[@name='test_pending()']"],
              "", 0, "保留")
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

          def check_testcase_success(testcase, class_name, assertions)
            assert_equal(class_name, testcase.attribute("classname").value)
            assert_equal(assertions.to_s, testcase.attribute("assertions").value)
            assert_compare(0, "<", Float(testcase.attribute("time").value))

            assert_equal(0, testcase.get_elements("failure").size)
            assert_equal(0, testcase.get_elements("error").size)
            assert_equal(0, testcase.get_elements("skipped").size)
          end

          def check_testcase_failure(testcase, class_name, assertions, message = nil)
            assert_equal(class_name, testcase.attribute("classname").value)
            assert_equal(assertions.to_s, testcase.attribute("assertions").value)
            assert_compare(0, "<", Float(testcase.attribute("time").value))

            failures = testcase.get_elements("failure")
            assert_equal(1, failures.size)
            assert_match(message, failures.first.attribute("message").to_s) if message
            assert_true(failures.first.has_text?)

            assert_equal(0, testcase.get_elements("error").size)
            assert_equal(0, testcase.get_elements("skipped").size)
          end

          def check_testcase_error(testcase, class_name, assertions, message = nil)
            assert_equal(class_name, testcase.attribute("classname").value)
            assert_equal(assertions.to_s, testcase.attribute("assertions").value)
            assert_compare(0, "<", Float(testcase.attribute("time").value))

            errors = testcase.get_elements("error")
            assert_equal(1, errors.size)
            assert_match(message, errors.first.attribute("message").to_s) if message
            assert_not_nil(errors.first.attribute("type"))
            assert_true(errors.first.has_text?)

            assert_equal(0, testcase.get_elements("failure").size)
            assert_equal(0, testcase.get_elements("skipped").size)
          end

          def check_testcase_skipped(testcase, class_name, assertions, message = nil)
            assert_equal(class_name, testcase.attribute("classname").value)
            assert_equal(assertions.to_s, testcase.attribute("assertions").value)
            assert_compare(0, "<", Float(testcase.attribute("time").value))

            failures = testcase.get_elements("skipped")
            assert_equal(1, failures.size)
            assert_match(message, failures.first.attribute("message").to_s) if message

            assert_equal(0, testcase.get_elements("failure").size)
            assert_equal(0, testcase.get_elements("error").size)
          end
        end
      end
    end
  end
end
