# desc "Explaining what the task does"
# task :mastiff do
#   # Task goes here
# end
require "highline/import"

namespace :mastiff do

  desc "Clears cached inbox and removes local attachment storage artifacts"
  task :reset => :environment do
    Mastiff.attachment_uploader.flush
    Mastiff::Email::Message.processing.clear
    Mastiff::Email::Message.pending_attachments.clear
    Mastiff::Email::Message.emails.clear
    Mastiff::Email::Message.raw.clear
    Mastiff::Email::Message.uid_validity.delete
    Sidekiq::RetrySet.new.clear
    #message::pending_attachments

  end

  desc "Uninstalls Gem Generated files"
  task :uninstall  do
    install_files = [
      "config/initializers/mastiff.rb",
      "config/sidekiq.yml",
      "app/controllers/emails_controller.rb",
      "app/views/emails/index.html.erb",
      "app/assets/javascripts/emails.js.coffee",
      "app/assets/stylesheets/emails.css.scss",
      "app/workers/sync_mail_worker.rb",
      "app/workers/sync_attachment_worker.rb",
      "app/workers/process_attachment_worker.rb",
      "app/uploaders/mail_attachment_uploader.rb",
    ]
    install_files.each do |fpath|
      File.delete(fpath) if File.exist?(fpath)
    end
  end

  desc "Create paths for attachment storage"
  task :init_paths, [:attachment_path]   do
      p = attachment_path
      answer = ask("Attachment Path (Enter for Default) ") { |q|
        q.default   = "#{p}"
        #q.validate  = /^(left|right)$/i
      }
      mkpath(answer, verbose: true)

  end
end
