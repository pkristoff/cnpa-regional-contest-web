class DownloadController < ApplicationController
  def download_contest

    contest_dir = File.join(HomeHelper::ROOT_FOLDER, 'test1')
    originals_dir_name = HomeHelper::ORIGINALS
    testdata_dir_name = HomeHelper::TESTDATA
    name_and_number_dir_name = HomeHelper::NAME_AND_NUMBER
    number_dir_name = HomeHelper::NUMBER

    [[File.join(contest_dir, "#{originals_dir_name}.zip"), originals_dir_name],
     [File.join(contest_dir, "#{testdata_dir_name}.zip"), testdata_dir_name],
     [File.join(contest_dir, "#{name_and_number_dir_name}.zip"), name_and_number_dir_name],
     [File.join(contest_dir, "#{number_dir_name}.zip"), number_dir_name]].each do |entry|
      zip_file_path = entry[0]
      dir_path = entry[1]
      # ContestMailer.contest_email(params[:contestName], params[:emailAddress], dir_path, zip_file_path)
      send_file zip_file_path, :type=>'application/zip', :x_sendfile=>true, :disposition=>'attachment'

    end
  end
end
