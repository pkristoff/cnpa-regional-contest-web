require 'home_helper'
require 'home_file_module'

class HomeController < ApplicationController

  ROOT_FOLDER = 'Contests'
  NAME_AND_NUMBER = 'name_and_number'


  def file_list_template
    render '../assets/javascripts/directives/images/images-template.html'

  end

  def rename_file_template
    render '../assets/javascripts/services/rename-file-template.html'

  end

  def choose_contest
    render '../views/partials/chooseContest.html'
  end

  def contest_files
    render '../views/partials/contestFiles.html'
  end

  def busyModal
    render '../views/partials/busyModal.html'
  end

#  ============= AJAX ===================

  def handle_return info
    if info.kind_of? Array # error
      render status: info[0], json: {message: info[1]}
    else
      render json: info
    end

  end

  def add_files
    HomeFileModule.save_file(ROOT_FOLDER, params)
    handle_return HomeFileModule.get_contest_info(ROOT_FOLDER, params[:name], HomeFileModule.get_testdata())
  end

  def contest
    handle_return HomeFileModule.get_contest_info(ROOT_FOLDER, params[:name], HomeFileModule.get_testdata())
  end

  def create_contest
    root_folder = ROOT_FOLDER
    begin
      contest_name = params[:name]
      result = HomeFileModule.create_contest(root_folder, contest_name)
      handle_return result
    rescue Exception => e
      render status: 500, json: {"message" => "could not find path: #{root_folder}/#{contest_name}: #{e.message}"}
    end
  end

  def delete_file
    root_folder = ROOT_FOLDER
    contest_name = params[:contestName]
    filename = params[:filename]
    directory = params[:directory]
    file_path_originals = File.join(HomeFileModule.get_originals_path(root_folder, contest_name), filename)
    file_path_testdata = File.join(HomeFileModule.get_testdata_path(root_folder, contest_name), filename)
    begin
      deleted = false
      if File.exists?(file_path_originals)
        File.delete(file_path_originals)
        deleted=true
      else
        return render status: 500, json: {"message" => file_path_originals + " does not exist"}
      end
      if File.exists?(file_path_testdata)
        File.delete(file_path_testdata)
        deleted=true
      else
        return render status: 500, json: {"message" => file_path_testdata + " does not exist"}
      end
      if deleted
        dir_path = HomeFileModule.get_path(root_folder, contest_name, directory)
        contest_content = HomeFileModule.get_dir_contents(dir_path, false)
        handle_return HomeFileModule.get_and_return_file_info(contest_content, root_folder, contest_name, directory)
      end
    rescue Exception => e
      return render status: 500, json: {"message" => "could not delete file: #{file_path_originals}: #{filename}: #{e.message}"}

    end

  end

  def directory
    root_folder = ROOT_FOLDER
    contest_name = params[:name]
    directory = params[:directory]
    dir_path = HomeFileModule.get_path(root_folder, contest_name, directory)

    begin
      if Dir.exists?(dir_path)
        contest_content = HomeFileModule.get_dir_contents(dir_path, false)
        handle_return HomeFileModule.get_and_return_file_info(contest_content, root_folder, contest_name, directory)
      else
        return render status: 500, json: {"message" => "could not find path: #{dir_path}: #{e.message}"}
      end

    rescue Exception => e
      return render status: 500, json: {"message" => "could not change directory: #{e.message}"}
    end

  end

  def email_contest

    contest_dir = File.join(ROOT_FOLDER, params[:contestName])

    originals_dir_name = HomeFileModule.get_originals
    testdata_dir_name = HomeFileModule.get_testdata
    name_and_number_dir_name = HomeFileModule.get_name_and_number
    number_dir_name = HomeFileModule.get_number

    [[File.join(contest_dir, "#{originals_dir_name}.zip"), originals_dir_name],
     [File.join(contest_dir, "#{testdata_dir_name}.zip"), testdata_dir_name],
     [File.join(contest_dir, "#{name_and_number_dir_name}.zip"), name_and_number_dir_name],
     [File.join(contest_dir, "#{number_dir_name}.zip"), number_dir_name]].each do |entry|
      zip_file_path = entry[0]
      dir_path = entry[1]
      ContestMailer.contest_email(params[:contestName], params[:emailAddress], dir_path, zip_file_path)

    end

    handle_return HomeFileModule.get_contest_info(ROOT_FOLDER, params[:contestName], HomeFileModule.get_testdata())
  end

  def generate_contest

    HomeFileModule.generate_contest(params[:contestName])

    handle_return HomeFileModule.get_contest_info(ROOT_FOLDER, params[:contestName], HomeFileModule.get_testdata())
  end

  def delete_contest

    HomeFileModule.delete_generated_contest(params[:contestName])
    HomeFileModule.delete_contest(params[:contestName])

    get_contests

    # handle_return HomeFileModule.get_contest_info(ROOT_FOLDER, params[:contestName], HomeFileModule.get_testdata())
  end

  def regenerate_contest

    HomeFileModule.delete_generated_contest(params[:contestName])
    HomeFileModule.generate_contest(params[:contestName])

    handle_return HomeFileModule.get_contest_info(ROOT_FOLDER, params[:contestName], HomeFileModule.get_testdata())
  end

  def get_contests
    root_folder = ROOT_FOLDER
    dir_path = root_folder + '/'
    # since it returns an array then don't call handle_return
    render json: HomeFileModule.get_dir_contents(dir_path, true)
  end

  def rename_file
    root_folder = ROOT_FOLDER
    contest_name = params[:contestName]
    old_filename = params[:old_filename]
    new_filename = params[:new_filename]
    directory = params[:directory]

    dir_path = HomeFileModule.get_path(root_folder, contest_name, directory)

    HomeFileModule.rename_file(root_folder, contest_name, old_filename, new_filename)

    handle_return HomeFileModule.get_contest_info(ROOT_FOLDER, params[:contestName], HomeFileModule.get_testdata())
  end

  def save_config_info
    root_folder = ROOT_FOLDER
    contest_name = params[:contestName]
    email = params[:email]
    is_picture_age_required = params[:isPictureAgeRequired]
    picture_age_date = params[:pictureAgeDate]
    directory = params[:directory]

    dir_path = HomeFileModule.get_path(root_folder, contest_name, directory)

    HomeFileModule.save_config_info(root_folder, contest_name, email, is_picture_age_required, picture_age_date)

    handle_return HomeFileModule.get_contest_info(ROOT_FOLDER, params[:contestName], HomeFileModule.get_testdata())
  end

  def set_copyright
    root_folder = ROOT_FOLDER
    contest_name = params[:contestName]
    filename = params[:filename]
    copyright = params[:copyright]
    HomeFileModule.set_copyright(root_folder, contest_name, filename, copyright)

    render status: 200, text: copyright
  end


end
