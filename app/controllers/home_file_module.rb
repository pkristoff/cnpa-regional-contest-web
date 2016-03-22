require 'fileutils'
require 'home_helper'

module HomeFileModule

  def HomeFileModule.get_dir_contents(dir_path, for_dir)
    directories = []
    Dir.foreach(dir_path) do |x|
      file_path = File.join(dir_path, x)
      if for_dir
        directories.push(x) if File.directory?(file_path) and (x != '.' and x != '..')
      else
        directories.push(x) if File.file?(file_path) and (x != '.DS_Store') and (!x.include? '_original') and (!x.include? '.json')
      end
    end
    directories
  end

  def HomeFileModule.get_contest_info(root_folder, contest_name, dir)
    dir_path = HomeHelper.get_path(root_folder, contest_name, dir)
    begin
      if Dir.exists?(dir_path)
        contest_content = HomeFileModule.get_dir_contents(dir_path, false)
        result = HomeFileModule.get_and_return_file_info(contest_content, root_folder, contest_name, dir)
        config_info = HomeFileModule.get_config_info(root_folder, contest_name)
        result[:hasGeneratedContest] = [result[:directories].size > 2]
        result[:email] = config_info['email']
        result[:isPictureAgeRequired] = config_info['is_picture_age_required']
        result[:pictureAgeDate] = config_info['picture_age_date']
      else
        return 500, "could not find path: #{dir_path}"
      end
    rescue Exception => e
      return 500, "could not find path: #{dir_path}: #{e.message}"
    end
    return result
  end

  def HomeFileModule.get_and_return_file_info(contest_content, root_folder, contest_name, directory)
    if directory == HomeHelper::TESTDATA
      result = {
          filenames: HomeFileModule.get_files_info(contest_name, root_folder),
          directories: HomeFileModule.get_dir_contents(File.join(root_folder, contest_name), true),
          directory: directory
      }
    else
      result = {
          filenames: [],
          directories: HomeFileModule.get_dir_contents(File.join(root_folder, contest_name), true),
          directory: directory
      }
      dir_path = HomeHelper.get_path(root_folder, contest_name, directory)

      contest_content.each do |filename|
        filename_split = filename.split('.')
        if filename_split.length === 2 && (filename_split[1] === 'jpg' || filename_split[1] === 'JPG' || filename_split[1] === 'jpeg' || filename_split[1] === 'JPEG')
          file_path = File.join(dir_path, filename)

          result[:filenames].push(HomeFileModule.extract_file_info(file_path, dir_path, filename, false))
        end
      end
    end
    result
  end

  def HomeFileModule.execute_exiftool(options, file_path, result_path)

    file_path_exif = file_path.gsub(' ', '\\ ')
    file_path_exif = file_path_exif.gsub('(', '\\(')
    file_path_exif = file_path_exif.gsub(')', '\\)')

    result = result_path.empty? ? '' : " > #{result_path}"

    xxx = "exiftool #{options} #{file_path_exif}#{result}"
    #  xxx = "exiftool  ./* > #{directory_info.EXIFTOOL_FILE_INFO}"
    system xxx
  end

  def HomeFileModule.get_files(params)
    files = []
    params.each do |key, value|
      if key.start_with?('file')
        files.push(value)
      end
    end
    files
  end

  def HomeFileModule.save_file (root_folder, params)
    contest_name = params[:name]
    dir_path_originals = HomeHelper.get_originals_path(root_folder, contest_name)
    dir_path_testdata = HomeHelper.get_testdata_path(root_folder, contest_name)

    files_info = HomeFileModule.get_files_info contest_name

    HomeFileModule.get_files(params).each do |file|

      name = file.original_filename
      name = name.gsub('', '')

      file_path_originals = File.join(dir_path_originals, name)
      file_path_testdata = File.join(dir_path_testdata, name)

      file_innards = file.read
      File.open(file_path_originals, 'wb') { |f| f.write(file_innards) }
      File.open(file_path_testdata, 'wb') { |f| f.write(file_innards) }

      file_info = HomeFileModule.extract_file_info file_path_testdata, dir_path_testdata, name
      files_info.push(file_info)

    end
    HomeFileModule.save_files_info(files_info, contest_name)
  end

  def HomeFileModule.extract_file_info(file_path_testdata, dir_path, filename, is_for_testdata=true)

    if File.file?(file_path_testdata)
      begin
        exiftool_filepath = File.join(dir_path, HomeHelper::EXIFTOOL_FILE_INFO)
        HomeFileModule.execute_exiftool('-imagesize -iptc:CopyrightNotice -iptc:caption-abstract -xmp:title -DateTimeOriginal -FileSize', file_path_testdata, exiftool_filepath)

        lines = IO.readlines(exiftool_filepath)
        file_info = {filename: filename}
        file_info[:original_filename] = filename if is_for_testdata

        lines.each do |line|

          split = line.split(':')
          key = split[0].strip
          value = split[1].chomp.strip
          case key
            when 'Image Size'
              image_size_split = value.chomp.strip.split('x')
              file_info[:imageWidth] = image_size_split[0].strip
              file_info[:imageHeight] = image_size_split[1].strip
            when 'Copyright Notice'
              file_info[:copyrightNotice] = value.strip
            when 'Caption-Abstract'
              file_info[:caption] = value.strip
            when 'Title'
              file_info[:title] = value.strip
            when 'Date/Time Original'
              date_str = line[line.index(':') + 1, line.size].chomp.strip
              date = Date.strptime(date_str, '%Y:%m:%d')
              file_info[:dateCreated] = date
            when 'File Size'
              size_split = value.strip.split(' ')
              if size_split[1].strip == 'kB'
                file_info[:fileSize] = size_split[0].strip
              else
                file_info[:fileSize] = "filesize not in kB but is '#{size_split[1].strip}'"
              end
            else
              return 500, "unknown exiftool key #{key}"
          end
        end
        FileUtils.rm(exiftool_filepath)
      rescue Exception => e
        return 500, "could not get exiftool info : #{file_path_testdata}: #{e.message}"
      end
      file_info
    end
  end


  def HomeFileModule.create_contest(root_folder, contest_name)

    Dir.mkdir(root_folder) unless Dir.exists? root_folder

    result = {filenames: [],
              directories: HomeHelper.get_initial_directories,
              directory: HomeHelper::TESTDATA,
              hasGeneratedContest: false,
              email: 'foo@bar.com',
              isPictureAgeRequired: false,
              pictureAgeDate: Date.today
    }
    contest_dir_path = root_folder + '/' + contest_name + '/'
    if Dir.exists?(contest_dir_path)
      HomeFileModule.empty_and_delete contest_dir_path
    end

    Dir.mkdir(contest_dir_path)
    HomeFileModule.save_config_info(root_folder, contest_name, result[:email], result[:isPictureAgeRequired],
                                    result[:pictureAgeDate])
    Dir.mkdir(HomeHelper.get_originals_path(root_folder, contest_name))
    Dir.mkdir(HomeHelper.get_testdata_path(root_folder, contest_name))
    result
  end

  def HomeFileModule.save_config_info(root_folder, contest_name, email, is_age_required, picture_age_date)
    contest_config_path = "#{root_folder}/#{contest_name}/config.json"
    config_info = {email: email, is_picture_age_required: is_age_required, picture_age_date:
        picture_age_date}
    File.open(contest_config_path, 'w') { |f| f.write(config_info.to_json) }
  end

  def HomeFileModule.get_config_file(root_folder, contest_name)
    return "#{root_folder}/#{contest_name}/config.json"
  end

  def HomeFileModule.get_config_info(root_folder, contest_name)
    contest_config_path = get_config_file(root_folder, contest_name)
    if File.exist? contest_config_path
      return JSON.parse(File.read(contest_config_path))
    else
      HomeFileModule.save_config_info(root_folder, contest_name, 'foo@bar.com', false, Date.today)
      return HomeFileModule.get_config_info(root_folder, contest_name)
    end
  end

  def HomeFileModule.set_copyright(root_folder, contest_name, filename, copyright)
    file_path_testdata = File.join(HomeHelper.get_testdata_path(root_folder, contest_name), filename)

    HomeFileModule.execute_exiftool("-iptc:CopyrightNotice=\"#{copyright}\"", file_path_testdata, '')
    FileUtils.rm("#{file_path_testdata}_original")

    file_info = HomeFileModule.get_file_info contest_name, filename, root_folder
    file_info[:copyrightNotice] = copyright
    HomeFileModule.update_file_info contest_name, filename, root_folder, file_info
  end

  def HomeFileModule.delete_contest(contest_name)

    root_folder = HomeHelper::ROOT_FOLDER
    dir_path_originals = HomeHelper.get_path(root_folder, contest_name, HomeHelper::ORIGINALS)
    dir_path_testdata = HomeHelper.get_path(root_folder, contest_name, HomeHelper::TESTDATA)

    HomeFileModule.empty_and_delete dir_path_originals
    HomeFileModule.empty_and_delete dir_path_testdata

    file_path_config = HomeFileModule.get_config_file(root_folder, contest_name)
    File.delete file_path_config

    dir_path_contest = File.join(root_folder, contest_name)

    Dir.delete (dir_path_contest)

  end

  def HomeFileModule.delete_generated_contest(contest_name)

    root_folder = HomeHelper::ROOT_FOLDER
    dir_path_name_and_number = HomeHelper.get_path(root_folder, contest_name, HomeHelper::NAME_AND_NUMBER)
    dir_path_number = HomeHelper.get_path(root_folder, contest_name, HomeHelper::NAME_AND_NUMBER)

    dir_path_contest = File.join(root_folder, contest_name)

    zip_path_name_and_number = File.join(dir_path_contest, "#{HomeHelper::NAME_AND_NUMBER}.zip")
    File.delete(zip_path_name_and_number) if File.exist? zip_path_name_and_number
    zip_path_number = File.join(dir_path_contest, "#{HomeHelper::NUMBER}.zip")
    File.delete(zip_path_number) if File.exist? zip_path_number
    zip_path_originals = File.join(dir_path_contest, "#{HomeHelper::ORIGINALS}.zip")
    File.delete(zip_path_originals) if File.exist? zip_path_originals
    zip_path_testdata = File.join(dir_path_contest, "#{HomeHelper::TESTDATA}.zip")
    File.delete(zip_path_testdata) if File.exist? zip_path_testdata

    HomeFileModule.empty_and_delete dir_path_name_and_number
    HomeFileModule.empty_and_delete dir_path_number

  end

  def HomeFileModule.empty_and_delete(dir_path)

    if Dir.exists? dir_path
      Dir.foreach(dir_path) do |filename|
        filename_path = File.join(dir_path, filename)
        if filename != '.' && filename != '..'
          if File.directory?(filename_path)
            HomeFileModule.empty_and_delete filename_path
          else
            File.delete filename_path
          end
        end
      end
      Dir.delete(dir_path)
    end
  end

  def HomeFileModule.generate_contest(contest_name)

    root_folder = HomeHelper::ROOT_FOLDER
    dir_path_originals = HomeHelper.get_originals_path(root_folder, contest_name)
    dir_path_testdata = HomeHelper.get_testdata_path(root_folder, contest_name)
    dir_path_name_and_number = HomeHelper.get_path(root_folder, contest_name, HomeHelper::NAME_AND_NUMBER)
    dir_path_number = HomeHelper.get_path(root_folder, contest_name, HomeHelper::NUMBER)

    Dir.mkdir(dir_path_name_and_number)
    Dir.mkdir(dir_path_number)

    contest_content = HomeFileModule.get_dir_contents(dir_path_testdata, false)
    file_nums = (1..contest_content.length).to_a.sort { rand - 0.5 }
    contest_content.each_index do |i|

      filename = contest_content[i]

      file_path_testdata = File.join(dir_path_testdata, filename)
      file_path_name_and_number = File.join(dir_path_name_and_number, "#{file_nums[i]}_#{filename}")
      file_path_number = File.join(dir_path_number, "#{file_nums[i]}.jpg")

      FileUtils.cp(file_path_testdata, file_path_name_and_number)
      FileUtils.cp(file_path_testdata, file_path_number)

      HomeFileModule.execute_exiftool('-all=', file_path_number, '')

    end

    contest_dir = File.join(root_folder, contest_name)

    xxx = "zip #{File.join(contest_dir, "#{HomeHelper::ORIGINALS}.zip")} #{dir_path_originals}/*"
    system xxx

    xxx = "zip #{File.join(contest_dir, "#{HomeHelper::TESTDATA}.zip")} #{dir_path_testdata}/*"
    system xxx

    xxx = "zip #{File.join(contest_dir, "#{HomeHelper::NAME_AND_NUMBER}.zip")} #{dir_path_name_and_number}/*"
    system xxx

    xxx = "zip #{File.join(contest_dir, "#{HomeHelper::NUMBER}.zip")} #{dir_path_number}/*"
    system xxx

  end

  def HomeFileModule.rename_file(root_folder, contest_name, old_filename, new_filename)
    old_file_path_testdata = File.join(HomeHelper.get_testdata_path(root_folder, contest_name), old_filename)
    new_file_path_testdata = File.join(HomeHelper.get_testdata_path(root_folder, contest_name), new_filename)

    if File.exists?(old_file_path_testdata)
      File.rename(old_file_path_testdata, new_file_path_testdata)
      file_info = HomeFileModule.get_file_info contest_name, old_filename, root_folder
      file_info[:filename] = new_filename
      HomeFileModule.update_file_info contest_name, old_filename, root_folder, file_info
    end
  end

  def HomeFileModule.delete_file(contest_name, filename)
    root_folder = HomeHelper::ROOT_FOLDER

    file_info = HomeFileModule.get_file_info contest_name, filename, root_folder

    original_filename = file_info[:original_filename]
    file_path_originals = File.join(HomeHelper.get_originals_path(root_folder, contest_name), original_filename)
    file_path_testdata = File.join(HomeHelper.get_testdata_path(root_folder, contest_name), filename)

    if File.exists?(file_path_originals)
      File.delete(file_path_originals)
    else
      return "#{file_path_originals} does not exist"
    end
    if File.exists?(file_path_testdata)
      File.delete(file_path_testdata)
    else
      return "#{file_path_testdata} does not exist"
    end
    HomeFileModule.remove_file_info contest_name, filename, root_folder
    return ''

  end

  def HomeFileModule.save_files_info(files_info, contest_name, root_folder=HomeHelper::ROOT_FOLDER)
    file_path = HomeHelper.get_testdata_path(root_folder, contest_name)
    File.open(File.join(file_path, HomeHelper::ROOT_FOLDER), 'w') { |fo| fo.puts files_info.to_json }
  end

  def HomeFileModule.get_files_info(contest_name, root_folder=HomeHelper::ROOT_FOLDER)
    file_path = HomeHelper.get_testdata_path(root_folder, contest_name)
    files_info_string = '[]'
    begin
      files_info_string = File.read(File.join(file_path, HomeHelper::ROOT_FOLDER))
    rescue Exception => _e
      # lazy initialize file
    end

    files_info_string = files_info_string.strip.empty? ? '{}' : files_info_string
    JSON.parse(files_info_string, :symbolize_names => true)
  end

  def HomeFileModule.get_file_info(contest_name, filename, root_folder)
    files_info = HomeFileModule.get_files_info contest_name, root_folder
    files_info.detect do |fi|
      fi[:filename] == filename
    end
  end

  def HomeFileModule.update_file_info(contest_name, filename, root_folder, file_info)
    files_info = HomeFileModule.get_files_info contest_name, root_folder
    files_info.delete_at(files_info.index { |fi| fi[:filename] == filename })
    files_info.push(file_info)
    HomeFileModule.save_files_info files_info, contest_name, root_folder
  end

  def HomeFileModule.remove_file_info(contest_name, filename, root_folder)
    files_info = HomeFileModule.get_files_info contest_name, root_folder
    files_info.delete_at(files_info.index { |fi| fi[:filename] == filename })
    HomeFileModule.save_files_info files_info, contest_name, root_folder
  end

end