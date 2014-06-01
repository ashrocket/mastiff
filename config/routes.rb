Mastiff::Engine.routes.draw do
  resources :emails,  except: [:show, :create, :new, :edit, :update, :destroy] do
            collection do
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
            #post 'process_mail', format: 'json'
            #post 'archive', format: 'json'
            #post 'clean',  format: 'json'
            #post 'headers', format: 'json'
            #post 'attachment_headers', format: 'json'
            #post 'auto_clean', format: 'json'
            #post 'auto_archive', format: 'json'
            end
            #get 'attachment_header', format: 'json'

  end
end
