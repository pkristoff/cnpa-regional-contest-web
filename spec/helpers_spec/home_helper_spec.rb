require 'spec_helper'


describe HomeHelper do

  describe 'pathes' do

    it 'should return a joined path' do

      HomeHelper.get_path('root', 'contest', 'dir').should == 'root/contest/dir'

    end

    it 'should return a joined path ending in Testdata' do

      HomeHelper.get_testdata_path('root', 'contest').should == 'root/contest/Testdata'

    end

    it 'should return a joined path ending in Originals' do

      HomeHelper.get_originals_path('root', 'contest').should == 'root/contest/Originals'

    end

    it 'should return an array of Originals & Testdata' do

      HomeHelper.get_initial_directories.should == %w(Originals Testdata)

    end

  end

  describe 'constants' do

    it 'HomeHelper::TESTDATA' do

      HomeHelper::TESTDATA.should == 'Testdata'

    end

    it 'HomeHelper::ORIGINALS' do

      HomeHelper::ORIGINALS.should == 'Originals'

    end

    it 'HomeHelper::EXIFTOOL_FILE_INFO' do

      HomeHelper::EXIFTOOL_FILE_INFO.should == 'exif.txt'

    end

    it 'HomeHelper::ROOT_FOLDER' do

      HomeHelper::ROOT_FOLDER.should == 'Contests'

    end

    it 'HomeHelper::NAME_AND_NUMBER' do

      HomeHelper::NAME_AND_NUMBER.should == 'name_and_number'

    end

    it 'HomeHelper::NUMBER' do

      HomeHelper::NUMBER.should == 'number'

    end

    it 'should return  files_info.json' do

      HomeHelper::FILES_INFO.should == 'files_info.json'

    end
  end
end
