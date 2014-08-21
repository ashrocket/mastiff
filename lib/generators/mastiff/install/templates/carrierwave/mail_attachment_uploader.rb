require 'carrierwave'
require 'carrierwave/processing/mime_types'
# encoding: utf-8
    class MailAttachmentUploader < CarrierWave::Uploader::Base
      include CarrierWave::MimeTypes

      class MimeIO < StringIO
        attr_accessor :filepath

        def initialize(*args)
          super(*args[1..-1])
          @filepath = args[0]
        end

        def original_filename
          File.basename(@filepath)
        end
      end


      process :set_content_type


      def self.flush
        Dir.glob(File.join(new.store_dir, '*')).each{|f| File.delete(f)}
      end
      def self.delete(filename)
        return if filename.blank?
        filepath = File.join(new.store_dir, filename)
        File.delete(filepath) if File.exists?(filepath)
      end


      # Choose what kind of storage to use for this uploader:
      storage :file
      # storage :fog

      # Override the directory where uploaded files will be stored.
      # This is a sensible default for uploaders that are meant to be mounted:
      def store_dir
        Mastiff.attachment_dir
      end

      def store_mime(fname, mime_blob)
        mime_io = MimeIO.new(fname, mime_blob)
        store!(mime_io)
      end
      

      # Add a white list of extensions which are allowed to be uploaded.
      # For images you might use something like this:
      def extension_white_list
         %w(csv zip)
      end

      # Override the filename of the uploaded files:
      # Avoid using model.id or version_name here, see uploader/store.rb for details.
      def filename
        original_filename.squish.gsub(" ", "_")
      end

end
