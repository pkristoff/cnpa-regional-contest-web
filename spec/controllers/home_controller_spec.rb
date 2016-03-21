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
    it 'returns an error if contest dir does not exist' do
      stub_const('HomeHelper::ROOT_FOLDER', 'TestContest')
      get :contest, :name => 'q1'
      response.body.should == '{"message":"could not find path: TestContest/q1/Testdata"}'
      response.status.should == 500
    end
    it 'returns an error if contest dir does not exist' do
      Dir.mkdir('TestContest/q1')
      stub_const('HomeHelper::ROOT_FOLDER', 'TestContest')
      get :contest, :name => 'q1'
      response.body.should == '{"message":"could not find path: TestContest/q1/Testdata"}'
      response.status.should == 500
    end
    it 'returns empty filename info' do

      setup_contest false

      get :contest, :name => 'q1'

      response.status.should == 200
      response.body.should == {
          :filenames => [],
          directories: %w(Originals Testdata),
          directory: 'Testdata',
          hasGeneratedContest: [false],
          email: 'foo@bar.com',
          isPictureAgeRequired: false,
          pictureAgeDate: "#{Date.today}"
      }.to_json
    end
  end

  describe "POST 'create_contest'" do
    it 'returns an error if contest dir does not exist' do
      stub_const('HomeHelper::ROOT_FOLDER', 'TestContest')
      get :create_contest, :name => 'q1'
      response.status.should == 200
      response.body.should == {
          :filenames => [],
          directories: %w(Originals Testdata),
          directory: 'Testdata',
          hasGeneratedContest: false,
          email: 'foo@bar.com',
          isPictureAgeRequired: false,
          pictureAgeDate: "#{Date.today}"
      }.to_json
    end
  end

  describe "POST 'delete_file'" do
    it 'returns  empty file info + creates: TestContest/q1/Testdata & TestContest/q1/Originals' do

      setup_contest

      get :delete_file, :contestName => 'q1', :filename => TEST_FILENAME_1, :directory => 'Testdata'

      response.status.should == 200
      response.body.should == {
          :filenames => [],
          directories: %w(Originals Testdata),
          directory: 'Testdata'
      }.to_json
      HomeFileModule.get_file_info('q1', TEST_FILENAME_1, 'TestContest').nil?.should == true
    end
    it 'deletes a renamed file & returns  empty file info + creates: TestContest/q1/Testdata & TestContest/q1/Originals' do

      setup_contest

      new_file_name = 'Paul new - New Medow.jpg'
      get :rename_file, :contestName => 'q1', :old_filename => TEST_FILENAME_1, :new_filename => new_file_name, :directory => 'Testdata'

      get :delete_file, :contestName => 'q1', :filename => new_file_name, :directory => 'Testdata'

      response.body.should == {
          :filenames => [],
          directories: %w(Originals Testdata),
          directory: 'Testdata'
      }.to_json
      response.status.should == 200
      HomeFileModule.get_file_info('q1', TEST_FILENAME_1, 'TestContest').nil?.should == true
    end
  end

  describe "GET 'directory'" do
    it 'returns  content from specified dir' do

      setup_contest

      get :directory, :name => 'q1', :directory => 'Testdata'

      response.status.should == 200
      response.body.should == {
          :filenames => [TEST_FILE_INFO_TESTDATA],
          directories: %w(Originals Testdata),
          directory: 'Testdata',
          hasGeneratedContest: [false],
          email: 'foo@bar.com',
          isPictureAgeRequired: false,
          pictureAgeDate: "#{Date.today}"
      }.to_json

      get :directory, :name => 'q1', :directory => 'Originals'

      response.status.should == 200
      response.body.should == {
          :filenames => [TEST_FILE_INFO_ORIGINALS],
          directories: %w(Originals Testdata),
          directory: 'Originals',
          hasGeneratedContest: [false],
          email: 'foo@bar.com',
          isPictureAgeRequired: false,
          pictureAgeDate: "#{Date.today}"
      }.to_json
    end
  end

  describe "GET 'get_contests'" do
    it 'returns q1' do

      setup_contest false

      get :get_contests

      response.status.should == 200
      response.body.should == ['q1'].to_json
    end
  end

  describe "POST 'set_copyright'" do
    it 'returns copyright' do

      setup_contest

      get :set_copyright, :contestName => 'q1', :filename => TEST_FILENAME_1, :copyright => 'xxx'

      response.status.should == 200
      response.body.should == 'xxx'
    end
  end

  after(:each) do
    cleanup_dirs_and_files('TestContest')
  end

  def setup_contest(should_copy_file=true)
    stub_const('HomeHelper::ROOT_FOLDER', 'TestContest')

    Dir.mkdir('TestContest/q1')
    Dir.mkdir('TestContest/q1/Testdata')
    Dir.mkdir('TestContest/q1/Originals')

    files_info = []

    if should_copy_file
      copy_file(TEST_FILENAME_1, 'Testdata')
      copy_file(TEST_FILENAME_1, 'Originals')
      files_info = [{
                        :filename => TEST_FILENAME_1,
                        :original_filename => TEST_FILENAME_1,
                        :imageWidth => 1024,
                        :imageHeight => 683,
                        :copyrightNotice => 'Paul Kristoff',
                        :title => 'Grassland',
                        :dateCreated => '2012-01-15',
                        :fileSize => 249
                    }]
    end

    HomeFileModule.save_files_info files_info, 'q1', 'TestContest'
  end

end


def copy_file(filename, dir)
  file_path = "spec/test_data/#{filename}"
  File.open(file_path, 'r') do |from_file|
    File.open("TestContest/q1/#{dir}/#{filename}", 'wb') { |to_file| to_file.write(from_file.read) }
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
    else
      if File.exists? path and !path.end_with?('.') and !path.end_with?('..')
        File.delete(path)
      end
    end
  end
end
