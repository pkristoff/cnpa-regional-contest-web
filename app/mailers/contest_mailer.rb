class ContestMailer < ActionMailer::Base
  default from: "retail@kristoffs.com"

  def contest_email(contest_name, directory, zip_file_path)
    @directory = directory
    mail.attachments[zip_file_path] = File.read(zip_file_path)
    message = mail(to: 'paul@kristoffs.com', from: 'paul@kristoffs.com',
         subject: "#{contest_name}: here are the files for directory: #{directory}",
         )
    begin
      message.deliver
    rescue Exception => e
      puts 'an error happened'
      puts e
    end
  end
end

