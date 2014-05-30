# app/workers/sync_attachment_worker.rb
class SyncAttachmentWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :email_queue, :retry => 1, :backtrace => true

  def perform(message_id)
    msg = Mastiff::Email::Message.get(message_id)
    msg.sync_message_attachments
  end
end
