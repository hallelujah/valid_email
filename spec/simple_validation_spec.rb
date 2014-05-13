require 'spec_helper'

describe 'validating email with Mail::Address' do

  subject { simple.new }

  def errors
    [ "is invalid" ]
  end

  it "should fail when email empty" do
    subject.valid?.should be_false
    subject.errors[:email].should == errors
  end

  it "should fail when email is not valid" do
    subject.email = 'joh@doe'
    subject.valid?.should be_false
    subject.errors[:email].should == errors
  end

  it "should fail when email is valid with information" do
    subject.email = '"John Doe" <john@doe.com>'
    subject.valid?.should be_false
    subject.errors[:email].should == errors
  end

  it "should pass when email is simple email address" do
    subject.email = 'john@doe.com'
    subject.valid?.should be_true
    subject.errors[:email].should be_empty
  end

  it "should fail when email is simple email address not stripped" do
    subject.email = 'john@doe.com            '
    subject.valid?.should be_false
    subject.errors[:email].should == errors
  end

  it "should fail when passing multiple simple email addresses" do
    subject.email = 'john@doe.com, maria@doe.com'
    subject.valid?.should be_false
    subject.errors[:email].should == errors
  end

end
