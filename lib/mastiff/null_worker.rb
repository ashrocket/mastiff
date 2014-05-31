# null_worker.rb
module Mastiff
  class NullWorker
    def perform(null_id)
      puts 'Doing nothing'
    end
    def perform_async(null_id)
      puts 'Doing nothing'
    end
  end
end