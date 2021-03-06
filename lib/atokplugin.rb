require "atokplugin/version"
require "erb"
require "yaml"
require "ostruct"

module ATOKPlugin
  require "atokplugin/cli"

  module_function
  def check_environment
    unless ENV["ATOK_TOOLS_ROOT"]
      STDERR.puts(
        "!!! Cannot locate ATOK Direct API module !!!",
        "Please download ATOK Direct API module from",
        "  http://www.atok.com/useful/developer/api/",
        "and set path to ATOK_TOOLS_ROOT env"
      )
      exit 1
    end
  end

  def tools_path
    @tools_root ||= ENV["ATOK_TOOLS_ROOT"]
  end

  def sample_source_path(ext)
    lang = case ext
    when "rb"
      "ruby"
    when "py"
      "python"
    when "pl"
      "perl"
    end
    "#{tools_path}/Samples/script_#{lang}_sample/DATA/atok_direct_script_#{lang}_sample.#{ext}"
  end

  def debugger_path
    "#{tools_path}/atok_direct_debugger/atok_direct_script_plugin_test.app"
  end

  def debugger_filename
    File.basename(debugger_path)
  end

  def installer_path
    "#{tools_path}/atok_direct_setuptool/atok_plugin_installer.app"
  end

  def installer_filename
    File.basename(installer_path)
  end

  def render_template(filename, variables)
    b = OpenStruct.new(variables).instance_eval{ binding }
    template(filename).result(b)
  end

  def template(filename)
    ERB.new(File.read("#{template_path}/#{filename}"))
  end

  def template_path
    @template_path ||= "#{__dir__}/../template"
  end

  def config
    @config ||= begin
      unless File.exists?("atokplugin.yml")
        STDERR.puts "Cannot locate atokplugin.yml"
        exit 1
      end
      YAML.load_file("atokplugin.yml")
    end
  end
end
