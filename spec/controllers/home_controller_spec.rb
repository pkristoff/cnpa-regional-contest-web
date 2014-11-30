require 'spec_helper'
require 'json'


describe HomeController, :type => :controller do

  before(:each) do
    cleanup_dirs_and_files('TestContest')
    Dir.mkdir('TestContest')
    # Dir.mkdir('TestContest/q1')
    # Dir.mkdir('TestContest/q1/Testdata')
    # Dir.mkdir('TestContest/q1/Originals')
  end

  describe "GET 'contest'" do
    it "returns an error if contest dir does not exist" do
      stub_const('HomeController::ROOT_FOLDER', 'TestContest')
      get :contest, :name => 'q1'
      response.status.should == 500
      response.body.should == 'could not find path: TestContest/q1/Testdata'
    end
    it "returns an error if contest dir does not exist" do
      Dir.mkdir('TestContest/q1')
      stub_const('HomeController::ROOT_FOLDER', 'TestContest')
      get :contest, :name => 'q1'
      response.status.should == 500
      response.body.should == 'could not find path: TestContest/q1/Testdata'
    end
    it "returns empty filename info" do
      Dir.mkdir('TestContest/q1')
      Dir.mkdir('TestContest/q1/Testdata')
      Dir.mkdir('TestContest/q1/Originals')
      stub_const('HomeController::ROOT_FOLDER', 'TestContest')
      get :contest, :name => 'q1'
      response.status.should == 200
      response.body.should == {
          :filenames => [],
          directories: ['Originals', 'Testdata'],
          directory: 'Testdata'
      }.to_json
    end
  end

  describe "POST 'create_contest'" do
    it "returns an error if contest dir does not exist" do
      stub_const('HomeController::ROOT_FOLDER', 'TestContest')
      get :create_contest, :name => 'q1'
      response.status.should == 200
      response.body.should == {
          :filenames => [],
          directories: ['Originals', 'Testdata'],
          directory: 'Testdata'
      }.to_json
    end
  end

  describe "POST 'delete_file'" do
    it "returns  empty file info + creates: TestContest/q1/Testdata & TestContest/q1/Originals" do
      stub_const('HomeController::ROOT_FOLDER', 'TestContest')
      Dir.mkdir('TestContest/q1')
      Dir.mkdir('TestContest/q1/Testdata')
      Dir.mkdir('TestContest/q1/Originals')
      copy_file(TEST_FILENAME_1, 'Testdata')
      copy_file(TEST_FILENAME_1, 'Originals')

      get :delete_file, :contestName => 'q1', :filename => TEST_FILENAME_1, :directory => 'Testdata'

      response.status.should == 200
      response.body.should == {
          :filenames => [],
          directories: ['Originals', 'Testdata'],
          directory: 'Testdata'
      }.to_json
    end
  end

  describe "GET 'directory'" do
    it "returns  content from specified dir" do
      stub_const('HomeController::ROOT_FOLDER', 'TestContest')
      Dir.mkdir('TestContest/q1')
      Dir.mkdir('TestContest/q1/Testdata')
      Dir.mkdir('TestContest/q1/Originals')
      copy_file(TEST_FILENAME_1, 'Testdata')
      # nothing in original to show diff

      get :directory, :name => 'q1', :directory => 'Testdata'

      response.status.should == 200
      response.body.should == {
          :filenames => [TEST_FILFENAME_1_INFO],
          directories: ['Originals', 'Testdata'],
          directory: 'Testdata'
      }.to_json

      get :directory, :name => 'q1', :directory => 'Originals'

      response.status.should == 200
      response.body.should == {
          :filenames => [],
          directories: ['Originals', 'Testdata'],
          directory: 'Originals'
      }.to_json
    end
  end

  describe "GET 'get_contests'" do
    it "returns q1" do
      stub_const('HomeController::ROOT_FOLDER', 'TestContest')
      Dir.mkdir('TestContest/q1')
      Dir.mkdir('TestContest/q1/Testdata')
      Dir.mkdir('TestContest/q1/Originals')

      get :get_contests

      response.status.should == 200
      response.body.should == ['q1'].to_json
    end
  end

  describe "POST 'set_copyright'" do
    it "returns copyright" do
      stub_const('HomeController::ROOT_FOLDER', 'TestContest')
      Dir.mkdir('TestContest/q1')
      Dir.mkdir('TestContest/q1/Testdata')
      Dir.mkdir('TestContest/q1/Originals')
      copy_file(TEST_FILENAME_1, 'Testdata')
      copy_file(TEST_FILENAME_1, 'Originals')

      get :set_copyright, :contestName => 'q1', :filename => TEST_FILENAME_1, :copyright => 'xxx'

      response.status.should == 200
      response.body.should == 'xxx'
    end
  end

  after(:each) do
    cleanup_dirs_and_files('TestContest')
  end

end



def copy_file(filename, dir)
  file_path = "spec/test_data/#{filename}"
  File.open(file_path, 'r') do |from_file|
    File.open("TestContest/q1/#{dir}/#{filename}", "wb") { |to_file| to_file.write(from_file.read) }
  end
end

def cleanup_dirs_and_files path
  if Dir.exists? path and !path.end_with?('.') and !path.end_with?('..')
    if File.directory? path
      Dir.foreach(path) do |entry|
        file_path = File.join(path, entry)
        cleanup_dirs_and_files(file_path)
      end
      Dir.rmdir(path)
    end
  else
    if File.exists? path and !path.end_with?('.') and !path.end_with?('..')
      File.delete(path)
    end
  end
end
