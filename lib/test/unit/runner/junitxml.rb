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
      opts.on("--junitxml-disable-output-capture",
              "Disable output capture") do |b|
        auto_runner.runner_options[:junitxml_disable_output_capture] = b
      end
    end
  end
end
