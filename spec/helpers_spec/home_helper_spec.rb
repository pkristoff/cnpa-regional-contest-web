require 'spec_helper'


describe HomeHelper do

  describe 'pathes' do

    it 'should return a joined path' do

      expect(HomeHelper.get_path('root', 'contest', 'dir')).to eq('root/contest/dir')

    end

    it 'should return a joined path ending in Testdata' do

      expect(HomeHelper.get_testdata_path('root', 'contest')).to eq('root/contest/Testdata')

    end

    it 'should return a joined path ending in Originals' do
      expect(HomeHelper.get_originals_path('root', 'contest')).to eq('root/contest/Originals')

    end

    it 'should return an array of Originals & Testdata' do

      expect(HomeHelper.get_initial_directories).to eq(%w(Originals Testdata))

    end

  end

  describe 'constants' do

    it 'HomeHelper::TESTDATA' do

      expect(HomeHelper::TESTDATA).to eq('Testdata')

    end

    it 'HomeHelper::ORIGINALS' do

      expect(HomeHelper::ORIGINALS).to eq('Originals')

    end

    it 'HomeHelper::EXIFTOOL_FILE_INFO' do

      expect(HomeHelper::EXIFTOOL_FILE_INFO).to eq('exif.txt')

    end

    it 'HomeHelper::ROOT_FOLDER' do

      expect(HomeHelper::ROOT_FOLDER).to eq('Contests')

    end

    it 'HomeHelper::NAME_AND_NUMBER' do

      expect(HomeHelper::NAME_AND_NUMBER).to eq('name_and_number')

    end

    it 'HomeHelper::NUMBER' do

      expect(HomeHelper::NUMBER).to eq('number')

    end

    it 'should return  files_info.json' do

      expect(HomeHelper::FILES_INFO).to eq('files_info.json')

    end
  end
end
