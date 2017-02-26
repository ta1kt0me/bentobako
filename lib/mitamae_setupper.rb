require "mitamae_setupper/version"
require "open-uri"

module MitamaeSetupper
  def self.run
    Runner.new.run
  end

  class Runner
    SETUP_PATH = 'setup'
    MITAMAE_PATH = SETUP_PATH + "/mitamae"
    LATEST_MITAMAE_URL = "https://github.com/k0kubun/mitamae/releases/latest"

    def run
      Dir.mkdir SETUP_PATH unless Dir.exist? SETUP_PATH
      setup_mitamae
    end

    private

    def setup_mitamae
      File.open(MITAMAE_PATH, "wb") do |file|
        file.write open(LATEST_MITAMAE_URL).read
      end

      File.chmod(0755, MITAMAE_PATH)
    end
  end
end
