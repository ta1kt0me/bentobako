require "mitamae_setupper/version"

module MitamaeSetupper
  SETUP_PATH = 'setup'
  def self.run
    Dir.mkdir SETUP_PATH unless Dir.exist? SETUP_PATH
  end
end
