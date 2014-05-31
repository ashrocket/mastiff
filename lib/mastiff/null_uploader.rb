# null_uploader.rb
module Mastiff
  class NullUploader
    def self.delete(filename)
       return if filename.blank?
       filepath = File.join(new.store_dir, filename)
       File.delete(filepath) if File.exists?(filepath)
    end
    def self.flush
      puts 'Doing nothing'
      return nil
    end
    def store_dir
      return '/tmp'
    end
    def store_mime(fname, blob)
      return nil
    end
  end
end