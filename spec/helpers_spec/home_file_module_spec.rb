require 'rspec'
puts Dir.pwd
require_relative '../../app/helpers/home_file_module'
require_relative '../../spec/support/common'

describe 'HomeFileModule' do


  before(:each) do
    @root_folder = 'TestContest'
    @contest_name = 'q1'
    @today = Date.today
    @dir_path_contest = File.join(@root_folder, @contest_name)
    @dir_path_testdata = HomeHelper.get_testdata_path(@root_folder, @contest_name)
    @dir_path_originals = HomeHelper.get_originals_path(@root_folder, @contest_name)
    cleanup_dirs_and_files(@root_folder)
  end

  after(:each) do
    cleanup_dirs_and_files(@root_folder)
  end

  describe 'get_dir_contents' do

    before(:each) do
      cleanup_dirs_and_files(@root_folder)
      Dir.mkdir(@root_folder)
    end

    describe 'empty contents' do

      it 'should return directory contents' do

        HomeFileModule.get_dir_contents(@root_folder, true).should == []

      end

      it 'should return directory contents' do

        HomeFileModule.get_dir_contents(@root_folder, false).should == []

      end
    end

    describe 'one directory and one file contents' do

      before(:each) do
        Dir.mkdir(@dir_path_contest)

        File.open('TestContest/foo.jpg', 'wb') { |f| f.write('') }
      end

      it 'should return directory contents' do

        HomeFileModule.get_dir_contents(@root_folder, true).should == [@contest_name]

      end

      it 'should return directory contents' do

        HomeFileModule.get_dir_contents(@root_folder, false).should == ['foo.jpg']

      end

    end

    after(:each) do
      cleanup_dirs_and_files(@root_folder)
    end
  end

  describe 'get_and_render_contest_info - error' do

    it 'should render a status of 500 saying could not find path' do

      HomeFileModule.get_contest_info(@root_folder, @contest_name, 'xxx').should == [500, 'could not find path: TestContest/q1/xxx']

    end

  end

  describe 'get_and_render_contest_info' do

    before(:each) do
      cleanup_dirs_and_files(@root_folder)

      setup_contest false
    end

    it 'should return no filenames & Testdata' do

      HomeFileModule.get_and_return_file_info([], @root_folder, @contest_name, 'Testdata').should.eql?(
          {
              json: {filenames: []},
              directories: %w(Originals Testdata),
              directory: 'Testdata'
          })

    end

    it 'should return no filenames & Testdata' do

      HomeFileModule.get_and_return_file_info([], @root_folder, @contest_name, 'Originals').should.eql?(
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

      HomeFileModule.get_and_return_file_info([TEST_FILENAME_1], @root_folder, @contest_name, 'Testdata').should == (
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

      HomeFileModule.get_and_return_file_info([TEST_FILENAME_1], @root_folder, @contest_name, 'Originals').should == (
      {filenames: [
          TEST_FILE_INFO_ORIGINALS],
       directories: %w(Originals Testdata),
       directory: 'Originals'
      })

    end

  end


  describe 'get_contest_info' do

    before(:each) do
      cleanup_dirs_and_files(@root_folder)
      setup_contest
    end

    it 'should return 1 filename & Testdata' do

      HomeFileModule.get_contest_info(@root_folder, @contest_name, 'Testdata').should == (
      {filenames: [
          TEST_FILE_INFO_TESTDATA],
       directories: %w(Originals Testdata),
       directory: 'Testdata', hasGeneratedContest: [false], isPictureAgeRequired: false, pictureAgeDate: "#{Date.today}",
       max_size: Size::MAX_SIZE, max_width: Size::MAX_WIDTH, max_height: Size::MAX_HEIGHT
      })

    end

  end

  describe 'create_contest' do

    it 'should return empty filenames and creates TestContest & TestContest/q1 & Testdata & Originals dirs' do

      File.exists?(@root_folder).should == false

      HomeFileModule.create_contest(@root_folder, @contest_name).should == {
          filenames: [],
          directories: %w(Originals Testdata),
          directory: 'Testdata',
          hasGeneratedContest: false,
          isPictureAgeRequired: false,
          pictureAgeDate: Date.today,
          max_size: Size::MAX_SIZE, max_width: Size::MAX_WIDTH, max_height: Size::MAX_HEIGHT
      }

      File.exists?(@root_folder).should == true
      File.exists?(@dir_path_contest).should == true
      File.exists?(@dir_path_testdata).should == true
      File.exists?(@dir_path_originals).should == true

    end

    it 'should return empty filenames and creates TestContest/q1 & Testdata & Originals dirs' do

      Dir.mkdir(@root_folder)
      File.exists?(@root_folder).should == true
      File.exists?(@dir_path_contest).should == false

      HomeFileModule.create_contest(@root_folder, @contest_name).should == {
          filenames: [],
          directories: %w(Originals Testdata),
          directory: 'Testdata',
          hasGeneratedContest: false,
          isPictureAgeRequired: false,
          pictureAgeDate: Date.today,
          max_size: Size::MAX_SIZE, max_width: Size::MAX_WIDTH, max_height: Size::MAX_HEIGHT
      }

      File.exists?(@root_folder).should == true
      File.exists?(@dir_path_contest).should == true
      File.exists?(@dir_path_testdata).should == true
      File.exists?(@dir_path_originals).should == true

    end

    it 'should return empty filenames with empty contest' do

      setup_contest false

      HomeFileModule.create_contest(@root_folder, @contest_name).should == {
          filenames: [],
          directories: %w(Originals Testdata),
          directory: 'Testdata',
          hasGeneratedContest: false,
          isPictureAgeRequired: false,
          pictureAgeDate: Date.today,
          max_size: Size::MAX_SIZE, max_width: Size::MAX_WIDTH, max_height: Size::MAX_HEIGHT
      }

      File.exists?(@root_folder).should == true
      File.exists?(@dir_path_contest).should == true
      File.exists?(@dir_path_testdata).should == true
      File.exists?(@dir_path_originals).should == true

    end

    it 'should return empty filenames with empty contest' do

      setup_contest

      HomeFileModule.create_contest(@root_folder, @contest_name).should ==
          {filenames: [],
           directories: %w(Originals Testdata),
           directory: 'Testdata',
           hasGeneratedContest: false,
           isPictureAgeRequired: false,
           pictureAgeDate: Date.today,
           max_size: Size::MAX_SIZE, max_width: Size::MAX_WIDTH, max_height: Size::MAX_HEIGHT
          }

      File.exists?(@root_folder).should == true
      File.exists?(@dir_path_contest).should == true
      File.exists?(@dir_path_testdata).should == true
      File.exists?("#{@dir_path_testdata}#{TEST_FILENAME_1}").should == false
      File.exists?(@dir_path_originals).should == true
      File.exists?("#{@dir_path_originals}/#{TEST_FILENAME_1}").should == false
      HomeFileModule.get_file_info(@contest_name, TEST_FILENAME_1, @root_folder).nil?.should == true

    end

  end


  describe 'set_copyright' do

    it 'should change the copyright of Testdata file' do

      setup_contest

      HomeFileModule.set_copyright(@root_folder, @contest_name, TEST_FILENAME_1, 'copyright baby')

      HomeFileModule.get_file_info(@contest_name, TEST_FILENAME_1, @root_folder)[:copyrightNotice].should == 'copyright baby'
      get_copyright("#{@dir_path_testdata}/#{TEST_FILENAME_1}").should == 'copyright baby'
      get_copyright("#{@dir_path_originals}/#{TEST_FILENAME_1}").should_not == 'copyright baby'
    end

  end

  describe 'delete_generated_contest' do

    it 'should handle nothing there' do

      HomeFileModule.delete_generated_contest(@contest_name)

      assert_generated_contest(@contest_name, false)

    end

    it 'should handle contest not generated there' do

      setup_contest

      HomeFileModule.delete_generated_contest(@contest_name)

      assert_generated_contest(@contest_name, false)

    end

    it 'should handle contest generated there' do

      setup_contest

      HomeFileModule.generate_contest(@contest_name)

      assert_generated_contest(@contest_name, true)

      HomeFileModule.delete_generated_contest(@contest_name)

      assert_generated_contest(@contest_name, false)

    end

    it 'should handle contest generated there with renamed file' do

      setup_contest

      HomeFileModule.rename_file(HomeHelper::ROOT_FOLDER, @contest_name, TEST_FILENAME_1, 'Paul kristoff - New Medow.jpg')

      HomeFileModule.generate_contest(@contest_name)

      assert_generated_contest(@contest_name, true)

      HomeFileModule.delete_generated_contest(@contest_name)

      assert_generated_contest(@contest_name, false)

      HomeFileModule.generate_contest(@contest_name)

      assert_generated_contest(@contest_name, true)

    end

    it 'should generate the number filename with only one "." ' do

      setup_initial_contest(false)

      HomeFileModule.generate_contest(@contest_name)

      dir_path_number = HomeHelper.get_path(@root_folder, @contest_name, HomeHelper::NUMBER)

      found_file = false

      HomeFileModule.get_dir_contents(dir_path_number, false).each do | filename |
        unless filename === '.' || filename === '..'
          found_file = true
          expect(filename.include?('..')).to eq(false)
        end
      end

      expect(found_file).to eq(true)

    end


  end

  describe 'config_info' do

    it 'should create a path to config.json' do
      expect(HomeFileModule.get_config_file(@root_folder, @contest_name)).to eq('TestContest/q1/config.json')
    end

    it 'should save config_info to a file' do
      Dir.mkdir(@root_folder)
      Dir.mkdir("#{@root_folder}/#{@contest_name}")
      contest_config_path = HomeFileModule.get_config_file(@root_folder, @contest_name)
      HomeFileModule.save_config_info(@root_folder, @contest_name, true, @today, 123, 456, 789)
      json = JSON.parse(File.read(contest_config_path))

      expect(json['is_picture_age_required']).to eq(true)
      expect(json['picture_age_date']).to eq(@today.to_s)
      expect(json['max_size']).to eq(123)
      expect(json['max_width']).to eq(456)
      expect(json['max_height']).to eq(789)
    end

    it 'should initialize config_info' do
      Dir.mkdir(@root_folder)
      Dir.mkdir("#{@root_folder}/#{@contest_name}")

      json = HomeFileModule.get_config_info(@root_folder, @contest_name)

      expect(json['is_picture_age_required']).to eq(false)
      expect(json['picture_age_date']).to eq(@today.to_s)
    end

    it 'should retrieve config_info from a file' do
      Dir.mkdir(@root_folder)
      Dir.mkdir("#{@root_folder}/#{@contest_name}")
      HomeFileModule.save_config_info(@root_folder, @contest_name, true, @today, '987', '654', '321')

      json = HomeFileModule.get_config_info(@root_folder, @contest_name)

      expect(json['is_picture_age_required']).to eq(true)
      expect(json['picture_age_date']).to eq(@today.to_s)
      expect(json['max_size']).to eq('987')
      expect(json['max_width']).to eq('654')
      expect(json['max_height']).to eq('321')
    end

  end

  describe 'delete_contest' do

    before(:each) do

      stub_const('HomeHelper::ROOT_FOLDER', @root_folder)

      cleanup_dirs_and_files(@root_folder)
    end

    after(:each) do
      cleanup_dirs_and_files(@root_folder)
    end

    it 'should delete an contest directory' do

      Dir.mkdir(@root_folder)
      Dir.mkdir(@dir_path_contest)

      HomeFileModule.delete_contest(@contest_name)

      expect(Dir.exist?(@dir_path_contest)).to eq(false)

    end

    it 'should delete a contest with no pictures' do

      setup_initial_contest(true)

      HomeFileModule.delete_contest(@contest_name)

      expect(Dir.exist?(@dir_path_contest)).to eq(false)
    end

    it 'should delete a contest with pictures' do

      setup_initial_contest(false)

      # this is created by the mac's finder program
      File.open("#{@dir_path_contest}/'.DS_Store'", 'wb') { |to_file| to_file.write('from_file.read') }

      HomeFileModule.delete_contest(@contest_name)

      expect(Dir.exist?(@dir_path_contest)).to eq(false)

    end

  end


  describe 'generate_contest' do
    it 'should generate zip files with the different types of jpg file extensions' do
      setup_initial_contest

      HomeFileModule.generate_contest(@contest_name)

      name_and_number_path = HomeHelper.get_path(@root_folder, @contest_name, HomeHelper::NAME_AND_NUMBER)
      expect(Dir.exist?(name_and_number_path)).to eq(true)
      number_path = HomeHelper.get_path(@root_folder, @contest_name, HomeHelper::NUMBER)
      expect(Dir.exist?(number_path)).to eq(true)

      number_content = HomeFileModule.get_dir_contents(number_path, false).sort

      expect(number_content.size).to eq(4)

      expect(File.exists?(File.join(File.join(@root_folder, @contest_name), 'contest.zip')))

    end
  end

  describe 'get_dir_contents' do
    it 'should generate zip files' do
      setup_initial_contest

      contents = HomeFileModule.get_dir_contents(@dir_path_testdata, false)

      expect(contents.size).to eq(4)
      contents.each do |filename|
        expect(jpg_endings = Jpeg_endings::MAPPING_DOT.include?(File.extname(filename))).to eq(true)
      end

    end
  end
end

def get_copyright(filepath)
  exiftool_filepath = 'TestContest/temp.txt'
  HomeFileModule.execute_exiftool('-iptc:CopyrightNotice', filepath, exiftool_filepath)
  lines = IO.readlines(exiftool_filepath)
  lines[0].split(':')[1].strip.chomp
end