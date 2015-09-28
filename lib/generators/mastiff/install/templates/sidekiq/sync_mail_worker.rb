require 'sidekiq-lock'

class SyncMailWorker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker
  sidekiq_options :queue => :email_queue, :retry => false, :backtrace => true
  sidekiq_options lock: { timeout: 120000, name: 'lock-mail-worker' }


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
Sidekiq::Cron::Job.create(name: 'SyncMailWorker', cron: '*/10 * * * *', klass: 'SyncMailWorker')
