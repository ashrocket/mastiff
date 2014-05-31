module Helpers
  def local_attachment_files
    path = Mastiff::Email::Uploader.new.store_dir
    Dir.glob(File.join( path,'*')).map{|f| File.basename(f)}
  end
end