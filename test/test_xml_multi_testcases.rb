require "stringio"
require 'rexml/document'
require "test/unit"
require "test/unit/ui/junitxml/testrunner"
require_relative "check"

class TestXmlMultiTestcases < Test::Unit::TestCase
  include Check

  setup do
    test_case1 = Class.new(Test::Unit::TestCase) do
      test "success" do
        assert_equal(1, 1)
      end
    end

    test_case2 = Class.new(Test::Unit::TestCase) do
      test "failure" do
        assert_equal(1, 2)
      end
    end

    output = StringIO.new
    suite = Test::Unit::TestSuite.new
    suite << test_case1.suite << test_case2.suite
    runner = Test::Unit::UI::JUnitXml::TestRunner.new(
      suite, :output => output)
    runner.start

    output.rewind
    @doc = REXML::Document.new(output)
  end

  test "testsuites" do
    testsuites_array = @doc.get_elements("/testsuites")
    assert_equal(1, testsuites_array.size)
  end

  test "testsuite" do
    testsuite_array = @doc.get_elements("/testsuites/testsuite")
    assert_equal(2, testsuite_array.size)
    check_testsuite(testsuite_array[0], "", 1, 0, 0, 0)
    check_testsuite(testsuite_array[1], "", 1, 0, 1, 0)
  end

  test "testcase success" do
    testcase_array = @doc.get_elements(
      "/testsuites/testsuite/testcase[@name='success']")
    assert_equal(1, testcase_array.size)
    check_testcase_success(testcase_array.first, "", 1)
  end

  test "testcase failure" do
    testcase_array = @doc.get_elements(
      "/testsuites/testsuite/testcase[@name='failure']")
    assert_equal(1, testcase_array.size)
    check_testcase_failure(testcase_array.first, "", 1)
  end
end
