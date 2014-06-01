# app/workers/process_attachment_worker.rb
class ProcessAttachmentWorker
  include Sidekiq::Worker

  def perform(message_id)
    msg = Mastiff::Email::Message.get(message_id)

    #Do Something here with the message
    #
  end
end