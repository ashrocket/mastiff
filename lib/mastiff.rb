require 'active_support/core_ext'
require 'active_support/dependencies'
require 'mastiff/message'
require 'mastiff/email'
require 'mastiff/null_worker'
require 'mastiff/null_uploader'

module Mastiff
  require "mastiff/engine" if defined?(Rails)

  # Our host application root path
  # We set this when the engine is initialized
  mattr_accessor :app_root
  mattr_accessor :message_settings
  @@message_settings = {}

  mattr_accessor :redis_options
  @@redis_options = {host:  '127.0.0.1', port: 6379}

  #The default worker does nothing
  mattr_accessor :process_attachment_worker
  @@process_attachment_worker = NullWorker.new

  #The default worker removes attachments and stores them in local file store
  mattr_accessor :message_attachment_worker
  @@message_attachment_worker = NullWorker

  mattr_accessor :attachment_uploader
  @@attachment_uploader = NullUploader

  # Yield self on setup for nice config blocks
  def self.configure(&block)
    yield self
  end




end




