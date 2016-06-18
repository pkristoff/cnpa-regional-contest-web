require 'rspec'

describe HomeFileModule do


  before(:each) do
    cleanup_dirs_and_files('TestContest')
  end

  after(:each) do
    cleanup_dirs_and_files('TestContest')
  end

  describe 'get_dir_contents' do

    before(:each) do
      cleanup_dirs_and_files('TestContest')
      Dir.mkdir('TestContest')
    end

    describe 'empty contents' do

      it 'should return directory contents' do

        HomeFileModule.get_dir_contents('TestContest', true).should == []

      end

      it 'should return directory contents' do

        HomeFileModule.get_dir_contents('TestContest', false).should == []

      end
    end

    describe 'one directory and one file contents' do

      before(:each) do
        Dir.mkdir('TestContest/q1')

        File.open('TestContest/foo.jpg', 'wb') { |f| f.write('') }
      end

      it 'should return directory contents' do

        HomeFileModule.get_dir_contents('TestContest', true).should == ['q1']

      end

      it 'should return directory contents' do

        HomeFileModule.get_dir_contents('TestContest', false).should == ['foo.jpg']

      end

    end

    after(:each) do
      cleanup_dirs_and_files('TestContest')
    end
  end

  describe 'get_and_render_contest_info - error' do

    it 'should render a status of 500 saying could not find path' do

      HomeFileModule.get_contest_info('TestContest', 'q1', 'xxx').should == [500, 'could not find path: TestContest/q1/xxx']

    end

  end

  describe 'get_and_render_contest_info' do

    before(:each) do
      cleanup_dirs_and_files('TestContest')

      setup_contest false
    end

    it 'should return no filenames & Testdata' do

      HomeFileModule.get_and_return_file_info([], 'TestContest', 'q1', 'Testdata').should.eql?(
          {
              json: {filenames: []},
              directories: %w(Originals Testdata),
              directory: 'Testdata'
          })

    end

    it 'should return no filenames & Testdata' do

      HomeFileModule.get_and_return_file_info([], 'TestContest', 'q1', 'Originals').should.eql?(
          {
              json: {filenames: []},
              directories: %w(Originals Testdata),
              directory: 'Originals'
          })

    end

    it 'should return one filename & Testdata' do

      copy_file(TEST_FILENAME_1, 'Testdata')
      copy_file(TEST_FILENAME_1, 'Originals')

      create_and_save_files_info

      HomeFileModule.get_and_return_file_info([TEST_FILENAME_1], 'TestContest', 'q1', 'Testdata').should == (
      {filenames: [
          TEST_FILE_INFO_TESTDATA],
       directories: %w(Originals Testdata),
       directory: 'Testdata'
      })

    end

    it 'should return one filename & Originals' do

      copy_file(TEST_FILENAME_1, 'Testdata')
      copy_file(TEST_FILENAME_1, 'Originals')

      create_and_save_files_info

      HomeFileModule.get_and_return_file_info([TEST_FILENAME_1], 'TestContest', 'q1', 'Originals').should == (
      {filenames: [
          TEST_FILE_INFO_ORIGINALS],
       directories: %w(Originals Testdata),
       directory: 'Originals'
      })

    end

  end


  describe 'get_contest_info' do

    before(:each) do
      cleanup_dirs_and_files('TestContest')
      setup_contest
    end

    it 'should return 1 filename & Testdata' do

      HomeFileModule.get_contest_info('TestContest', 'q1', 'Testdata').should == (
      {filenames: [
          TEST_FILE_INFO_TESTDATA],
       directories: %w(Originals Testdata),
       directory: 'Testdata', hasGeneratedContest: [false], isPictureAgeRequired: false, pictureAgeDate: "#{Date.today}"
      })

    end

  end

  describe 'create_contest' do

    it 'should return empty filenames and creates TestContest & TestContest/q1 & Testdata & Originals dirs' do

      File.exists?('TestContest').should == false

      HomeFileModule.create_contest('TestContest', 'q1').should == {
          filenames: [],
          directories: %w(Originals Testdata),
          directory: 'Testdata',
          hasGeneratedContest: false,
          isPictureAgeRequired: false,
          pictureAgeDate: Date.today
      }

      File.exists?('TestContest').should == true
      File.exists?('TestContest/q1').should == true
      File.exists?('TestContest/q1/Testdata').should == true
      File.exists?('TestContest/q1/Originals').should == true

    end

    it 'should return empty filenames and creates TestContest/q1 & Testdata & Originals dirs' do

      Dir.mkdir('TestContest')
      File.exists?('TestContest').should == true
      File.exists?('TestContest/q1').should == false

      HomeFileModule.create_contest('TestContest', 'q1').should == {
          filenames: [],
          directories: %w(Originals Testdata),
          directory: 'Testdata',
          hasGeneratedContest: false,
          isPictureAgeRequired: false,
          pictureAgeDate: Date.today}

      File.exists?('TestContest').should == true
      File.exists?('TestContest/q1').should == true
      File.exists?('TestContest/q1/Testdata').should == true
      File.exists?('TestContest/q1/Originals').should == true

    end

    it 'should return empty filenames with empty contest' do

      setup_contest false

      HomeFileModule.create_contest('TestContest', 'q1').should == {
          filenames: [],
          directories: %w(Originals Testdata),
          directory: 'Testdata',
          hasGeneratedContest: false,
          isPictureAgeRequired: false,
          pictureAgeDate: Date.today
      }

      File.exists?('TestContest').should == true
      File.exists?('TestContest/q1').should == true
      File.exists?('TestContest/q1/Testdata').should == true
      File.exists?('TestContest/q1/Originals').should == true

    end

    it 'should return empty filenames with empty contest' do

      setup_contest

      HomeFileModule.create_contest('TestContest', 'q1').should ==
          {filenames: [],
           directories: %w(Originals Testdata),
           directory: 'Testdata',
           hasGeneratedContest: false,
           isPictureAgeRequired: false,
           pictureAgeDate: Date.today
          }

      File.exists?('TestContest').should == true
      File.exists?('TestContest/q1').should == true
      File.exists?('TestContest/q1/Testdata').should == true
      File.exists?("TestContest/q1/Testdata/#{TEST_FILENAME_1}").should == false
      File.exists?('TestContest/q1/Originals').should == true
      File.exists?("TestContest/q1/Originals/#{TEST_FILENAME_1}").should == false
      HomeFileModule.get_file_info('q1', TEST_FILENAME_1, 'TestContest').nil?.should == true

    end

  end


  describe 'set_copyright' do

    it 'should change the copyright of Testdata file' do

      setup_contest

      HomeFileModule.set_copyright('TestContest', 'q1', TEST_FILENAME_1, 'copyright baby')

      HomeFileModule.get_file_info('q1', TEST_FILENAME_1, 'TestContest')[:copyrightNotice].should == 'copyright baby'
      get_copyright("TestContest/q1/Testdata/#{TEST_FILENAME_1}").should == 'copyright baby'
      get_copyright("TestContest/q1/Originals/#{TEST_FILENAME_1}").should_not == 'copyright baby'
    end

  end

  describe 'delete_generated_contest' do

    it 'should handle nothing there' do

      contest_name = 'q1'

      HomeFileModule.delete_generated_contest(contest_name)

      assert_generated_contest(contest_name, false)

    end

    it 'should handle contest not generated there' do

      setup_contest

      contest_name = 'q1'

      HomeFileModule.delete_generated_contest(contest_name)

      assert_generated_contest(contest_name, false)

    end

    it 'should handle contest generated there' do

      setup_contest

      contest_name = 'q1'

      HomeFileModule.generate_contest(contest_name)

      assert_generated_contest(contest_name, true)

      HomeFileModule.delete_generated_contest(contest_name)

      assert_generated_contest(contest_name, false)

    end

    it 'should handle contest generated there with renamed file' do

      setup_contest

      contest_name = 'q1'

      HomeFileModule.rename_file(HomeHelper::ROOT_FOLDER, contest_name, TEST_FILENAME_1, 'Paul kristoff - New Medow.jpg')

      HomeFileModule.generate_contest(contest_name)

      assert_generated_contest(contest_name, true)

      HomeFileModule.delete_generated_contest(contest_name)

      assert_generated_contest(contest_name, false)

      HomeFileModule.generate_contest(contest_name)

      assert_generated_contest(contest_name, true)

    end

  end
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

def get_copyright(filepath)
  exiftool_filepath = 'TestContest/temp.txt'
  HomeFileModule.execute_exiftool('-iptc:CopyrightNotice', filepath, exiftool_filepath)
  lines = IO.readlines(exiftool_filepath)
  lines[0].split(':')[1].strip.chomp
end