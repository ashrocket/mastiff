require 'mail'
require 'mastiff/message'
module Mastiff
  module Email

  #
  # You can configure Mastiff::Email with a configure block in an initializer.
  #
  # For example, the following configure the email server info and basic rules settings.
  # using the Figaro gem to grab sensitive values from ENV.
  # place these values in ~/.bashrc or equivalent shell init file
  #
  #
  #  export MAILDO_MAILHOST='mail.somehost.com'
  #  export MAILDO_PORT=993
  #  export MAILDO_EMAIL_ADDRESS='accountname@somehost.com'
  #  export MAILDO_PASSWORD='changeme'

  #
  # RAILS.root/config/initializers/mastiff.rb
  #  Mastiff::Email.configure do |config|
  #   config.settings =  { address:        ENV["MAILDO_MAILHOST"],
  #                        port:           ENV["MAILDO_PORT"],
  #                        user_name:      ENV["MAILDO_EMAIL_ADDRESS"],
  #                        password:       ENV["MAILDO_PASSWORD"],
  #                        authentication: nil,
  #                        enable_ssl:     true }
  #  end
  #
  #

  extend self


    mattr_accessor :imap_connection
    @@imap_connection = nil

    # { :address              => "localhost",
    #  :port                 => 143,
    #  :user_name            => nil,
    #  :password             => nil,
    #  :authentication       => nil,
    #  :enable_ssl           => false }.merge!(values)

    def settings= settings_hash
      Mail.defaults do
        retriever_method :imap, settings_hash
      end
    end
    def settings
      Mail.retriever_method.settings
    end

    def configure(&block)
      yield self
    end

    # Receive all emails from the default retriever
    # See Mail::Retriever for a complete documentation.
    def all(*args, &block)
      Mail.all(*args, &block)
    end

    def uid_validity
      Message.validity
    end
    def u_ids
      prefix = uid_validity
      Message.emails.keys.select{|k| /#{prefix}:/ =~ k }
    end

    def headers(ids = [])
      ids = u_ids() if ids.blank?
      if ids.blank?
        []
      else
        Message.emails.bulk_values(*ids).map{|msg| msg.header}
      end
    end
    def messages(ids = [])
      ids = u_ids() if ids.blank?
      if ids.blank?
        []
      else
        Message.emails.bulk_values(*ids)
      end
    end
    def raw_messages(ids = [])
      ids = u_ids() if ids.blank?
      if ids.blank?
        []
      else
        Message.raw.bulk_values(*ids).map{|msg| Mail.new(msg)}
      end
    end

    #
    # Modification Methods
    #
    def process_inbox
      no_attachments = headers.select{|m| m[:attachment_name].blank?}.map{|m| m[:id]}
      remove(no_attachments)

      grouped = headers.group_by{|m| m[:subject]}
      keep_ids    = []
      grouped.each do |k,l|
       l.sort_by!{|m| m[:date]}.reverse!
       keep_ids << l.shift[:id]
      end
      archive_ids = grouped.map{|k,l| l.map{|m| m[:id]}}.flatten
      archive(archive_ids)

      handle_mail(keep_ids)

    end
    def handle_mail(ids = [])
      unless ids.blank?
        ids.each do |id|
          msg = Message.get(id)
          msg.header[:busy] = true
          msg.save
          Mastiff.process_attachment_worker.perform_async(id)
          msg.header[:busy] = false
          msg.save

        end
        uids    = ids.map{|v| (v.split ':').last.to_i}
        original_vid = ids.first.split(':').first.to_i

        return ids
      end

      return []
    end

    def archive(ids = [])
      unless ids.blank?
        uids         = ids.map{|v| (v.split ':').last.to_i}
        original_vid = ids.first.split(':').first.to_i


        Mail.connection do |imap|
          delim = imap.list("","INBOX").first.delim
          path = ["INBOX","unprocessed"].join(delim)
          imap.select('INBOX')
           if not imap.list('', "INBOX#{delim}unprocessed")
             imap.create("INBOX#{delim}unprocessed")
           end
           uids.each do |uid|
             imap.uid_copy(uid, "INBOX#{delim}unprocessed")
             imap.uid_store(uid, "+FLAGS", [:Deleted])
           end
           imap.expunge
        end
        sync_deleted(ids)
        return ids
      end
      return []
    end


    def flush(current_uid_validity = :all)
      current_uid_validity = :all if current_uid_validity.nil?
      Mastiff.attachment_uploader.flush
      stale_msgs_ids = Message.emails.keys.select {|k| /#{current_uid_validity}:/ !~ k}
      stale_msgs_ids.each {|id| Message.emails.delete id}
      stale_msgs_ids.each {|id| Message.raw.delete id}
    end
   def remove(ids = [])
     unless ids.blank?
       uids         = ids.map{|v| (v.split ':').last.to_i}
       original_vid = ids.first.split(':').first.to_i
       Mail.find_and_delete(keys: "UID #{uids.join ','}")
       sync_deleted(ids)
       return ids
     end
     return []
   end

    def sync_deleted(ids = [])
      unless ids.blank?
        ids.each do |id|
          message = Message.get(id)
          if message.respond_to?('attachment_name') and not message.attachment_name.blank?
            Mastiff::attachment_uploader.delete(message.attachment_name)
          end
          Message.emails.delete id
          Message.raw.delete id
        end
      end
    end
    #def sync_new(ids = [])
    #  unless ids.blank?
    #      fetchdata = imap.uid_fetch(ids, ['RFC822'])
    #      fetchdata.each do |rec|
    #        message = Mail.new(rec.attr['RFC822'])
    #        validity_id = imap.responses["UIDVALIDITY"].last if imap.responses["UIDVALIDITY"]
    #        msg         = Message.new(uid: rec['UID'], validity_id: validity_id, mail_message: message)
    #        msg.save
    #    end
    #  end
    #end

    def sync_messages
      Mail.connection do |imap|
        imap.select 'INBOX'
        validity_id = imap.responses["UIDVALIDITY"].last if imap.responses["UIDVALIDITY"]
        if Message.validity.eql? validity_id
          uids        = imap.uid_search(["NOT", "DELETED"]).sort
          local_uids  = Message.ids
          if  uids != local_uids
            puts "*** Syncing Some ***"
            new_ids     = uids       - local_uids
            deleted_ids = local_uids - uids
            unless new_ids.blank?
              fetchdata = imap.uid_fetch(new_ids, ['RFC822'])
              fetchdata.each do |rec|
                  message = Mail.new(rec.attr['RFC822'])
                  validity_id = imap.responses["UIDVALIDITY"].last if imap.responses["UIDVALIDITY"]
                  msg         = Message.new(uid: rec.attr['UID'], validity_id: validity_id, mail_message: message)
                  msg.save
              end
            end
            self.sync_deleted(deleted_ids.map{|id| [validity_id,id].join ':'}) unless deleted_ids.blank?
          end
        else
          self.sync_all
        end
        Message.ids
      end
    end

    def sync_all(options={}, &block)
      self.flush
      Mail.all({keys:["NOT", "DELETED"]}.merge(options)) do |message, imap, uid|
        validity_id = imap.responses["UIDVALIDITY"].last if imap.responses["UIDVALIDITY"]
        msg         = Message.new(uid: uid, validity_id: validity_id, mail_message: message)
        msg.save

        if Message.validity != msg.validity_id
          flush(msg.validity_id)
          Message.uid_validity.value = msg.validity_id
        end

        if block_given?
          if block.arity == 3
            yield msg, imap, uid
          else
            yield msg
          end
        end
      end
    end


  end
end