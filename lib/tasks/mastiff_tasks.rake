# desc "Explaining what the task does"
# task :air_oag do
#   # Task goes here
# end
namespace :air_oag do

  desc "Clears cached inbox and removes local attachment storage artifacts"
  task :reset => :environment do
    Mastiff.attachment_uploader.flush
    Mastiff::Email::Message.processing.clear
    Mastiff::Email::Message.emails.clear
    Mastiff::Email::Message.raw.clear
    Mastiff::Email::Message.uid_validity.delete
  end

  desc "Uninstalls Gem Generated files"
  task :uninstall => :environment do
    install_files = [
      "config/initializers/air_oag.rb",
      "config/sidekiq.yml",
      "app/workers/sync_mail_worker.rb",
      "app/workers/sync_attachment_worker.rb",
      "app/workers/process_attachment_worker.rb",
      "app/uploaders/mail_attachment_uploader.rb",
    ]
    install_files.each do |fpath|
      File.delete(fpath) if File.exist?(fpath)
    end
  end
end
