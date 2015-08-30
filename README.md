mastiff
=======

Mastiff is a War Dog who fetches mail from IMAP and then hands it off to do something useful

Introduction
------------

Mastiff is a gem  designed to handle imap hosted emails, downloading them to your applications
server, detaching attachments, and storing them locally to be parsed and oeprated upon using a background
queue.  The queue manager supported is sidekiq.  Mails are stored locally in Redis for synhronization and speed.


Compatibility
-------------
Mastiff currently supports use of redis version 2.8.9 - 2.8.16
Mastiff currently supports use of the following sidekiq gem and plug-ins
 * gem "sidekiq", '~> 2.17.7'
 * gem 'sidetiq', '~> 0.5.0'
 * gem 'sidekiq-lock', '0.2.0'

Installation
------------

    rails g 'mastiff:install'

creates the following files

      create  config/initializers/mastiff.rb
      append  config/sidekiq.yml
      create  app/workers
      create  app/workers/sync_mail_worker.rb
      create  app/workers/sync_attachment_worker.rb
      create  app/workers/process_attachment_worker.rb
      create  app/uploaders
      create  app/uploaders/mail_attachment_uploader.rb


Initializers
-------------
 1. Mailbox Folders
 2. Attachment Uploader Class
 3. Attachment storage Directory
 4.  Sync Attachment Worker Class
 5.  Process Attachement Worker Class
 6.  Redis Options
 7.  IMAP Message options
  
####Mailbox Folders
Names of the folders you want to create on your IMAP account.
This is where completed and processed messages get moved to after processing

    # Mailbox Options
    config.mailbox_folders = config.mailbox_folders.merge({processed: 'processed', rejected: 'rejected', processing: 'processing'})

####Attachment Uploader Class
Defaults to CarrierWave based uploader.  You can and should override this by adding an /uploader/mail_attachement_uploader.rb class in your app root, or by editing the file that is generated during install.

####Attachment storage Directory
Defaults to '/tmp'  but can be changed by assigning the variable

    config.attachment_dir      = 'data/attachments/pending'

####Sync Attachment Worker Class
This class is generated for you, but should be modified to add additional book keeping or records you wish to create.

####Process Attachment Worker Class
This class is generated for you, but should be modified to kick-off the steps you wish to have run when an attachment is detected and stored.  Originally designed to kick-off a csv record import.

  



Rspec Tests
-------------

You must run `$rails g mastiff:install` before executing tests, from within the spec/dummy directory.



