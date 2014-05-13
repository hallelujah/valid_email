require 'spec_helper'

describe "validating email with MX" do
  subject { mx.new }

  def errors
    ['belongs to no valid domain']
  end

  it "should pass when email domain has MX record" do
    subject.email = 'john@gmail.com'
    subject.valid?.should be_true
    subject.errors[:email].should be_empty
  end

  it "should fail when email domain has no MX record" do
    subject.email = 'john@subdomain.rubyonrails.org'
    subject.valid?.should be_false
    subject.errors[:email].should == errors
  end

  it "should fail when domain does not exists" do
    subject.email = 'john@nonexistentdomain.abc'
    subject.valid?.should be_false
    subject.errors[:email].should == errors
  end

  describe 'about translation' do
    before { subject.email = 'john@domain.does.not.exists' }
    it_behaves_like "Translated errors", 'mx', 'translated string'
    it_behaves_like "Translated errors", 'mx', 'chaîne de caractères traduite', lang: :fr
  end
end
