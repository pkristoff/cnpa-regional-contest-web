require 'home_file_module'

class HomeController < ApplicationController


  def file_list_template
    render '../assets/javascripts/directives/images/images-template.html'

  end

  def rename_file_template
    render '../assets/javascripts/directives/rename-file/rename-file-template.html'

  end

  def choose_contest
    render '../views/partials/chooseContest.html'
  end

  def contest_files
    render '../views/partials/contestFiles.html'
  end

  def busy_modal
    render '../views/partials/busyModal.html'
  end

#  ============= AJAX ===================

  def handle_return(info)
    if info.kind_of? Array # error
      render status: info[0], json: {message: info[1]}
    else
      render json: info
    end

  end

  def add_files
    HomeFileModule.save_file(HomeHelper::ROOT_FOLDER, params)
    handle_return HomeFileModule.get_contest_info(HomeHelper::ROOT_FOLDER, params[:name], HomeHelper::TESTDATA)
  end

  def contest
    handle_return HomeFileModule.get_contest_info(HomeHelper::ROOT_FOLDER, params[:name], HomeHelper::TESTDATA)
  end

  def create_contest
    root_folder = HomeHelper::ROOT_FOLDER
    begin
      contest_name = params[:name]
      result = HomeFileModule.create_contest(root_folder, contest_name)
      handle_return result
    rescue Exception => e
      render status: 500, json: {message: "could not find path: #{root_folder}/#{contest_name}: #{e.message}"}
    end
  end

  def delete_file
    root_folder = HomeHelper::ROOT_FOLDER
    contest_name = params[:contestName]
    filename = params[:filename]
    directory = params[:directory]

    begin

      error_message = HomeFileModule.delete_file contest_name, filename
      if error_message.empty?
        dir_path = HomeHelper.get_path(root_folder, contest_name, directory)
        contest_content = HomeFileModule.get_dir_contents(dir_path, false)
        handle_return HomeFileModule.get_and_return_file_info(contest_content, root_folder, contest_name, directory)
      else
        render status: 500, json: {message: error_message}
      end

    rescue Exception => e
      return render status: 500, json: {message: "could not delete file: #{contest_name}: #{filename}: #{e.message}"}

    end

  end

  def directory
    root_folder = HomeHelper::ROOT_FOLDER
    contest_name = params[:name]
    directory = params[:directory]
    dir_path = HomeHelper.get_path(root_folder, contest_name, directory)

    begin
      if Dir.exists?(dir_path)
        handle_return HomeFileModule.get_contest_info(HomeHelper::ROOT_FOLDER, contest_name, directory)
      else
        return render status: 500, json: {message: "could not find path: #{dir_path}: #{e.message}"}
      end

    rescue Exception => e
      return render status: 500, json: {message: "could not change directory: #{e.message}"}
    end

  end

  def delete_contest

    HomeFileModule.delete_generated_contest(params[:contestName])
    HomeFileModule.delete_contest(params[:contestName])

    get_contests

    # handle_return HomeFileModule.get_contest_info(HomeHelper::ROOT_FOLDER, params[:contestName], HomeHelper::TESTDATA)
  end

  def get_contests
    root_folder = HomeHelper::ROOT_FOLDER
    dir_path = root_folder + '/'
    # since it returns an array then don't call handle_return
    render json: HomeFileModule.get_dir_contents(dir_path, true)
  end

  def rename_file
    root_folder = HomeHelper::ROOT_FOLDER
    contest_name = params[:contestName]
    old_filename = params[:old_filename]
    new_filename = params[:new_filename]

    HomeFileModule.rename_file(root_folder, contest_name, old_filename, new_filename)

    handle_return HomeFileModule.get_contest_info(HomeHelper::ROOT_FOLDER, params[:contestName], HomeHelper::TESTDATA)
  end

  def save_config_info
    root_folder = HomeHelper::ROOT_FOLDER
    contest_name = params[:contestName]
    is_picture_age_required = params[:isPictureAgeRequired]
    picture_age_date = params[:pictureAgeDate]

    HomeFileModule.save_config_info(root_folder, contest_name, is_picture_age_required, picture_age_date)

    handle_return HomeFileModule.get_contest_info(HomeHelper::ROOT_FOLDER, params[:contestName], HomeHelper::TESTDATA)
  end

  def set_copyright
    root_folder = HomeHelper::ROOT_FOLDER
    contest_name = params[:contestName]
    filename = params[:filename]
    copyright = params[:copyright]
    HomeFileModule.set_copyright(root_folder, contest_name, filename, copyright)

    render status: 200, text: copyright
  end

  def generate_contest

    contest_name = params[:contestName]
    HomeFileModule.generate_contest(contest_name)

    handle_return HomeFileModule.get_contest_info(HomeHelper::ROOT_FOLDER, contest_name, HomeHelper::TESTDATA)
  end

  def regenerate_contest

    contest_name = params[:contestName]
    HomeFileModule.delete_generated_contest(contest_name)
    HomeFileModule.generate_contest(contest_name)

    handle_return HomeFileModule.get_contest_info(HomeHelper::ROOT_FOLDER, contest_name, HomeHelper::TESTDATA)
  end


end
