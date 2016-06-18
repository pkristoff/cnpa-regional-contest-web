

TEST_FILENAME_1 = 'Paul - New Medow.jpg'

TEST_FILE_INFO_TESTDATA = {
    filename: TEST_FILENAME_1,
    original_filename: TEST_FILENAME_1,
    imageWidth: 1024,
    imageHeight: 683,
    copyrightNotice: 'Paul Kristoff',
    title: 'Grassland',
    dateCreated: '2012-01-15',
    fileSize: 249
}
TEST_FILE_INFO_ORIGINALS = {
    filename: TEST_FILENAME_1,
    imageWidth: '1024',
    imageHeight: '683',
    copyrightNotice: 'Paul Kristoff',
    title: 'Grassland',
    dateCreated: Date.new(2012, 1, 15),
    fileSize: '249'
}

def setup_contest(should_copy_file=true)

  stub_const('HomeHelper::ROOT_FOLDER', 'TestContest')

  Dir.mkdir('TestContest')
  Dir.mkdir('TestContest/q1')
  Dir.mkdir('TestContest/q1/Testdata')
  Dir.mkdir('TestContest/q1/Originals')
  copy_file(TEST_FILENAME_1, 'Testdata') if should_copy_file
  copy_file(TEST_FILENAME_1, 'Originals') if should_copy_file

  create_and_save_files_info should_copy_file

end

def create_and_save_files_info(should_copy_file=true)

  files_info = []

  if should_copy_file
    files_info = [{
                      filename: TEST_FILENAME_1,
                      original_filename: TEST_FILENAME_1,
                      imageWidth: 1024,
                      imageHeight: 683,
                      copyrightNotice: 'Paul Kristoff',
                      title: 'Grassland',
                      dateCreated: '2012-01-15',
                      fileSize: 249
                  }]
  end

  HomeFileModule.save_files_info files_info, 'q1', 'TestContest'
end


def copy_file(filename, dir)
  file_path = "spec/test_data/#{filename}"
  File.open(file_path, 'r') do |from_file|
    File.open("TestContest/q1/#{dir}/#{filename}", 'wb') { |to_file| to_file.write(from_file.read) }
  end
end

def cleanup_dirs_and_files(path)
  if Dir.exists? path and !path.end_with?('.') and !path.end_with?('..')
    if File.directory? path
      Dir.foreach(path) do |entry|
        file_path = File.join(path, entry)
        cleanup_dirs_and_files(file_path)
      end
      Dir.rmdir(path)
    end
  else
    if File.exists? path and !path.end_with?('.') and !path.end_with?('..')
      File.delete(path)
    end
  end
end

def assert_generated_contest(contest_name, is_generated)
  root_folder = HomeHelper::ROOT_FOLDER
  dir_path_name_and_number = HomeHelper.get_path(root_folder, contest_name, HomeHelper::NAME_AND_NUMBER)
  dir_path_number = HomeHelper.get_path(root_folder, contest_name, HomeHelper::NUMBER)

  File.exist?(dir_path_name_and_number).should == is_generated
  File.exist?(dir_path_number).should == is_generated

  contest_dir = File.join(root_folder, contest_name)
  File.exist?(File.join(contest_dir, 'contest.zip')).should == is_generated
  File.exist?(File.join(contest_dir, "#{HomeHelper::ORIGINALS}.zip")).should == false
  File.exist?(File.join(contest_dir, "#{HomeHelper::TESTDATA}.zip")).should == false
  File.exist?(File.join(contest_dir, "#{HomeHelper::NAME_AND_NUMBER}.zip")).should == false
  File.exist?(File.join(contest_dir, "#{HomeHelper::NUMBER}.zip")).should == false
end