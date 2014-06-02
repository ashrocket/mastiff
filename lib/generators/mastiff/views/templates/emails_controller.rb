class EmailsController < ApplicationController
  before_action :set_admin_mastiff_email, only: [:show, :edit, :update, :destroy]

  # GET /admin/mastiff_emails
  # GET /admin/mastiff_emails.json
  def index
    respond_to do |format|
       format.html{}
    end
  end
  def list
    @emails = Mastiff::Email.headers
    @emails.each{|m| m["DT_RowId"] = m[:id]}
    puts @emails.map{|m| "#{m[:id]}, #{m[:attachment_size]}"}
    render :json => {aaData: @emails}
    #    render :json => {aaData: @emails.map{|email| [
    #    email[:id],
    #    email[:date], email[:subject], email[:sender_email],
    #    email[:attachment_name], email[:attachment_size].to_s
    #]}}
  end
  def message_ids
    respond_to do |format|
        format.json{
          @msg_ids = Mastiff::Email.msg_ids
          render :json => @msg_ids
        }
    end
  end


  #
  # Modifying Actions
  #

  # GETS masquerading as POSTS
  def reload
    message_ids = Mastiff::Email.sync_messages
    respond_to do |format|
       format.json{
         render :json => message_ids
       }
    end
  end
  def reset
    message_ids = Mastiff::Email.sync_all
    respond_to do |format|
       format.json{
         render :json => message_ids
       }
    end
  end
  def process_inbox
    message_ids = Mastiff::Email.process_inbox
    respond_to do |format|
       format.json{
         render :json => message_ids
       }
    end
  end


  def remove
    #TODO: figure out how to get DataTables to send a JSON array
    tableData = params["tableData"]
    tableData_a = tableData.split ","
    ids = Mastiff::Email.remove(tableData_a)
    respond_to do |format|
       format.json{
         render :json => ids
       }
    end
  end

  #POST /admin/mastiff_email/archive
  def archive
    #TODO: figure out how to get DataTables to send a JSON array
    tableData = params["tableData"]
    tableData_a = tableData.split ","
    ids = Mastiff::Email.archive(tableData_a)

    respond_to do |format|
       format.json{
         render :json => ids
       }
    end
  end

  ## POST /admin/mastiff_email/archive
  def handle_mail
    #TODO: figure out how to get DataTables to send a JSON array
    tableData = params["tableData"]
    tableData_a = tableData.split ","
    ids = Mastiff::Email.handle_mail(tableData_a)

    respond_to do |format|
       format.json{
         render :json => ids
       }
    end
  end
end
