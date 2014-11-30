require 'rspec'

TEST_FILENAME_1 = 'Paul - New Medow.jpg'

TEST_FILFENAME_1_INFO = {
    :filename => TEST_FILENAME_1,
    :imageWidth => '1024',
    :imageHeight => '683',
    :copyrightNotice => 'Paul Kristoff',
    :title => 'Grassland',
    :dateCreated => '2012',
    :fileSize => '249'
}

describe HomeFileModule do

  describe 'get_path' do

    it 'should return a joined path' do

      HomeFileModule.get_path('root', 'contest', 'dir').should == 'root/contest/dir'

    end
  end

  describe 'get_testdata_path' do

    it 'should return a joined path ending in Testdata' do

      HomeFileModule.get_testdata_path('root', 'contest').should == 'root/contest/Testdata'

    end
  end

  describe 'get_originals_path' do

    it 'should return a joined path ending in Originals' do

      HomeFileModule.get_originals_path('root', 'contest').should == 'root/contest/Originals'

    end
  end

  describe 'get_initial_directories' do

    it 'should return an array of Originals & Testdata' do

      HomeFileModule.get_initial_directories.should == ['Originals', 'Testdata']

    end
  end

  describe 'get_testdata' do

    it 'should return  Testdata' do

      HomeFileModule.get_testdata.should == 'Testdata'

    end
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

        File.open('TestContest/foo.jpg', "wb") { |f| f.write('') }
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

      HomeFileModule.get_contest_info('TestContest', 'q1', 'xxx').should == [500, "could not find path: TestContest/q1/xxx"]

    end

  end

  describe 'get_and_render_contest_info' do

    before(:each) do
      cleanup_dirs_and_files('TestContest')
      Dir.mkdir('TestContest')
      Dir.mkdir('TestContest/q1')
      Dir.mkdir('TestContest/q1/Testdata')
      Dir.mkdir('TestContest/q1/Originals')
    end

    it 'should return no filenames & Testdata' do

      HomeFileModule.get_and_return_file_info([], 'TestContest/q1/Testdata', 'Testdata').should.eql?(
          {
              :json => {:filenames => []},
              directories: ['Originals', 'Testdata'],
              directory: 'Testdata'
          })

    end

    it 'should return no filenames & Testdata' do

      HomeFileModule.get_and_return_file_info([], 'TestContest/q1/Originals', 'Originals').should.eql?(
          {
              :json => {:filenames => []},
              directories: ['Originals', 'Testdata'],
              directory: 'Originals'
          })

    end

    it 'should return one filename & Testdata' do

      copy_file(TEST_FILENAME_1, 'Testdata')


      HomeFileModule.get_and_return_file_info([TEST_FILENAME_1], 'TestContest/q1/Testdata', 'Testdata').should == (
      {:filenames => [
          TEST_FILFENAME_1_INFO],
       directories: ['Originals', 'Testdata'],
       directory: 'Testdata'
      })

    end

    it 'should return one filename & Originals' do

      copy_file(TEST_FILENAME_1, 'Originals')


      HomeFileModule.get_and_return_file_info([TEST_FILENAME_1], 'TestContest/q1/Originals', 'Originals').should == (
      {:filenames => [
          TEST_FILFENAME_1_INFO],
       directories: ['Originals', 'Testdata'],
       directory: 'Originals'
      })

    end

    after(:each) do
      cleanup_dirs_and_files('TestContest')
    end

  end


  describe 'get_contest_info' do

    before(:each) do
      cleanup_dirs_and_files('TestContest')
      Dir.mkdir('TestContest')
      Dir.mkdir('TestContest/q1')
      Dir.mkdir('TestContest/q1/Testdata')
      Dir.mkdir('TestContest/q1/Originals')
      copy_file(TEST_FILENAME_1, 'Testdata')
    end

    it 'should return 1 filename & Testdata' do

      HomeFileModule.get_contest_info('TestContest', 'q1', 'Testdata').should == (
      {:filenames => [
          TEST_FILFENAME_1_INFO],
       directories: ['Originals', 'Testdata'],
       directory: 'Testdata'
      })

    end

  end

  describe 'create_contest' do

    before(:each) do
      cleanup_dirs_and_files('TestContest')
    end

    it 'should return empty filenames and creates TestContest & TestContest/q1 & Testdata & Originals dirs' do

      File.exists?('TestContest').should == false

      HomeFileModule.create_contest('TestContest', 'q1').should == {:filenames => [], :directories => ["Originals", "Testdata"], :directory => "Testdata"}

      File.exists?('TestContest').should == true
      File.exists?('TestContest/q1').should == true
      File.exists?('TestContest/q1/Testdata').should == true
      File.exists?('TestContest/q1/Originals').should == true

    end

    it 'should return empty filenames and creates TestContest/q1 & Testdata & Originals dirs' do

      Dir.mkdir('TestContest')
      File.exists?('TestContest').should == true
      File.exists?('TestContest/q1').should == false

      HomeFileModule.create_contest('TestContest', 'q1').should == {:filenames => [], :directories => ["Originals", "Testdata"], :directory => "Testdata"}

      File.exists?('TestContest').should == true
      File.exists?('TestContest/q1').should == true
      File.exists?('TestContest/q1/Testdata').should == true
      File.exists?('TestContest/q1/Originals').should == true

    end

    it 'should return empty filenames with empty contest' do

      Dir.mkdir('TestContest')
      Dir.mkdir('TestContest/q1')
      Dir.mkdir('TestContest/q1/Testdata')
      Dir.mkdir('TestContest/q1/Originals')

      HomeFileModule.create_contest('TestContest', 'q1').should == {:filenames => [], :directories => ["Originals", "Testdata"], :directory => "Testdata"}

      File.exists?('TestContest').should == true
      File.exists?('TestContest/q1').should == true
      File.exists?('TestContest/q1/Testdata').should == true
      File.exists?('TestContest/q1/Originals').should == true

    end

    it 'should return empty filenames with empty contest' do

      Dir.mkdir('TestContest')
      Dir.mkdir('TestContest/q1')
      Dir.mkdir('TestContest/q1/Testdata')
      Dir.mkdir('TestContest/q1/Originals')
      copy_file(TEST_FILENAME_1, 'Testdata')

      HomeFileModule.create_contest('TestContest', 'q1').should ==
          {:filenames => [
              TEST_FILFENAME_1_INFO],
           directories: ['Originals', 'Testdata'],
           directory: 'Testdata'
          }

      File.exists?('TestContest').should == true
      File.exists?('TestContest/q1').should == true
      File.exists?('TestContest/q1/Testdata').should == true
      File.exists?('TestContest/q1/Originals').should == true

    end

  end


  describe 'set_copyright' do

    before(:each) do
      cleanup_dirs_and_files('TestContest')
    end

    it 'should change the copyright of Testdata file' do

      Dir.mkdir('TestContest')
      Dir.mkdir('TestContest/q1')
      Dir.mkdir('TestContest/q1/Testdata')
      Dir.mkdir('TestContest/q1/Originals')
      copy_file(TEST_FILENAME_1, 'Testdata')
      copy_file(TEST_FILENAME_1, 'Originals')

      HomeFileModule.set_copyright('TestContest', 'q1', TEST_FILENAME_1, 'copyright baby')

      get_copyright("TestContest/q1/Testdata/#{TEST_FILENAME_1}").should == 'copyright baby'
      get_copyright("TestContest/q1/Originals/#{TEST_FILENAME_1}").should_not == 'copyright baby'
    end

  end
end

def copy_file(filename, dir)
  file_path = "spec/test_data/#{filename}"
  File.open(file_path, 'r') do |from_file|
    File.open("TestContest/q1/#{dir}/#{filename}", "wb") { |to_file| to_file.write(from_file.read) }
  end
end

def cleanup_dirs_and_files path
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
  HomeFileModule.execute_exiftool("-iptc:CopyrightNotice", filepath, exiftool_filepath)
  lines = IO.readlines(exiftool_filepath)
  lines[0].split(':')[1].strip.chomp
end