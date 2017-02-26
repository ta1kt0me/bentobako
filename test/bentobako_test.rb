require 'test_helper'

class BentobakoTest < Minitest::Test
  def setup
    @root_path = Dir.pwd
    @sandbox_path = @root_path + '/test/sandbox'
    Dir.mkdir @sandbox_path
    Dir.chdir @sandbox_path

    stub_request(:get, Bentobako::Runner::LATEST_MITAMAE_URL)
      .to_return(body: File.new(@root_path + "/test/fixtures/sample.bin"), status: 200)
  end

  def teardown
    Dir.chdir @root_path
    FileUtils.rm_rf @sandbox_path
  end

  def test_that_it_has_a_version_number
    refute_nil ::Bentobako::VERSION
  end

  def test_that_create_setup_directory
    ::Bentobako.run
    assert Dir.exist?(@sandbox_path + "/setup")

    ::Bentobako.run
    assert Dir.exist?(@sandbox_path + "/setup")
  end

  def test_that_download_latest_mitamae_into_setup
    ::Bentobako.run
    assert File.executable?(@sandbox_path + "/setup/mitamae")
  end

  def test_that_specify_user_into_node_user
    ::Bentobako::Runner.new(["--user=James"]).run
    assert File.exist?(@sandbox_path + "/setup/node.yaml")

    data = YAML.load(File.new(@sandbox_path + "/setup/node.yaml").read)
    assert data["user"] == "James"
  end

  def test_that_use_homebrew_as_package_manager
    ::Bentobako::Runner.new(["--homebrew"]).run
    assert File.exist?(@sandbox_path + "/setup/bootstrap.rb")
    assert File.open(@sandbox_path + "/setup/bootstrap.rb").read.include?("include_recipe './recipes/homebrew.rb'\n")
    assert File.open(@sandbox_path + "/setup/recipes/homebrew.rb").read.include?("Install Homebrew")
  end

  def test_that_setup_packages_for_rails
    ::Bentobako::Runner.new(["--rails"]).run
    assert File.open(@sandbox_path + "/setup/bootstrap.rb").read.include?("include_recipe './recipes/gems.rb'\n")
    assert File.open(@sandbox_path + "/setup/recipes/gems.rb").read.include?('gem_package')
    assert File.open(@sandbox_path + "/setup/bootstrap.rb").read.include?("include_recipe './recipes/packages.rb'\n")
    assert File.open(@sandbox_path + "/setup/recipes/packages.rb").read.include?('package')
    data = YAML.load(File.new(@sandbox_path + "/setup/node.yaml").read)
    assert data["gems"] == %w(bundler)
    assert data["packages"].sort == %w(git ruby).sort
  end
end
