module HomeFileModule
  TESTDATA = 'Testdata'
  ORIGINALS = 'Originals'
  EXIFTOOL_FILE_INFO = 'exif.txt'

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

  def HomeFileModule.get_dir_contents(dir_path, for_dir)
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

  def HomeFileModule.get_contest_info(root_folder, contest_name, dir)
    dir_path = HomeFileModule.get_path(root_folder, contest_name, dir)
    begin
      if Dir.exists?(dir_path)
        contest_content = HomeFileModule.get_dir_contents(dir_path, false)
        result = HomeFileModule.get_and_return_file_info(contest_content, dir_path, dir)
      else
        return 500, "could not find path: #{dir_path}"
      end
    rescue Exception => e
      return 500, "could not find path: #{dir_path}: #{e.message}"
    end
    return result
  end

  def HomeFileModule.get_and_return_file_info(contest_content, dir_path, directory)
    result = {
        filenames: [],
        directories: HomeFileModule.get_initial_directories(),
        directory: directory
    }

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
                file_info[:dateCreated] = value.strip
              elsif key == 'File Size'
                size_split = value.strip.split(' ')
                if size_split[1].strip == 'kB'
                  file_info[:fileSize] = size_split[0].strip
                else
                  file_info[:fileSize] = "filesize not in kB but is '#{size_split[1].strip}'"
                end
              end
            end
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
              :directories => HomeFileModule.get_initial_directories(),
              :directory => HomeFileModule.get_testdata()
    }
    dir_path = root_folder + '/' + contest_name + '/'
    if Dir.exists?(dir_path)
      dir_path = HomeFileModule.get_originals_path(root_folder, contest_name)
      if Dir.exists?(dir_path)
        result = HomeFileModule.get_contest_info(root_folder, contest_name, TESTDATA)
      else
        Dir.mkdir(dir_path)
      end
    else
      Dir.mkdir(dir_path)
      Dir.mkdir(HomeFileModule.get_originals_path(root_folder, contest_name))
      Dir.mkdir(HomeFileModule.get_testdata_path(root_folder, contest_name))
    end
    return result
  end

  def HomeFileModule.set_copyright(root_folder, contest_name, filename, copyright)
    file_path_testdata = File.join(HomeFileModule.get_testdata_path(root_folder, contest_name), filename)

    HomeFileModule.execute_exiftool("-iptc:CopyrightNotice=\"#{copyright}\"", file_path_testdata, "")
  end

end