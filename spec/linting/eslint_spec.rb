require 'rake'
require 'rails'

describe 'eslint' do
  it 'should walk through all the js files making sure they are valid' do

    rake = Rake::Application.new
    Rake.application = rake
    Rake::Task.define_task(:environment)
    load 'lib/tasks/eslint.rake'
    begin
    result = rake['lint:run'].invoke(["#{File.dirname(__FILE__)}/../.."])
    rescue SystemExit => e
      expect(e.status).to eq(0)
    end
  end

end