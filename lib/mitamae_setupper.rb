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
    BOOTSTRAP_PATH = SETUP_PATH + "/bootstrap.rb"
    RECIPES_PATH = SETUP_PATH + "/recipes"

    attr_accessor :options

    def initialize(args)
      @args = args
      @options = {}
    end

    def run
      Dir.mkdir SETUP_PATH unless Dir.exist? SETUP_PATH
      Dir.mkdir RECIPES_PATH unless Dir.exist? RECIPES_PATH
      setup_mitamae
      setup_node_config
      setup_bootstrap
      setup_recipes
    end

    private

    def setup_mitamae
      File.open(MITAMAE_PATH, "wb") do |file|
        file.write open(LATEST_MITAMAE_URL).read
      end

      File.chmod(0755, MITAMAE_PATH)
    end

    def setup_node_config
      parse_options
      File.open(NODE_PATH, "wb") do |file|
        file.write YAML.dump(options)
      end
    end

    def setup_recipes
      if options.dig(:homebrew)
        content = <<-EOF
execute "Install Homebrew" do
  user node[:user]
  command 'yes "" | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
end
        EOF
        File.open(RECIPES_PATH + '/homebrew.rb', 'w') do |file|
          file.write(content)
        end
      end
    end

    def setup_bootstrap
      lines = "require_recipe './recipes/homebrew.rb'\n" if options.dig(:homebrew)
      File.open(BOOTSTRAP_PATH, "w") do |file|
        file.write lines
      end
    end

    def parse_options
      opt_parser = OptionParser.new do |opt|
        opt.banner = "Usage: mitamae_wrapper [options]"
        opt.on("--user=NAME", "executor user name")  { |user| options[:user] = user }
        opt.on("--homebrew", "Use homebrew as package manager") { options[:homebrew] = true }
      end

      opt_parser.parse!(@args)
    end
  end
end
