require 'fileutils'

module HomeFileModule
  TESTDATA = 'Testdata'
  ORIGINALS = 'Originals'
  EXIFTOOL_FILE_INFO = 'exif.txt'
  ROOT_FOLDER = 'Contests'
  NAME_AND_NUMBER = 'name_and_number'
  NUMBER = 'number'

  def HomeFileModule.get_originals_path(root_folder, contest_name)
    HomeFileModule.get_path(root_folder, contest_name, ORIGINALS);
  end

  def HomeFileModule.get_testdata_path(root_folder, contest_name)
    HomeFileModule.get_path(root_folder, contest_name, TESTDATA);
  end

  def HomeFileModule.get_path(root_folder, contest_name, directory)
    File.join(root_folder, contest_name, directory)
  end

  def HomeFileModule.get_initial_directories()
    [ORIGINALS, TESTDATA]
  end

  def HomeFileModule.get_testdata()
    TESTDATA
  end

  def HomeFileModule.get_originals()
    ORIGINALS
  end

  def HomeFileModule.get_name_and_number()
    NAME_AND_NUMBER
  end

  def HomeFileModule.get_number()
    NUMBER
  end

  def HomeFileModule.get_dir_contents(dir_path, for_dir)
    directories = []
    Dir.foreach(dir_path) do |x|
      file_path = File.join(dir_path, x)
      if for_dir
        directories.push(x) if File.directory?(file_path) and (x != '.' and x != '..')
      else
        directories.push(x) if File.file?(file_path) and (x != '.DS_Store') and (!x.include? "_original")
      end
    end
    directories
  end

  def HomeFileModule.get_contest_info(root_folder, contest_name, dir)
    dir_path = HomeFileModule.get_path(root_folder, contest_name, dir)
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
    result = {
        filenames: [],
        directories: HomeFileModule.get_dir_contents(File.join(root_folder, contest_name), true),
        directory: directory
    }
    dir_path = HomeFileModule.get_path(root_folder, contest_name, directory)

    contest_content.each do |filename|
      filename_split = filename.split(".")
      if filename_split.length === 2 && (filename_split[1] === "jpg" || filename_split[1] === "JPG" || filename_split[1] === "jpeg" || filename_split[1] === "JPEG")
        file_path = File.join(dir_path, filename)
        if File.file?(file_path)
          begin
            exiftool_filepath = File.join(dir_path, EXIFTOOL_FILE_INFO)
            HomeFileModule.execute_exiftool("-imagesize -iptc:CopyrightNotice -iptc:caption-abstract -xmp:title -DateTimeOriginal -FileSize", file_path, exiftool_filepath)

            lines = IO.readlines(exiftool_filepath)
            file_info = {:filename => filename}
            result[:filenames].push(file_info)

            lines.each do |line|

              split = line.split(":")
              key = split[0].strip
              value = split[1].chomp.strip
              if key == 'Image Size'
                image_size_split = value.chomp.strip.split('x')
                file_info[:imageWidth] = image_size_split[0].strip
                file_info[:imageHeight] = image_size_split[1].strip
              elsif key == 'Copyright Notice'
                file_info[:copyrightNotice] = value.strip
              elsif key == 'Caption-Abstract'
                file_info[:caption] = value.strip
              elsif key == 'Title'
                file_info[:title] = value.strip
              elsif key == 'Date/Time Original'
                dateStr = line[line.index(':') + 1, line.size].chomp.strip
                date = Date.strptime(dateStr, "%Y:%m:%d")
                file_info[:dateCreated] = date
              elsif key == 'File Size'
                size_split = value.strip.split(' ')
                if size_split[1].strip == 'kB'
                  file_info[:fileSize] = size_split[0].strip
                else
                  file_info[:fileSize] = "filesize not in kB but is '#{size_split[1].strip}'"
                end
              end
            end
            FileUtils.rm(exiftool_filepath)
          rescue Exception => e
            return 500, "could not get exiftool info : #{filename}: #{e.message}"
          end
        end
      end
    end
    result
  end

  def HomeFileModule.execute_exiftool options, file_path, result_path

    file_path_exif = file_path.gsub(' ', '\\ ')
    file_path_exif = file_path_exif.gsub('(', '\\(')
    file_path_exif = file_path_exif.gsub(')', '\\)')

    result = result_path.empty? ? "" : " > #{result_path}"

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
    dir_path_originals = HomeFileModule.get_originals_path(root_folder, contest_name)
    dir_path_testdata = HomeFileModule.get_testdata_path(root_folder, contest_name)

    HomeFileModule.get_files(params).each do |file|

      name = file.original_filename
      name = name.gsub("'", "")

      file_path_originals = File.join(dir_path_originals, name)
      file_path_testdata = File.join(dir_path_testdata, name)

      file_innards = file.read
      File.open(file_path_originals, "wb") { |f| f.write(file_innards) }
      File.open(file_path_testdata, "wb") { |f| f.write(file_innards) }
    end
  end


  def HomeFileModule.create_contest(root_folder, contest_name)
    if !Dir.exists? root_folder
      Dir.mkdir(root_folder)
    end
    result = {:filenames => [],
              :directories => HomeFileModule.get_initial_directories,
              :directory => HomeFileModule.get_testdata,
              :hasGeneratedContest => false,
              :email => 'foo@bar.com',
              :isPictureAgeRequired => false,
              :pictureAgeDate => Date.today
    }
    contest_dir_path = root_folder + '/' + contest_name + '/'
    if Dir.exists?(contest_dir_path)
      contest_dir_path = HomeFileModule.get_originals_path(root_folder, contest_name)
      if Dir.exists?(contest_dir_path)
        result = HomeFileModule.get_contest_info(root_folder, contest_name, TESTDATA)
      else
        Dir.mkdir(contest_dir_path)
      end
    else
      Dir.mkdir(contest_dir_path)
      HomeFileModule.save_config_info(root_folder, contest_name, result[:email], result[:isPictureAgeRequired],
                                      result[:pictureAgeDate])
      Dir.mkdir(HomeFileModule.get_originals_path(root_folder, contest_name))
      Dir.mkdir(HomeFileModule.get_testdata_path(root_folder, contest_name))
    end
    return result
  end

  def HomeFileModule.save_config_info(root_folder, contest_name, email, is_picture_age_required, picture_age_date)
    contest_config_path = "#{root_folder}/#{contest_name}/config.json"
    config_info = {'email' => email, 'is_picture_age_required' => is_picture_age_required, 'picture_age_date' =>
        picture_age_date}
    File.open(contest_config_path, "w") { |f| f.write(config_info.to_json) }
  end

  def HomeFileModule.get_config_file(root_folder, contest_name)
    return "#{root_folder}/#{contest_name}/config.json"
  end

  def HomeFileModule.get_config_info(root_folder, contest_name)
    contest_config_path = get_config_file(root_folder, contest_name)
    if (File.exist? contest_config_path)
      return JSON.parse(File.read(contest_config_path))
    else
      HomeFileModule.save_config_info(root_folder, contest_name, "foo@bar.com", false, Date.today)
      return HomeFileModule.get_config_info(root_folder, contest_name)
    end
  end

  def HomeFileModule.set_copyright(root_folder, contest_name, filename, copyright)
    file_path_testdata = File.join(HomeFileModule.get_testdata_path(root_folder, contest_name), filename)

    HomeFileModule.execute_exiftool("-iptc:CopyrightNotice=\"#{copyright}\"", file_path_testdata, "")
    FileUtils.rm("#{file_path_testdata}_original")
  end

  def HomeFileModule.delete_contest(contest_name)

    root_folder = ROOT_FOLDER
    dir_path_originals = HomeFileModule.get_path(root_folder, contest_name, ORIGINALS)
    dir_path_testdata = HomeFileModule.get_path(root_folder, contest_name, TESTDATA)

    HomeFileModule.empty_and_delete dir_path_originals
    HomeFileModule.empty_and_delete dir_path_testdata

    file_path_config = HomeFileModule.get_config_file(root_folder, contest_name)
    File.delete file_path_config

    dir_path_contest = File.join(root_folder, contest_name)

    Dir.delete (dir_path_contest)

  end

  def HomeFileModule.delete_generated_contest(contest_name)

    root_folder = ROOT_FOLDER
    dir_path_name_and_number = HomeFileModule.get_path(root_folder, contest_name, NAME_AND_NUMBER)
    dir_path_number = HomeFileModule.get_path(root_folder, contest_name, NUMBER)

    dir_path_contest = File.join(root_folder, contest_name)

    zip_path_name_and_number = File.join(dir_path_contest, "#{NAME_AND_NUMBER}.zip")
    File.delete(zip_path_name_and_number) if File.exist? zip_path_name_and_number
    zip_path_number = File.join(dir_path_contest, "#{NUMBER}.zip")
    File.delete(zip_path_number) if File.exist? zip_path_number
    zip_path_originals = File.join(dir_path_contest, "#{ORIGINALS}.zip")
    File.delete(zip_path_originals) if File.exist? zip_path_originals
    zip_path_testdata = File.join(dir_path_contest, "#{TESTDATA}.zip")
    File.delete(zip_path_testdata) if File.exist? zip_path_testdata

    HomeFileModule.empty_and_delete dir_path_name_and_number
    HomeFileModule.empty_and_delete dir_path_number

  end

  def HomeFileModule.empty_and_delete(dir_path)

    if Dir.exists? dir_path
      Dir.foreach(dir_path)do |filenane|
        filename_path = File.join(dir_path, filenane)
        if (! Dir.exists? filename_path)
          File.delete filename_path
        end
      end
      Dir.delete(dir_path)
    end
  end

  def HomeFileModule.generate_contest(contest_name)

    root_folder = ROOT_FOLDER
    dir_path_originals = HomeFileModule.get_originals_path(root_folder, contest_name)
    dir_path_testdata = HomeFileModule.get_testdata_path(root_folder, contest_name)
    dir_path_name_and_number = HomeFileModule.get_path(root_folder, contest_name, NAME_AND_NUMBER)
    dir_path_number = HomeFileModule.get_path(root_folder, contest_name, NUMBER)

    Dir.mkdir(dir_path_name_and_number)
    Dir.mkdir(dir_path_number)

    contest_content = HomeFileModule.get_dir_contents(dir_path_testdata, false)
    file_nums = (1..contest_content.length).to_a.sort { rand() - 0.5 }
    contest_content.each_index do |i|

      filename = contest_content[i]

      file_path_testdata = File.join(dir_path_testdata, filename)
      file_path_name_and_number = File.join(dir_path_name_and_number, "#{file_nums[i]}_#{filename}")
      file_path_number = File.join(dir_path_number, "#{file_nums[i]}.jpg")

      FileUtils.cp(file_path_testdata, file_path_name_and_number)
      FileUtils.cp(file_path_testdata, file_path_number)

      HomeFileModule.execute_exiftool("-all", file_path_number, "")

    end

    contest_dir = File.join(root_folder, contest_name)

    xxx = "zip #{File.join(contest_dir, "#{ORIGINALS}.zip")} #{dir_path_originals}/*"
    system xxx

    xxx = "zip #{File.join(contest_dir, "#{TESTDATA}.zip")} #{dir_path_testdata}/*"
    system xxx

    xxx = "zip #{File.join(contest_dir, "#{NAME_AND_NUMBER}.zip")} #{dir_path_name_and_number}/*"
    system xxx

    xxx = "zip #{File.join(contest_dir, "#{NUMBER}.zip")} #{dir_path_number}/*"
    system xxx

  end

  def HomeFileModule.rename_file(root_folder, contest_name, old_filename, new_filename)
    old_file_path_testdata = File.join(HomeFileModule.get_testdata_path(root_folder, contest_name), old_filename)
    new_file_path_testdata = File.join(HomeFileModule.get_testdata_path(root_folder, contest_name), new_filename)

    if File.exists?(old_file_path_testdata)
      File.rename(old_file_path_testdata, new_file_path_testdata)
    end
  end

end