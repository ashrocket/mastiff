#
# When a generator is invoked, each public method in the generator is executed sequentially in the order that it is defined.
# http://guides.rubyonrails.org/generators.html
#
#require 'rails/generators'
module Mastiff
  #class UploaderGenerator < Rails::Generators::NamedBase

  class ViewsGenerator < Rails::Generators::Base


      desc "Creates a Mastiff view for monitoring email status"

      source_root File.expand_path("../templates", __FILE__)


      def create_routes

      route_text = "resource :mail, :controller => 'emails', only: [:index] do
           get '/', action: :index
           get 'msg_ids',  format: 'json'
           get 'validity',  format: 'json'
           get 'list', format: 'json'

           # These should be POSTs with no data, but get is easier to use
           get 'reload', format: 'json'
           get 'reset', format: 'json'
           get 'process_inbox', format: 'json'

           # These are posts with data
           post 'remove', format: 'json'
           post 'archive', format: 'json'
           post 'handle_mail', format: 'json'
      end"
      #TODO, check for existing routes for mail
      route route_text
      end

      def copy_views
        insert_into_file "app/assets/stylesheets/application.css.scss", :before => "*/" do
           "\n *= require 'emails'\n\n"
        end
        insert_into_file "app/assets/javascripts/application.js", :before => "*/" do
           "\n *= require 'emails'\n\n"
         end
        template "emails.js.coffee", "app/assets/javascripts/emails.js.coffee"
        template "emails.css.scss", "app/assets/stylesheets/emails.css.scss"
        template "emails_controller.rb", "app/controllers/emails_controller.rb"
        directory "emails", "app/views/emails"
      end

    end
end
