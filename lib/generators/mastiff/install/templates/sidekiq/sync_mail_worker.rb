require 'sidekiq-lock'

class SyncMailWorker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker
  include Sidetiq::Schedulable
  sidekiq_options :queue => :email_queue, :retry => false, :backtrace => true
  sidekiq_options lock: { timeout: 1000, name: 'lock-worker' }

  recurrence { minutely }

  def perform
    if lock.acquire!
      Mastiff::Email.sync_messages
    end
  end
end