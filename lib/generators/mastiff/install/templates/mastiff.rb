require 'redis'

AirOag.configure do |config|

  AirOag::Email.configure do |email_config|

    # IMAP server account settings
    email_config.settings =  {  address:        ENV["MAILDO_MAILHOST"],
                                port:           ENV["MAILDO_PORT"],
                                user_name:      ENV["MAILDO_EMAIL_ADDRESS"],
                                password:       ENV["MAILDO_PASSWORD"],
                                authentication: nil,
                                enable_ssl:     true }


  end

  # Redis Objects Option configuration
  AirOag::Email::Message.redis = Redis.new(config.redis_options)

  # https://gist.github.com/jnunemaker/230531
  # Allows accessing config variables from oag_mail_config.yml like so:
  #   OAGConfig[:server] => imap.gmail.com
  if File.exists? File.join(Rails.root, 'config', 'air_oag.yml')
    raw_config = File.read(File.join(Rails.root, 'config', 'air_oag.yml'))
    config.message_settings = YAML.load(raw_config)[Rails.env].symbolize_keys
  end

  # Background Workers are called using class methods, not object methods,
  # so we need to initialize based on the class, not an instance

  # Worker to decode and store attachments
  config.message_attachment_worker  = SyncAttachmentWorker

  # Worker to process attachments and perform an action
  config.process_attachment_worker  = ProcessAttachmentWorker

  # Class to store attachment
  config.attachment_uploader        =  MailAttachmentUploader


  ul = config.attachment_uploader.new
  File.directory?(ul.store_dir) or
  raise "Gem requires local storage path for mail attachments - #{ul.store_dir} does not exist!"
end

