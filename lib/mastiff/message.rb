require 'redis-objects'
require 'mail'


module Mastiff
  module Email
    class Message
      attr_accessor :attachment_name, :stored_filename, :attachment_size, :uid, :validity_id, :header, :raw_message,  :mailbox, :busy, :uploader
      attr_accessor :has_attachments, :attachment_analyzed

      include Redis::Objects
      #
      # TODO: add key processing method so that we can keep emails from multiple mailboxes
      #
      hash_key   :processing, global: true, marshal: true
      hash_key   :emails, global: true, marshal: true
      hash_key   :raw, global: true
      list       :pending_attachments, global: true
      value      :uid_validity, global: true


      def self.validity
        self.uid_validity.value.to_i
      end

      def self.ids
        prefix = validity
        self.emails.keys.select{|k| /#{prefix}:/ =~ k }.map{|id| id.split(':').last.to_i}.sort
      end
      def self.get(id)
        self.emails[id]
      end
      def busy?
        self.header[:busy]
      end
      def lock_and_save
        lock and save
      end
      def unlock_and_save
        unlock and save
      end
      def lock
        @header[:busy] = true
      end
      def unlock
        @header[:busy] = false
      end
      def <=> other
         self.id <=> other.id
      end

      def id
       "#{self.validity_id}:#{self.uid}"
      end

      def raw_source
        if @raw_message.blank?
          self.class.raw[id]
        else
          @raw_message
        end
      end
      def as_mail
        Mail.new raw_source
      end
      def sync_message_attachments
        mail_message = as_mail

        if mail_message and mail_message.has_attachments? and not @attachment_analyzed
                  attachment = mail_message.attachments[0]
                  decoded           = attachment.body.decoded
                  @attachment_name  = attachment.filename
                  @attachment_size  = decoded.length
                  @header[:attachment_size] = @attachment_size
                  @stored_filename = @attachment_name.squish.gsub(" ", "_")
                  @uploader.store_mime(@stored_filename,decoded)
                  @attachment_analyzed = true
                  self.class.pending_attachments.delete(id)
                  unlock
                  save
                  Mastiff.process_attachment_worker.perform_async(id)

        end
      end

      def attached_file_path
        File.join @uploader.store_dir, @stored_filename
      end
      def initialize(attrs = {})
        attrs.deep_symbolize_keys!
        @uid           = attrs[:uid]
        @validity_id   = attrs[:validity_id]
        @raw_message   = attrs[:raw_message]
        # @mail_message  = attrs[:mail_message]
        mail_message = as_mail
        if mail_message and mail_message.has_attachments?
          @has_attachments = true
          attachment = mail_message.attachments[0]
          @attachment_name  = attachment.filename
          @attachment_size  = 0
          @stored_filename = @attachment_name.squish.gsub(" ", "_")
          @uploader  = Mastiff.attachment_uploader.new

          self.class.pending_attachments << id
          @attachment_analyzed = false
          #decoded           = attachment.body.decoded
          #@attachment_size  = decoded.length
        end
        if attrs[:header].is_a? Hash
          @header = attrs[:header]
        end
        if  mail_message and @header.blank?
          @header  = {
            id: id,
            busy: false,
            from: mail_message[:from].display_names.first,
            sender_email: mail_message.from.first,
            subject: mail_message.subject,
            date: mail_message.date,
            attachment_name: @attachment_name,
            attachment_size: @attachment_size,
            stored_filename: @stored_filename,
          }
        elsif mail_message and not @header.blank?
          # TODO: Change this to a use a gem logger
          puts "Header already existed"
        end
      end



      def save
        mail_message = as_mail

        unless mail_message.blank?
          lock if @has_attachments and not @attachment_analyzed
          self.class.raw[id]    = self.raw_message
        end

        self.class.emails[id] = self
        Mastiff.sync_attachment_worker.perform_async(id) if @has_attachments and not @attachment_analyzed

      end


    end
  end
end


