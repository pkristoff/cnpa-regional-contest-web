require 'rake'
require 'rails'

describe 'eslint' do


  before(:each) do

    @basedir = File.join(File.dirname(__FILE__), '../..')
  end

  it 'should run eslint RuleTest' do
    warnings = `mocha eslint/plugins/eslint-plugin-pattern/tests/**/*.js`
    expect(warnings).not_to match(/.*AssertionError/i)

  end

  it 'should walk through all the asset js files making sure they are valid' do

    Dir.chdir @basedir do
      warnings = `eslint  -c .eslintrc app/assets/javascripts/**/*.js`
      # puts "warnings: #{warnings}" unless warnings.nil? or warnings.empty?
      expect(warnings).to match(//)
    end
  end

  it 'should walk through all the spec js files making sure they are valid' do

    Dir.chdir @basedir do
      warnings = `eslint  -c .eslintrc angular/spec/**/*.js`
      # puts "warnings: #{warnings}" unless warnings.nil? or warnings.empty?
      expect(warnings).to eq('')
    end
  end

end