require 'spec_helper'

describe DownloadController do

  describe "GET 'download_contest'" do
    it "returns http success" do
      get 'download_contest'
      response.should be_success
    end
  end

end
