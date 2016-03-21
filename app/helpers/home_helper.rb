module HomeHelper

  TESTDATA = 'Testdata'
  ORIGINALS = 'Originals'
  EXIFTOOL_FILE_INFO = 'exif.txt'
  ROOT_FOLDER = 'Contests'
  NAME_AND_NUMBER = 'name_and_number'
  NUMBER = 'number'
  FILES_INFO = 'files_info.json'

  def HomeHelper.get_originals_path(root_folder, contest_name)
    HomeHelper.get_path(root_folder, contest_name, ORIGINALS);
  end

  def HomeHelper.get_testdata_path(root_folder, contest_name)
    HomeHelper.get_path(root_folder, contest_name, TESTDATA);
  end

  def HomeHelper.get_path(root_folder, contest_name, directory)
    File.join(root_folder, contest_name, directory)
  end

  def HomeHelper.get_initial_directories
    [ORIGINALS, TESTDATA]
  end
end
