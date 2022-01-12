[[English](README.md)]

[![Test](https://github.com/kenichiice/test-unit-runner-junitxml/workflows/Test/badge.svg)](https://github.com/kenichiice/test-unit-runner-junitxml/actions?query=workflow%3ATest+branch%3Amaster)

# Test::Unit::Runner::JUnitXml

Test::Unit::Runner::JUnitXml は [test-unit](https://github.com/test-unit/test-unit) のテスト結果をJUnit XML形式で出力するライブラリです。

## インストール方法

    $ gem install test-unit-runner-junitxml

## 使い方

`test/unit/runner/junitxml.rb` をロードすると、テストスクリプトの `--runner` オプションに `junitxml` を指定できるようになります。これを指定すると、テスト結果がJUnit XML形式で出力されるようになります。

また、 `--junitxml-output-file` オプションも追加され、このオプションで指定したファイルにテスト結果を出力することができるようになります。

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
	<testsuite name="MyTest" tests="1" errors="0" failures="1" skipped="0" time="0.005365">
		<testcase classname="MyTest" name="test_1(MyTest)" time="0.0053308" assertions="1">
			<failure message="&lt;1&gt; expected but was
&lt;2&gt;.">Failure:
test_1(MyTest) [test.rb:7]:
&lt;1&gt; expected but was
&lt;2&gt;.</failure>
			<system-out>hello</system-out>
		</testcase>
	</testsuite>
</testsuites>
```

## オプション

* --junitxml-output-file=FILE_NAME
  * XMLを、標準出力ではなく指定したファイルへ出力します。
* --junitxml-disable-output-capture
  * 標準出力と標準エラー出力のキャプチャを行わないようになります。

## ライセンス

[MIT License](https://opensource.org/licenses/MIT)
