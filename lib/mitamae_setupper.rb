require "mitamae_setupper/version"
require "open-uri"
require "optparse"
require "yaml"

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

    attr_accessor :options, :nodes

    def initialize(args)
      @args = args
      @options = {}
      @nodes = {}
    end

    def run
      Dir.mkdir SETUP_PATH unless Dir.exist? SETUP_PATH
      Dir.mkdir RECIPES_PATH unless Dir.exist? RECIPES_PATH
      setup_mitamae
      parse_options
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
      File.open(NODE_PATH, "wb") do |file|
        file.write YAML.dump(build_nodes)
      end
    end

    def build_nodes
      nodes.merge!(user: options[:user]) if options.dig(:user)
      nodes.merge!(packages: %w(git ruby), gems: %w(bundler)) if options.dig(:rails)
      nodes
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

      if options.dig(:rails)
        File.open(RECIPES_PATH + '/packages.rb', 'w') do |file|
          file.write(
            <<-EOF
node[:packages].each do |item|
  package item
end
            EOF
          )
        end

        File.open(RECIPES_PATH + '/gems.rb', 'w') do |file|
          file.write(
            <<-EOF
node[:gems].each do |gem|
  gem_package gem do
    user node[:user]
  end
end
            EOF
          )
        end

      end
    end

    def setup_bootstrap
      lines = ""
      if options.dig(:homebrew)
        lines += "require_recipe './recipes/homebrew.rb'\n"
      end

      if options.dig(:rails)
        lines += "require_recipe './recipes/packages.rb'\n"
        lines += "require_recipe './recipes/gems.rb'\n"
      end

      File.open(BOOTSTRAP_PATH, "w") { |file| file.write lines }
    end

    def parse_options
      opt_parser = OptionParser.new do |opt|
        opt.banner = "Usage: mitamae_wrapper [options]"
        opt.on("--user=NAME", "executor user name")  { |user| options[:user] = user }
        opt.on("--homebrew", "Use homebrew as package manager") { options[:homebrew] = true }
        opt.on("--rails", "Enable to execute rails") { options[:rails] = true }
      end

      opt_parser.parse!(@args)
    end
  end
end
