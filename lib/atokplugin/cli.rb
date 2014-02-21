require "thor"
require "fileutils"
require "tmpdir"

module ATOKPlugin
  class CLI < Thor
    include FileUtils

    def initialize(*args)
      super
      ATOKPlugin.check_environment
    end

    desc "new PLUGIN_NAME", "Create new plugin"
    option :lang
    def new(name)
      ext = case options[:lang]
      when nil, "rb", "ruby"
        "rb"
      when "py", "python"
        "py"
      when "pl", "perl"
        "pl"
      else
        STDERR.puts "Unrecognized language: #{options[:lang].inspect}"
        exit 1
      end

      puts "Create plugin directory: #{name}"
      if File.exists?(name)
        STDERR.puts "#{name} already exists"
        exit 1
      end
      mkdir name

      puts "Copy plugin template: #{name}/#{name}.#{ext}"
      cp ATOKPlugin.sample_source_path(ext), "#{name}/#{name}.#{ext}"

      puts "Create: #{name}/LICENSE.TXT"
      touch "#{name}/LICENSE.TXT"

      puts "Create: #{name}/atokplugin.yml"
      config_file = ATOKPlugin.render_template("atokplugin.yml.erb", source: "#{name}.#{ext}", name: name)
      File.write("#{name}/atokplugin.yml", config_file)

      puts "Create: #{name}/.gitignore"
      File.write("#{name}/.gitignore", "pkg\n")

    end

    desc "debug", "Launch debugger"
    def debug
      Dir.mktmpdir do |tmp|
        puts "Create temporary directory: #{tmp}"
        cp_r ATOKPlugin.debugger_path, tmp
        mkdir "#{tmp}/plugin"
        # ln_s does not work
        ln source_filename, "#{tmp}/plugin/#{source_filename}"

        puts "Launch debugger"
        system "open --wait-apps #{tmp}/#{ATOKPlugin.debugger_filename}"
      end
    end

    desc "build", "Build plugin to ./pkg"
    def build
      ATOKPlugin.config
      puts "Remove directory: pkg"
      rm_rf "pkg"
      puts "Create directory: pkg"
      mkdir "pkg"

      cp_r ATOKPlugin.installer_path, "pkg"
      mkdir "pkg/DATA"
      cp source_filename, "pkg/DATA/#{source_filename}"
      metadata = ATOKPlugin.render_template("metadata.xml.erb", config["plugin_info"])
      File.write("pkg/DATA/#{metadata_filename}", metadata)
      cp "LICENSE.TXT", "pkg/LICENSE.TXT"

      setupinfo = ATOKPlugin.render_template("setupinfo.xml.erb", config["setup_info"].merge(plugin_file_name: config["source"]))
      File.write("pkg/SETUPINFO.XML", setupinfo)

      puts "Build succeeded"
    end

    desc "install", "Install plugin"
    def install
      build
      puts "Launch installer"
      system "open --wait-apps pkg/#{ATOKPlugin.installer_filename}"
    end

    private
    def config
      ATOKPlugin.config
    end

    def source_filename
      @source_filename ||= begin
        unless File.exists?(config["source"])
          STDERR.puts "#{config["source"]} not found.\nCheck atokplugin.yml"
        end
        config["source"]
      end
    end

    def metadata_filename
      @metadata_filename ||= source_filename.gsub(/\.(rb|py|pl)$/, ".xml")
    end
  end
end
