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


