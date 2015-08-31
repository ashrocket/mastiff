# encoding: utf-8
require 'spec_helper'
require 'support/mock_imap'
require 'mail'

describe Mastiff::Email do

  it {is_expected.to be_a_kind_of Module}

  context "is initialized " do
    subject(:settings){ Mastiff::Email.settings}
    it "address is initialized"    do expect(settings[:address]).not_to be nil end
    it "enable_ssl is initialized" do expect(settings[:enable_ssl]).not_to be nil end
  end

  context "is initialized with specific settings " do
    before do
       Mastiff::Email.configure do |config|
         config.settings =  { :address              => "some.host",
               :port                 => 143,
               :user_name            => 'testuser@localhost',
               :password             => 'changeme',
               :authentication       => nil,
               :enable_ssl           => true }
       end
    end
    subject(:settings){ Mastiff::Email.settings}
    it "address is initialized"    do expect(settings[:address]).to eq 'some.host' end
    it "enable_ssl is initialized" do expect(settings[:enable_ssl]).to eq true end

  end

  # mail = Mail.read(fixture('emails', 'rfc2822', 'example03.eml'))
  #   expect(mail.from).to eq ['john.q.public@example.com']
  #   expect(mail.to).to eq ['mary@x.test', 'jdoe@example.org', 'one@y.test']
  #   expect(mail.cc).to eq ['boss@nil.test', "sysservices@example.net"]
  #   expect(mail.message_id).to eq '5678.21-Nov-1997@example.com'
  #   expect(mail.date).to eq ::DateTime.parse('1 Jul 2003 10:52:37 +0200')
  # end
  #
  # # From RFC 2822:
  # # A.1.3. Group addresses
  # # In this message, the "To:" field has a single group recipient named A
  # # Group which contains 3 addresses, and a "Cc:" field with an empty
  # # group recipient named Undisclosed recipients.
  # it "should handle group address email test" do
  #   mail = Mail.read(fixture('emails', 'rfc2822', 'example04.eml'))
  #   expect(mail.from).to eq ['pete@silly.example']
  #   expect(mail.to).to eq ['c@a.test', 'joe@where.test', 'jdoe@one.test']
  #   expect(mail[:cc].group_names).to eq ['Undisclosed recipients']
  #   expect(mail.message_id).to eq 'testabcd.1234@silly.example'
  #   expect(mail.date).to eq ::DateTime.parse('Thu, 13 Feb 1969 23:32:54 -0330')
  # end



  context "when mailbox contains text only messages " do
      describe "local cache of emails" do
        before(:each) do
          MockIMAP.seed(:text_mails)
          Mastiff::Email.sync_all
        end
        let(:cached_raw_messages){ Mastiff::Email.raw_messages(Mastiff::Email.u_ids) }
        # it { expect(cached_raw_messages).not_to be_empty }
        # it { expect(cached_raw_messages).to each be_a_kind_of(Mail::Message) }
        it { expect(cached_raw_messages).to match_array(MockIMAP.examples.map{|m| m.attr['RFC822']}) }


        let(:cached_messages){ Mastiff::Email.messages(Mastiff::Email.u_ids) }
        it { expect(cached_messages).to each be_a_kind_of(Mastiff::Email::Message) }
      end

  end


  context "when mailbox contains only attachment messages" do
      before(:all) do
        expect(MockIMAP).to be_disconnected
        MockIMAP.seed(:attachment_mails)
        Mastiff::Email.flush
      end
      describe "local cache of emails" do
        before do
            Mastiff::Email.sync_all
        end

        let(:cached_raw_messages){ Mastiff::Email.raw_messages(Mastiff::Email.u_ids) }
        it { expect(cached_raw_messages).not_to be_empty }
        it { expect(cached_raw_messages).to each be_a_kind_of(Mail::Message) }
        it { expect(cached_raw_messages).to match_array(MockIMAP.examples.map{|m| m.attr['RFC822']}) }

        let(:cached_messages){ Mastiff::Email.messages(Mastiff::Email.u_ids) }
        it { expect(cached_messages).to each be_a_kind_of(Mastiff::Email::Message) }

        let(:filenames){ Mastiff::Email.messages(Mastiff::Email.u_ids).map{|msg| msg.attachment_name} }
        it { expect(filenames).to match_array(["test_1.zip", "test_2.zip","test_3.zip"])}
        #subject(:attachment){  }
      end
  end



end
