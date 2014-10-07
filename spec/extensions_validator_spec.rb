require 'spec_helper'
require 'valid_email/all_with_extensions'

describe String do

  it { "mymail@gmail".should respond_to(:email?) }

  it "is a valid e-mail" do
    "mymail@gmail.com".email?.should be_truthy
  end

  it "is not valid when text is not a real e-mail" do
    "invalidMail".email?.should be_falsey
  end

  context "when nil" do

    it "is invalid e-mail" do
      nil.email?.should be_falsey
    end

  end

end
