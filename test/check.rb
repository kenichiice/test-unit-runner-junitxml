require "test/unit/assertions"

module Check
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
    assert_true(failures.first.has_text?)
    if message
      assert_match(message, failures.first.attribute("message").value)
      assert_match(message, failures.first.text)
    end

    assert_equal(0, testcase.get_elements("error").size)
    assert_equal(0, testcase.get_elements("skipped").size)
  end

  def check_testcase_error(testcase, class_name, assertions, message = nil)
    assert_equal(class_name, testcase.attribute("classname").value)
    assert_equal(assertions.to_s, testcase.attribute("assertions").value)
    assert_compare(0, "<", Float(testcase.attribute("time").value))

    errors = testcase.get_elements("error")
    assert_equal(1, errors.size)
    assert_not_nil(errors.first.attribute("type"))
    assert_true(errors.first.has_text?)
    if message
      assert_match(message, errors.first.attribute("message").value)
      assert_match(message, errors.first.text)
    end

    assert_equal(0, testcase.get_elements("failure").size)
    assert_equal(0, testcase.get_elements("skipped").size)
  end

  def check_testcase_skipped(testcase, class_name, assertions, message = nil)
    assert_equal(class_name, testcase.attribute("classname").value)
    assert_equal(assertions.to_s, testcase.attribute("assertions").value)
    assert_compare(0, "<", Float(testcase.attribute("time").value))

    skipped = testcase.get_elements("skipped")
    assert_equal(1, skipped.size)
    assert_match(message, skipped.first.attribute("message").value) if message

    assert_equal(0, testcase.get_elements("failure").size)
    assert_equal(0, testcase.get_elements("error").size)
  end
end
