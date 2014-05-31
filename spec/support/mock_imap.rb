
class MockIMAPFetchData
  attr_reader :attr, :number

  def initialize(rfc822, number)
    @attr = { 'RFC822' => rfc822 }
    @number = number
  end

end

class MockIMAP
  @@connection = false
  @@mailbox = nil
  @@marked_for_deletion = []
  @@responses = {"FLAGS"=>[[:Answered, :Flagged, :Deleted, :Seen, :Draft, "nonjunk", "$Forwarded"]],
      "OK"=>[],"PERMANENTFLAGS"=>[[:Answered, :Flagged, :Deleted, :Seen, :Draft, "nonjunk", "$Forwarded", :*]],
      "EXISTS"=>[9], "RECENT"=>[0], "UIDVALIDITY"=>[123456789], "UIDNEXT"=>[3], "HIGHESTMODSEQ"=>["999"]}

  def self.examples
    @@examples
  end

  def self.seed(seed_with, max = nil)
    @@examples = []
    puts "Seeded with #{seed_with}"
    if seed_with.eql? :text_mails
      max = 9 unless max
      #Email 13 & 14 are intentionally bad
      (1..max).each do |i|
        mail = Mail.read(fixture(File.join('emails', "example#{i.to_s.rjust(2, '0')}.eml")))
        @@examples << MockIMAPFetchData.new(mail, i-1)
      end
      @@responses["UIDNEXT"] = max
    elsif seed_with.eql? :attachment_mails
      max = 3 unless max
      (1..max).each do |i|
       mail = Mail.read(fixture(File.join('emails', 'attachment_emails', "attachment_zip_email_#{i}.eml")))
       @@examples << MockIMAPFetchData.new(mail, i-1)
      end
      @@responses["UIDNEXT"] = max
    end
  end

  def initialize
    puts "Initializing a new instance of mock IMAP"
  end


  def responses
   @@responses
  end
  def login(user, password)
    @@connection = true
  end

  def disconnect
    @@connection = false
  end

  def select(mailbox)
    @@mailbox = mailbox
  end

  def examine(mailbox)
    select(mailbox)
  end

  def uid_search(keys, charset=nil)
    [*(0..@@examples.size - 1)]
  end

  def uid_fetch(set, attr)
    [@@examples[set]]
  end

  def uid_store(set, attr, flags)
    if attr == "+FLAGS" && flags.include?(Net::IMAP::DELETED)
      @@marked_for_deletion << set
    end
  end

  def expunge
    @@marked_for_deletion.reverse.each do |i|    # start with highest index first
      @@examples.delete_at(i)
    end
    @@marked_for_deletion = []
  end

  def self.mailbox; @@mailbox end    # test only

  def self.disconnected?; @@connection == false end
  def      disconnected?; @@connection == false end


end
require 'net/imap'
class Net::IMAP
  def self.new(*args)
    MockIMAP.new
  end
end