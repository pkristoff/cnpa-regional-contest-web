TEST_FILENAME_1 = 'test-data_lower-full.jpeg'

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

def setup_initial_contest(empty_contest=false)
  stub_const('HomeHelper::ROOT_FOLDER', @root_folder)
  Dir.mkdir(@root_folder)
  Dir.mkdir("#{@root_folder}/#{@contest_name}")
  @dir_path_testdata = HomeHelper.get_testdata_path(@root_folder, @contest_name)
  @dir_path_originals = HomeHelper.get_originals_path(@root_folder, @contest_name)
  Dir.mkdir(@dir_path_testdata)
  Dir.mkdir(@dir_path_originals)

  unless empty_contest
    test_file_path = 'spec/test_data/'
    Dir.foreach(test_file_path) do |filename|
      testdata_file_path = File.join(test_file_path, filename)
      unless File.directory?(testdata_file_path)
        FileUtils.cp(testdata_file_path, File.join(@dir_path_originals, filename))
        FileUtils.cp(testdata_file_path, File.join(@dir_path_testdata, filename))
      end
    end
  end
  create_and_save_files_info ! empty_contest
end

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
  FileUtils.cp("spec/test_data/#{filename}", "TestContest/q1/#{dir}/#{filename}")
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

  expect(File.exist?(dir_path_name_and_number)).to eq(is_generated)
  expect(File.exist?(dir_path_number)).to eq(is_generated)

  contest_dir = File.join(root_folder, contest_name)
  expect(File.exist?(File.join(contest_dir, 'contest.zip'))).to eq(is_generated)
  expect(File.exist?(File.join(contest_dir, "#{HomeHelper::ORIGINALS}.zip"))).to eq(false)
  expect(File.exist?(File.join(contest_dir, "#{HomeHelper::TESTDATA}.zip"))).to eq(false)
  expect(File.exist?(File.join(contest_dir, "#{HomeHelper::NAME_AND_NUMBER}.zip"))).to eq(false)
  expect(File.exist?(File.join(contest_dir, "#{HomeHelper::NUMBER}.zip"))).to eq(false)
end