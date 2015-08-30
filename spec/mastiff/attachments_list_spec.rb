# encoding: utf-8
require 'spec_helper'

describe "reading emails with attachments" do
  describe "test emails" do


    it "should use the content-type filename or name over the content-disposition filename for attachment" do
      mail = Mail.read(fixture(File.join('emails', 'attachment_emails', '20140530-MastiffArt-1177.eml')))
      expect(mail.attachments[0].filename).to eq 'MastiffArt32.jpg'
    end
    it "should find an attachment defined with 'name' and Content-Disposition: attachment" do
      mail = Mail.read(fixture(File.join('emails', 'attachment_emails', '20140530-MastiffHistoryWarDogs-1176.eml')))
      expect(mail.attachments.length).to eq 1
    end

    it "should decode an csv attachment" do
        mail = Mail.read(fixture(File.join('emails', 'attachment_emails', '20140530-MailCarrierStatsCSVFile-1180.eml')))
        expect(mail.attachments[0].decoded.length).to eq 41160509
    end
    it "should decode an xlsx attachment" do
        mail = Mail.read(fixture(File.join('emails', 'attachment_emails', '20140530-MailCarrierStatsExcelSheet-1179.eml')))
        expect(mail.attachments[0].decoded.length).to eq 33264373
    end
    it "should decode an zip attachment" do
        mail = Mail.read(fixture(File.join('emails', 'attachment_emails', '20140530-MailCarrierStatsReportZip-1178.eml')))
        expect(mail.attachments[0].decoded.length).to eq 24960287
    end
    it "should find the attachment using content location" do
      mail = Mail.read(fixture(File.join('emails', 'attachment_emails', 'attachment_content_location.eml')))
      expect(mail.attachments.length).to eq 1
    end

    it "should find an attachment defined with 'name' and Content-Disposition: attachment" do
      mail = Mail.read(fixture(File.join('emails', 'attachment_emails', 'attachment_content_disposition.eml')))
      expect(mail.attachments.length).to eq 1
    end

    it "should use the content-type filename or name over the content-disposition filename" do
      mail = Mail.read(fixture(File.join('emails', 'attachment_emails', 'attachment_content_disposition.eml')))
      expect(mail.attachments[0].filename).to eq 'hello.rb'
    end


    it "should decode an attachment" do
      mail = Mail.read(fixture(File.join('emails', 'attachment_emails', 'attachment_pdf.eml')))
      expect(mail.attachments[0].decoded.length).to eq 1026
    end




    it "should find an attachment that has an encoded name value" do
      mail = Mail.read(fixture(File.join('emails', 'attachment_emails', 'attachment_with_encoded_name.eml')))
      expect(mail.attachments.length).to eq 1
      result = mail.attachments[0].filename
      if RUBY_VERSION >= '1.9'
        expected = "01 Quien Te Dij\212at. Pitbull.mp3".force_encoding(result.encoding)
      else
        expected = "01 Quien Te Dij\212at. Pitbull.mp3"
      end
      expect(result).to eq expected
    end

    it "should find an attachment that has a name not surrounded by quotes" do
      mail = Mail.read(fixture(File.join('emails', 'attachment_emails', "attachment_with_unquoted_name.eml")))
      expect(mail.attachments.length).to eq 1
      expect(mail.attachments.first.filename).to eq "This is a test.txt"
    end

    it "should find attachments inside parts with content-type message/rfc822" do
      mail = Mail.read(fixture(File.join("emails",
                                         "attachment_emails",
                                         "attachment_message_rfc822.eml")))
      expect(mail.attachments.length).to eq 1
      expect(mail.attachments[0].decoded.length).to eq 1026
    end

    it "attach filename decoding (issue 83)" do
      data = <<-limitMAIL
Subject: aaa
From: aaa@aaa.com
To: bbb@aaa.com
Content-Type: multipart/mixed; boundary=0016e64c0af257c3a7048b69e1ac

--0016e64c0af257c3a7048b69e1ac
Content-Type: multipart/alternative; boundary=0016e64c0af257c3a1048b69e1aa

--0016e64c0af257c3a1048b69e1aa
Content-Type: text/plain; charset=ISO-8859-1

aaa

--0016e64c0af257c3a1048b69e1aa
Content-Type: text/html; charset=ISO-8859-1

aaa<br>

--0016e64c0af257c3a1048b69e1aa--
--0016e64c0af257c3a7048b69e1ac
Content-Type: text/plain; charset=US-ASCII; name="=?utf-8?b?Rm90bzAwMDkuanBn?="
Content-Disposition: attachment; filename="=?utf-8?b?Rm90bzAwMDkuanBn?="
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gbneqxxy0

YWFhCg==
--0016e64c0af257c3a7048b69e1ac--
limitMAIL
      mail = Mail.new(data)
      #~ puts Mail::Encodings.decode_encode(mail.attachments[0].filename, :decode)
      expect(mail.attachments[0].filename).to eq "Foto0009.jpg"
    end

  end



end


