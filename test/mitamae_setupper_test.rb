require 'test_helper'

class MitamaeSetupperTest < Minitest::Test
  def setup
    @root_path = Dir.pwd
    @sandbox_path = @root_path + '/test/sandbox'
    Dir.mkdir @sandbox_path
    Dir.chdir @sandbox_path
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

  def test_that_create_node_yaml_into_setup
    assert false
  end

  def test_that_specify_user_into_node_user
    assert false
  end

  def test_that_create_bootstrap_file_into_setup
    assert false
  end

  def test_that_use_homebrew_as_package_manager
    assert false
  end

  def test_that_setup_packages_for_rails
    assert false
  end
end
