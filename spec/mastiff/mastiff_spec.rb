# encoding: utf-8
require 'spec_helper'

describe "mastiff" do

  it "should be able to be instantiated" do
    doing { Mastiff }.should_not raise_error
  end

  #it "should be able to make a new email" do
  #  Mail.new.class.should eq Mail::Message
  #end



end
