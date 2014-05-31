# encoding: utf-8
require 'spec_helper'
require 'mail'

describe Mastiff::Email do

  it {should be_a_kind_of Module}

  context "is initialized " do
    subject(:settings){ Mastiff::Email.settings}
    it "address is initialized"    do settings[:address].should_not be nil end
    it "enable_ssl is initialized" do settings[:enable_ssl].should_not be nil end
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
    it "address is initialized"    do settings[:address].should eq 'some.host' end
    it "enable_ssl is initialized" do settings[:enable_ssl].should eq true end

  end
  context "when mailbox contains text only messages " do
      before(:all) do
        MockIMAP.should be_disconnected
        MockIMAP.seed(:text_mails)
         Mastiff::Email.flush
      end
      describe "local cache of emails" do
        before do
          Mastiff::Email.sync_all
        end
        let(:cached_raw_messages){ Mastiff::Email.raw_messages(Mastiff::Email.u_ids) }
        it { cached_raw_messages.should_not be_empty }
        it { cached_raw_messages.should each be_a_kind_of(Mail::Message) }
        it { cached_raw_messages.should =~ MockIMAP.examples.map{|m| m.attr['RFC822']} }

        let(:cached_messages){ Mastiff::Email.messages(Mastiff::Email.u_ids) }
        it { cached_messages.should each be_a_kind_of(Mastiff::Email::Message) }
      end

  end


  context "when mailbox contains only attachment messages" do
      before(:all) do
        MockIMAP.should be_disconnected
        MockIMAP.seed(:attachment_mails)
        Mastiff::Email.flush
      end
      describe "local cache of emails" do
        before do
            Mastiff::Email.sync_all
        end

        let(:cached_raw_messages){ Mastiff::Email.raw_messages(Mastiff::Email.u_ids) }
        it { cached_raw_messages.should_not be_empty }
        it { cached_raw_messages.should each be_a_kind_of(Mail::Message) }
        it { cached_raw_messages.should =~ MockIMAP.examples.map{|m| m.attr['RFC822']} }

        let(:cached_messages){ Mastiff::Email.messages(Mastiff::Email.u_ids) }
        it { cached_messages.should each be_a_kind_of(Mastiff::Email::Message) }

        let(:filenames){ Mastiff::Email.messages(Mastiff::Email.u_ids).map{|msg| msg.attachment_name} }
        it { filenames.should =~ ["test_1.zip", "test_2.zip","test_3.zip"]}
        #subject(:attachment){  }
      end
  end



end
