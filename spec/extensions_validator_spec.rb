require 'spec_helper'
require 'valid_email/all_with_extensions'

describe String do

  it { expect("mymail@gmail").to respond_to(:email?) }

  it "is a valid e-mail" do
    expect("mymail@gmail.com".email?).to be_truthy
  end

  it "is not valid when text is not a real e-mail" do
    expect("invalidMail".email?).to be_falsey
  end

  context "when nil" do

    it "is invalid e-mail" do
      expect(nil.email?).to be_falsey
    end

  end

end
