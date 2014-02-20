require "fileutils"
require "erb"
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

      puts "Create: #{name}/#{name}.xml"
      metadata = ATOKPlugin.template("metadata.xml.erb").result(binding)
      File.write("#{name}/#{name}.xml", metadata)
    end

    desc "debug", "Launch debugger"
    def debug
      Dir.mktmpdir do |tmp|
        puts "Create temporary directory: #{tmp}"
        cp_r ATOKPlugin.debugger_path, tmp
        mkdir "#{tmp}/plugin"
        # ln_s does not work
        ln source_filename, "#{tmp}/plugin/#{source_filename}"
        system "open --wait-apps #{tmp}/#{ATOKPlugin.debugger_filename}"
      end
    end

    desc "install", "Install plugin"
    def install
      Dir.mktmpdir do |tmp|
        puts "Create temporary directory: #{tmp}"
        cp_r ATOKPlugin.installer_path, tmp
        mkdir "#{tmp}/DATA"
        cp source_filename, "#{tmp}/DATA/#{source_filename}"
        cp metadata_filename, "#{tmp}/DATA/#{metadata_filename}"
        cp "LICENSE.TXT", "#{tmp}/LICENSE.TXT"

        setupinfo = ATOKPlugin.template("setupinfo.xml.erb").result(binding)
        File.write("#{tmp}/SETUPINFO.XML", setupinfo)

        system "open --wait-apps #{tmp}/#{ATOKPlugin.installer_filename}"
      end
    end

    private
    def source_filename
      @source_filename ||= Dir.glob("*.{rb,py,pl}").to_a[0]
    end

    def metadata_filename
      @metadata_filename ||= Dir.glob("*.xml").to_a[0]
    end
  end
end
