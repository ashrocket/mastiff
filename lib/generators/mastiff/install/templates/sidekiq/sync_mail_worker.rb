require 'sidekiq-lock'

class SyncMailWorker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker
  include Sidetiq::Schedulable
  sidekiq_options :queue => :email_queue, :retry => false, :backtrace => true
  sidekiq_options lock: { timeout: 120000, name: 'lock-mail-worker' }

  recurrence { minutely }

  def perform
      if lock.acquire!
        begin
          Mastiff::Email.sync_messages
        ensure
          lock.release!
        end
      end
  end

end