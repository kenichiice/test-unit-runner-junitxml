require "test/unit/autorunner"

module Test
  module Unit
    AutoRunner.register_runner(:junitxml) do |auto_runner|
      require 'test/unit/ui/junitxml/testrunner'
      Test::Unit::UI::JUnitXml::TestRunner
    end

    AutoRunner.setup_option do |auto_runner, opts|
      opts.on("--junitxml-output-file=FILE_NAME",
              "Outputs to FILE_NAME") do |name|
        auto_runner.runner_options[:junitxml_output_file] = name
      end

      opts.on("--junitxml-encoding=ENCODING",
              "Uses ENCODING as XML encoding",
              "(default is UTF-8)") do |enc|
        auto_runner.runner_options[:junitxml_encoding] = enc
      end
    end
  end
end
