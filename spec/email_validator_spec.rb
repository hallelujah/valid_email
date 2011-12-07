require 'spec_helper'

describe EmailValidator do
  person_class = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :email => true
  end



  describe "validating email" do
    subject { person_class.new }

    it "should fail when email empty" do
      subject.valid?.should be_false
      subject.errors[:email].should == [ "is invalid" ]
    end

    it "should fail when email is not valid" do
      subject.email = 'joh@doe'
      subject.valid?.should be_false
      subject.errors[:email].should == [ "is invalid" ]
    end

    it "should fail when email is valid with information" do
      subject.email = '"John Doe" <john@doe.com>'
      subject.valid?.should be_false
      subject.errors[:email].should == [ "is invalid" ]
    end

    it "should pass when email is simple email address" do
      subject.email = 'john@doe.com'
      subject.valid?.should be_true
      subject.errors[:email].should be_empty
    end

    it "should fail when email is simple email address not stripped" do
      subject.email = 'john@doe.com            '
      subject.valid?.should be_false
      subject.errors[:email].should == [ "is invalid" ]
    end


    it "should fail when passing multiple simple email addresses" do
      subject.email = 'john@doe.com, maria@doe.com'
      subject.valid?.should be_false
      subject.errors[:email].should == [ "is invalid" ]
    end
  end
    
  person_class_mx = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :email => {:mx => true}
  end

  describe "validating email with MX" do
    subject { person_class_mx.new }

    it "should pass when email domain has MX record" do
      subject.email = 'john@gmail.com'
      subject.valid?.should be_true
      subject.errors[:email].should be_empty
    end

    it "should fail when email domain has no MX record" do
      subject.email = 'john@subdomain.rubyonrails.org'
      subject.valid?.should be_false
      subject.errors[:email].should == [ "is invalid" ]
    end

    it "should fail when domain does not exists" do
      subject.email = 'john@nonexistentdomain.abc'
      subject.valid?.should be_false
      subject.errors[:email].should == [ "is invalid" ]
    end

  end
end
