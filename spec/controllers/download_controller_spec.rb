require 'spec_helper'

describe DownloadController, :type => :controller do

  before(:each) do
    cleanup_dirs_and_files('TestContest')
  end

  describe "GET 'download_contest'" do
    it 'returns http success' do
      Dir.mkdir('TestContest')

      stub_const('HomeHelper::ROOT_FOLDER', 'TestContest')

      get 'download_contest', :contestName => 'q1'
      response.should be_success

      assert_generated_contest('q1', false)
    end
  end

  describe "GET 'download_contest'" do
    it 'returns http success' do

      setup_contest

      stub_const('HomeHelper::ROOT_FOLDER', 'TestContest')

      get 'download_contest', :contestName => 'q1'
      response.should be_success
      response.header['Content-Disposition'].should eq('attachment; filename="contest.zip"')
      response.content_type.should eq('application/zip')

      assert_generated_contest('q1', true)
    end
  end

end
