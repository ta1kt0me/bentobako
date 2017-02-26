require "mitamae_setupper/version"

module MitamaeSetupper
  SETUP_PATH = 'setup'
  def self.run
    Runner.new.run
  end

  class Runner
    def run
      Dir.mkdir SETUP_PATH unless Dir.exist? SETUP_PATH
    end
  end
end
