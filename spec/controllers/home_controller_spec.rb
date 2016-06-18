require 'spec_helper'
require 'json'


describe HomeController, :type => :controller do

  before(:each) do
    cleanup_dirs_and_files('TestContest')
  end

  describe "GET 'contest'" do
    it 'returns an error if contest dir does not exist' do
      stub_const('HomeHelper::ROOT_FOLDER', 'TestContest')
      get :contest, :name => 'q1'
      expect(response.body).to eq('{"message":"could not find path: TestContest/q1/Testdata"}')
      expect(response.status).to eq(500)
    end
    it 'returns an error if contest dir does not exist' do
      Dir.mkdir('TestContest')
      Dir.mkdir('TestContest/q1')
      stub_const('HomeHelper::ROOT_FOLDER', 'TestContest')
      get :contest, :name => 'q1'
      expect(response.body).to eq('{"message":"could not find path: TestContest/q1/Testdata"}')
      expect(response.status).to eq(500)
    end
    it 'returns empty filename info' do

      setup_contest false

      get :contest, :name => 'q1'

      expect(response.status).to eq(200)
      expect(response.body).to eq({
          :filenames => [],
          directories: %w(Originals Testdata),
          directory: 'Testdata',
          hasGeneratedContest: [false],
          isPictureAgeRequired: false,
          pictureAgeDate: "#{Date.today}"
      }.to_json)
    end
  end

  describe "POST 'create_contest'" do
    it 'returns an error if contest dir does not exist' do
      stub_const('HomeHelper::ROOT_FOLDER', 'TestContest')
      get :create_contest, :name => 'q1'
      expect(response.status).to eq(200)
      expect(response.body).to eq({
          :filenames => [],
          directories: %w(Originals Testdata),
          directory: 'Testdata',
          hasGeneratedContest: false,
          isPictureAgeRequired: false,
          pictureAgeDate: "#{Date.today}"
      }.to_json)
    end
  end

  describe "POST 'delete_file'" do
    it 'returns  empty file info + creates: TestContest/q1/Testdata & TestContest/q1/Originals' do

      setup_contest

      get :delete_file, :contestName => 'q1', :filename => TEST_FILENAME_1, :directory => 'Testdata'

      expect(response.body).to eq({
          :filenames => [],
          directories: %w(Originals Testdata),
          directory: 'Testdata'
      }.to_json)
      expect(response.status).to eq(200)
      expect(HomeFileModule.get_file_info('q1', TEST_FILENAME_1, 'TestContest').nil?).to eq(true)
    end

    it 'deletes a renamed file & returns  empty file info + creates: TestContest/q1/Testdata & TestContest/q1/Originals' do

      setup_contest

      new_file_name = 'Paul new - New Medow.jpg'
      get :rename_file, :contestName => 'q1', :old_filename => TEST_FILENAME_1, :new_filename => new_file_name, :directory => 'Testdata'

      get :delete_file, :contestName => 'q1', :filename => new_file_name, :directory => 'Testdata'

      expect(response.body).to eq({
          :filenames => [],
          directories: %w(Originals Testdata),
          directory: 'Testdata'
      }.to_json)
      expect(response.status).to eq(200)
      expect(HomeFileModule.get_file_info('q1', TEST_FILENAME_1, 'TestContest').nil?).to eq(true)
    end
  end

  describe "GET 'directory'" do
    it 'returns  content from specified dir' do

      setup_contest

      get :directory, :name => 'q1', :directory => 'Testdata'

      expect(response.status).to eq(200)
      expect(response.body).to eq({
          :filenames => [TEST_FILE_INFO_TESTDATA],
          directories: %w(Originals Testdata),
          directory: 'Testdata',
          hasGeneratedContest: [false],
          isPictureAgeRequired: false,
          pictureAgeDate: "#{Date.today}"
      }.to_json)

      get :directory, :name => 'q1', :directory => 'Originals'

      expect(response.status).to eq(200)
      expect(response.body).to eq({
          :filenames => [TEST_FILE_INFO_ORIGINALS],
          directories: %w(Originals Testdata),
          directory: 'Originals',
          hasGeneratedContest: [false],
          isPictureAgeRequired: false,
          pictureAgeDate: "#{Date.today}"
      }.to_json)
    end
  end

  describe "GET 'get_contests'" do
    it 'returns q1' do

      setup_contest false

      get :get_contests

      expect(response.status).to eq(200)
      expect(response.body).to eq(['q1'].to_json)
    end
  end

  describe "POST 'set_copyright'" do
    it 'returns copyright' do

      setup_contest

      get :set_copyright, :contestName => 'q1', :filename => TEST_FILENAME_1, :copyright => 'xxx'

      expect(response.status).to eq(200)
      expect(response.body).to eq('xxx')
    end
  end

  after(:each) do
    cleanup_dirs_and_files('TestContest')
  end

end
