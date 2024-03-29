require "stringio"
require 'rexml/document'
require "test/unit"
require "test/unit/ui/junitxml/testrunner"
require_relative "check"

class TestXml < Test::Unit::TestCase
  include Check

  setup do
    test_case = Class.new(Test::Unit::TestCase) do
      test "success" do
        assert_equal(1, 1)
      end

      def test_failure
        assert_equal(1, 1)
        assert_equal(1, 2)
      end

      def test_error
        assert_equal(1, 1)
        assert_equal(1, 1)
        assert_equal(1, 1)
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
    runner = Test::Unit::UI::JUnitXml::TestRunner.new(
      test_case.suite, :output => output)
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
    assert_equal(1, testsuite_array.size)
    check_testsuite(testsuite_array.first, "", 5, 1, 1, 2)
  end

  test "testcase success" do
    testcase_array = @doc.get_elements(
      "/testsuites/testsuite/testcase[@name='success']")
    assert_equal(1, testcase_array.size)
    check_testcase_success(testcase_array.first, "", 1)
  end

  test "testcase failure" do
    testcase_array = @doc.get_elements(
      "/testsuites/testsuite/testcase[@name='test_failure()']")
    assert_equal(1, testcase_array.size)
    check_testcase_failure(testcase_array.first, "", 2, /.+/)
  end

  test "testcase error" do
    testcase_array = @doc.get_elements(
      "/testsuites/testsuite/testcase[@name='test_error()']")
    assert_equal(1, testcase_array.size)
    check_testcase_error(testcase_array.first, "", 3, "hello")
  end

  test "testcase omission" do
    testcase_array = @doc.get_elements(
      "/testsuites/testsuite/testcase[@name='test_omission()']")
    assert_equal(1, testcase_array.size)
    check_testcase_skipped(testcase_array.first, "", 0, /.+/)
  end

  test "testcase pending" do
    testcase_array = @doc.get_elements(
      "/testsuites/testsuite/testcase[@name='test_pending()']")
    assert_equal(1, testcase_array.size)
    check_testcase_skipped(testcase_array.first, "", 0, /.+/)
  end
end
