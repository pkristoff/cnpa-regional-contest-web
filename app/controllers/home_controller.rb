require 'home_helper'
require 'home_file_module'

class HomeController < ApplicationController

  ROOT_FOLDER = 'Contests'


  def file_list_template
    render '../assets/javascripts/directives/images-template.html'

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
      render status: info[0], json: info[1]
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
      render status: 500, json: "could not find path: #{root_folder}/#{contest_name}: #{e.message}"
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
        return render status: 500, json: file_path_originals + " does not exist"
      end
      if File.exists?(file_path_testdata)
        File.delete(file_path_testdata)
        deleted=true
      else
        return render status: 500, json: file_path_testdata + " does not exist"
      end
      if deleted
        dir_path = HomeFileModule.get_path(root_folder, contest_name, directory)
        contest_content = HomeFileModule.get_dir_contents(dir_path, false)
        handle_return HomeFileModule.get_and_return_file_info(contest_content, dir_path, directory)
      end
    rescue Exception => e
      return render status: 500, json: "could not delete file: #{file_path_originals}: #{filename}: #{e.message}"

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
        handle_return HomeFileModule.get_and_return_file_info(contest_content, dir_path, directory)
      else
        return render status: 500, json: "could not find path: #{dir_path}: #{e.message}"
      end

    rescue Exception => e
      return render status: 500, json: "could not cgange directory: #{e.message}"
    end

  end

  def get_contests
    root_folder = ROOT_FOLDER
    dir_path = root_folder + '/'
    # since it returns an array then don't call handle_return
    render json: HomeFileModule.get_dir_contents(dir_path, true)
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
