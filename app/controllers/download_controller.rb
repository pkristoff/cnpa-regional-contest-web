require 'home_file_module'

class DownloadController < ApplicationController
  def download_contest

    contest_name = params[:contestName]
    contest_dir = File.join(HomeHelper::ROOT_FOLDER, contest_name)

    if Dir.exist? contest_dir

      regenerate_contest(contest_name)

      send_file File.join(contest_dir, 'contest.zip'), :type => 'application/zip', :x_sendfile => true, :disposition => 'attachment'

    end
  end

  def regenerate_contest(contest_name)

    HomeFileModule.delete_generated_contest(contest_name)
    HomeFileModule.generate_contest(contest_name)

  end
end
