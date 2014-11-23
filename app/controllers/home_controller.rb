class HomeController < ApplicationController

  TESTDATA = 'Testdata'
  ORIGINALS = 'Originals'
  EXIFTOOL_FILE_INFO = 'exif.txt'

  def get_contest_folder
    render '../views/partials/getContestFolder.html'
  end

  def choose_contest
    render '../views/partials/chooseContest.html'
  end

  def file_list_template
    render '../assets/javascripts/directives/images-template.html'

  end

  def contest_files
    render '../views/partials/contestFiles.html'
  end

  def get_contests
    root_folder = params[:rootFolder]
    dir_path = root_folder + "/"
    render json: get_dir_contents(dir_path, true)
  end

  def get_dir_contents(dir_path, for_dir)
    directories = []
    Dir.foreach(dir_path) do |x|
      file_path = File.join(dir_path, x)
      if for_dir
        directories.push(x) if File.directory?(file_path) and (x != '.' and x != '..')
      else
        directories.push(x) if File.file?(file_path) and (x != '.DS_Store')
      end
    end
    directories
  end

  def create_contest
    root_folder = params[:rootFolder]
    contest_name = params[:name]
    dir_path = root_folder + "/" + contest_name + "/"
    begin
      if Dir.exists?(dir_path)
        dir_path = dir_path + "Originals/"
        if Dir.exists?(dir_path)
          contest_content_directories = get_dir_contents(dir_path, true)
        else
          Dir.mkdir(dir_path)
          contest_content_directories = []
        end
      else
        Dir.mkdir(dir_path)
        Dir.mkdir(get_originals_path(root_folder, contest_name))
        Dir.mkdir(get_testdata_path(root_folder, contest_name))
        contest_content_directories = []
      end
      result = {:filenames => contest_content_directories,
                :directories => [ORIGINALS, TESTDATA],
                :directory => TESTDATA
      }
      render json: result
    rescue Exception => e
      render status: 500, json: "could not find path: " + dir_path + ": " + e
    end
  end

  def get_originals_path(root_folder, contest_name)
    get_path(root_folder, contest_name, ORIGINALS);
  end

  def get_testdata_path(root_folder, contest_name)
    get_path(root_folder, contest_name, TESTDATA);
  end

  def get_path(root_folder, contest_name, directory)
    File.join(root_folder, contest_name, directory)
  end


  def contest
    get_and_render_contest_info(TESTDATA)
  end

  def get_and_render_contest_info(dir)
    root_folder = params[:rootFolder]
    contest_name = params[:name]
    dir_path = get_path(root_folder, contest_name, dir)
    begin
      if Dir.exists?(dir_path)
        contest_content = get_dir_contents(dir_path, false)
        result = get_and_return_file_info(contest_content, dir_path, dir)
      else
        render status: 500, json: "could not find path: " + dir_path
      end
    rescue Exception => e
      render status: 500, json: "could not find path: " + dir_path + ": " + e.message
    end
    render json: result
  end

  def get_and_return_file_info(contest_content, dir_path, directory)
    result = {
        filenames: [],
        directories: [ORIGINALS, TESTDATA],
        directory: directory
    }

    contest_content.each do |filename|
      filename_split = filename.split(".")
      if filename_split.length === 2 && (filename_split[1] === "jpg" || filename_split[1] === "JPG" || filename_split[1] === "jpeg" || filename_split[1] === "JPEG")
        file_path = File.join(dir_path, filename)
        file_path_exif = file_path.gsub(' ', '\\ ')
        if File.file?(file_path)
          begin
            exiftool_filepath = File.join(dir_path, EXIFTOOL_FILE_INFO)
            xxx = "exiftool -imagesize -iptc:CopyrightNotice -iptc:caption-abstract -xmp:title -DateTimeOriginal -FileSize #{file_path_exif} > #{exiftool_filepath}"
            #  xxx = "exiftool  ./* > #{directory_info.EXIFTOOL_FILE_INFO}"
            system xxx
            lines = IO.readlines(exiftool_filepath)
            file_info = {"filename" => filename}
            result[:filenames].push(file_info)
            lines.each do |line|

              split = line.split(":")
              key = split[0].strip
              value = split[1].chomp.strip
              if key == 'Image Size'
                imageSizeSplit = value.chomp.strip.split('x')
                file_info['imageWidth'] = imageSizeSplit[0].strip
                file_info['imageHeight'] = imageSizeSplit[1].strip
              elsif key == 'Copyright Notice'
                file_info['copyrightNotice'] = value.strip
              elsif key == 'Caption-Abstract'
                file_info['caption'] = value.strip
              elsif key == 'Title'
                file_info['title'] = value.strip
              elsif key == 'Date/Time Original'
                file_info['dateCreated'] = value.strip
              elsif key == 'File Size'
                sizeSplit = value.strip.split(' ')
                if sizeSplit[1].strip == 'kB'
                  file_info['fileSize'] = sizeSplit[0].strip
                else
                  file_info['fileSize'] = "filesize not in kB but is '#{sizeSplit[1].strip}'"
                end
              end
            end
          rescue Exception => e
            return render status: 500, json: "could not get exiftool info : #{filename}: #{e.message}"
          end
        end
      end
    end
    result
  end

  def addFiles
    saveFile(params)
    get_and_render_contest_info(TESTDATA)
  end

  def get_files(params)
    files = []
    params.each do |key, value|
      if key.start_with?('file')
        files.push(value)
      end
    end
    files
  end

  def saveFile (params)
    root_folder = params[:rootFolder]
    contest_name = params[:name]
    dir_path_originals = get_originals_path(root_folder, contest_name)
    dir_path_testdata = get_testdata_path(root_folder, contest_name)

    get_files(params).each do |file|

      name = file.original_filename

      file_path_originals = File.join(dir_path_originals, name)
      file_path_testdata = File.join(dir_path_testdata, name)

      file_innards = file.read
      File.open(file_path_originals, "wb") { |f| f.write(file_innards) }
      File.open(file_path_testdata, "wb") { |f| f.write(file_innards) }
    end
  end

  def delete_file
    root_folder = params[:rootFolder]
    contest_name = params[:contestName]
    filename = params[:filename]
    directory = params[:directory]
    file_path_originals = File.join(get_originals_path(root_folder, contest_name), filename)
    file_path_testdata = File.join(get_testdata_path(root_folder, contest_name), filename)
    begin
      deleted = false;
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
        dir_path = directory === ORIGINALS ? (get_originals_path(root_folder, contest_name)) : (get_testdata_path(root_folder, contest_name))
        contest_content = get_dir_contents(dir_path, false)
        render json: get_and_return_file_info(contest_content, dir_path, directory)
      end
    rescue Exception => e
      return render status: 500, json: "could not delete file: #{file_path_originals}: #{filename}: #{e.message}"

    end

  end

  def setCopyright
    root_folder = params[:rootFolder]
    contest_name = params[:contestName]
    filename = params[:filename]
    copyright = params[:copyright]
    file_path_testdata = File.join(get_testdata_path(root_folder, contest_name), filename)
    file_path_exif = file_path_testdata.gsub(' ', '\\ ')

    xxx = "exiftool -iptc:CopyrightNotice=\"#{copyright}\" #{file_path_exif}"
    #  xxx = "exiftool  ./* > #{directory_info.EXIFTOOL_FILE_INFO}"
    system xxx
    render status: 200, text: copyright
  end

  def directory
    root_folder = params[:rootFolder]
    contest_name = params[:name]
    directory = params[:directory]
    dir_path = get_path(root_folder, contest_name, directory)

    begin
      if Dir.exists?(dir_path)
        contest_content = get_dir_contents(dir_path, false)
        render json: get_and_return_file_info(contest_content, dir_path, directory)
      else
        return render status: 500, json: "could not find path: #{dir_path}: #{e.message}"
      end

    rescue Exception => e
      return render status: 500, json: "could not cgange directory: #{e.message}"
    end

  end
end
