require 'test_helper'
require 'yaml'

class MitamaeSetupperTest < Minitest::Test
  def setup
    @root_path = Dir.pwd
    @sandbox_path = @root_path + '/test/sandbox'
    Dir.mkdir @sandbox_path
    Dir.chdir @sandbox_path

    stub_request(:get, MitamaeSetupper::Runner::LATEST_MITAMAE_URL)
      .to_return(body: File.new(@root_path + "/test/fixtures/sample.bin"), status: 200)
  end

  def teardown
    Dir.chdir @root_path
    FileUtils.rm_rf @sandbox_path
  end

  def test_that_it_has_a_version_number
    refute_nil ::MitamaeSetupper::VERSION
  end

  def test_that_create_setup_directory
    ::MitamaeSetupper.run
    assert Dir.exist?(@sandbox_path + "/setup")

    ::MitamaeSetupper.run
    assert Dir.exist?(@sandbox_path + "/setup")
  end

  def test_that_download_latest_mitamae_into_setup
    ::MitamaeSetupper.run
    assert File.executable?(@sandbox_path + "/setup/mitamae")
  end

  def test_that_specify_user_into_node_user
    ::MitamaeSetupper::Runner.new(["--user=James"]).run
    assert File.exist?(@sandbox_path + "/setup/node.yaml")

    data = YAML.load(File.new(@sandbox_path + "/setup/node.yaml").read)
    assert data[:user] == "James"
  end

  def test_that_use_homebrew_as_package_manager
    ::MitamaeSetupper::Runner.new(["--homebrew"]).run
    assert File.exist?(@sandbox_path + "/setup/bootstrap.rb")
    assert File.open(@sandbox_path + "/setup/bootstrap.rb").read.include?("require_recipe './recipes/homebrew.rb'\n")
    assert File.open(@sandbox_path + "/setup/recipes/homebrew.rb").read.include?("Install Homebrew")
  end

  def test_that_setup_packages_for_rails
    assert false
  end
end
