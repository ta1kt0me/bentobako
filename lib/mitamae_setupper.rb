require "mitamae_setupper/version"
require "open-uri"
require "optparse"

module MitamaeSetupper
  def self.run
    Runner.new(ARGV).run
  end

  class Runner
    SETUP_PATH = 'setup'
    MITAMAE_PATH = SETUP_PATH + "/mitamae"
    LATEST_MITAMAE_URL = "https://github.com/k0kubun/mitamae/releases/latest"
    NODE_PATH = SETUP_PATH + "/node.yaml"

    attr_accessor :options

    def initialize(args)
      @args = args
      @options = {}
    end

    def run
      Dir.mkdir SETUP_PATH unless Dir.exist? SETUP_PATH
      setup_mitamae
      setup_node_config
    end

    def setup_node_config
      parse_options
      File.open(NODE_PATH, "wb") do |file|
        file.write YAML.dump(options)
      end
    end

    private

    def setup_mitamae
      File.open(MITAMAE_PATH, "wb") do |file|
        file.write open(LATEST_MITAMAE_URL).read
      end

      File.chmod(0755, MITAMAE_PATH)
    end

    def parse_options
      opt_parser = OptionParser.new do |opt|
        opt.banner = "Usage: mitamae_wrapper [options]"
        opt.on("--user=NAME", "executor user name")  { |user| options[:user] = user }
      end

      opt_parser.parse!(@args)
    end
  end
end
