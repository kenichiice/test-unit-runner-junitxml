[[日本語](README.ja.md)]

[![Test](https://github.com/kenichiice/test-unit-runner-junitxml/workflows/Test/badge.svg)](https://github.com/kenichiice/test-unit-runner-junitxml/actions?query=workflow%3ATest+branch%3Amaster)

# Test::Unit::Runner::JUnitXml

Test::Unit::Runner::JUnitXml is a [test-unit](https://github.com/test-unit/test-unit) runner that reports test result in JUnit XML format.

## Installation

    $ gem install test-unit-runner-junitxml

## Usage

By loading `test/unit/runner/junitxml.rb`, you can select `junitxml` runner via the `--runner` command line option of test script. This runner reports test result in JUnit XML format.

In addition, `--junitxml-output-file` command line option is added, and it becomes possible to output the test result to the file specified by this option.

```ruby
# test.rb
require "test/unit/runner/junitxml"

class MyTest < Test::Unit::TestCase
  def test_1
    print("hello")
    assert_equal(1, 2)
  end
end
```

```
$ ruby test.rb --runner=junitxml --junitxml-output-file=result.xml
$ cat result.xml
<?xml version="1.0" encoding="UTF-8" ?>
<testsuites>
	<testsuite name="MyTest" tests="1" errors="0" failures="1" skipped="0" time="0.0047083">
		<testcase classname="MyTest" name="test_1(MyTest)" time="0.0046712" assertions="1">
			<failure message="&lt;1&gt; expected but was
&lt;2&gt;.">
Failure:
test_1(MyTest) [test.rb:7]:
&lt;1&gt; expected but was
&lt;2&gt;.
			</failure>
			<system-out>hello</system-out>
		</testcase>
	</testsuite>
</testsuites>
```

## Options

* --junitxml-output-file=FILE_NAME
  * Output XML to the specified file instead of the standard output.
* --junitxml-disable-output-capture
  * Disable capture of standard output and standard error.

## License

[MIT License](https://opensource.org/licenses/MIT)
