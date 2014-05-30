#
# When a generator is invoked, each public method in the generator is executed sequentially in the order that it is defined.
# http://guides.rubyonrails.org/generators.html
#
#require 'rails/generators'
module Mastiff
    class InstallGenerator < Rails::Generators::Base


      desc "Creates a Mastiff initializer and copies default workers and uploader files to your application."
      #class_option :orm
      #def self.source_root
      #     @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      #end
      source_root File.expand_path("../templates", __FILE__)

      def create_routes
        route "mount Mastiff::Engine => '/mail'"
      end

      def copy_initializer
        template "mastiff.rb", "config/initializers/mastiff.rb"
      end


      def copy_workers
        # In future check param for other async processing integrations
        if true
          unless File.exist?('config/sidekiq.yml')
            template "sidekiq/sidekiq.yml", "config/sidekiq.yml"
          else
            append_file 'config/sidekiq.yml' do
              ':concurrency: 50'
              ':queues:'
              '  - default'
              '  - email_queue'
            end

          end
          empty_directory "app/workers"
          template "sidekiq/sync_mail_worker.rb",           "app/workers/sync_mail_worker.rb"
          template "sidekiq/sync_attachment_worker.rb",     "app/workers/sync_attachment_worker.rb"
          template "sidekiq/process_attachment_worker.rb",  "app/workers/process_attachment_worker.rb"
        end
      end
      def copy_uploaders
        empty_directory "app/uploaders"
        # In future check param for other file upload/storage integration
        if true
          template "carrierwave/mail_attachment_uploader.rb", "app/uploaders/mail_attachment_uploader.rb"
        end
      end

      #def show_readme
      #  readme "README" if behavior == :invoke
      #end
    end
end
