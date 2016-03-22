class ContestMailer < ActionMailer::Base
  default from: 'retail@kristoffs.com'

  def contest_email(contest_name, email_address, directory, zip_file_path)
    @directory = directory
    mail.attachments[zip_file_path] = File.read(zip_file_path)
    message = mail(to: email_address, from: 'photo@paulkristoff.com',
                   subject: "#{contest_name}: here are the files for directory: #{directory}",
    )
    begin
      message.deliver
    rescue Exception => e
      puts 'an error happened'
      puts e
      raise e
    end
  end
end

