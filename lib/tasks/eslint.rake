namespace :lint	do
  task :run, :arg1 do | t, args |
    js_dir = "#{args[:arg1] ? args[:arg1][0] : Rails.root}/app/assets/javascripts"


    if only_file_to_check.nil?
      fl = FileList["#{js_dir}/**/**/*.js", "#{js_dir}/**/**/*.coffee"]
      fl.exclude("#{js_dir}/**/**/application.js")
    else
      fl = FileList["#{js_dir}/**/**/#{only_file_to_check}"]
    end
    # puts fl
    # puts "Dir: #{js_dir}"
    exit_value = 0
    result = ''
    fl.each do |file|
      # puts("Executing: #{file}")
      ans =  `rake eslint:run[#{file}]`
      puts ans if exit_value==1
      exit_value = (exit_value==1 or !ans.include?('All good! :)')) ? 1 : 0
      result += "#{file}: #{ans}"
      # result << [file, ans]
    end

    # result.each do | arr |
    #   puts "#{arr[0]}: #{arr[1]}"
    # end
    puts result
    exit exit_value
  end
  def only_file_to_check
    # 'images-controller.js'
    nil
  end

end