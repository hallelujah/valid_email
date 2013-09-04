require 'spec_helper'

describe EmailValidator do
  class EmailValidatorClass
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :email => true
  end

  class MxRecordValidatorClass
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :email => {:mx => true}
  end

  person_class_nil_allowed = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :email => {:allow_nil => true}
  end

  person_class_blank_allowed = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :email => {:allow_blank => true}
  end

  shared_examples_for "Validating emails" do
    
    before :each do
      I18n.locale = locale
    end

    describe "validating email" do
      subject { EmailValidatorClass.new }

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

    describe "validating email with MX" do
      subject { MxRecordValidatorClass.new }

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
    end
  end
  
  describe "Can allow nil" do
    subject { person_class_nil_allowed.new }

    it "should pass even if mail isn't set" do
      subject.email = nil
      subject.should be_valid
      subject.errors[:email].should be_empty
    end

  end

  describe "Can allow blank" do
    subject { person_class_blank_allowed.new }

    it "should pass even if mail is a blank string set" do
      subject.email = ''
      subject.should be_valid
      subject.errors[:email].should be_empty
    end

  end
  
  describe "Translating in english" do
    let!(:locale){ :en }
    let!(:errors) { [ "is invalid" ] }
    it_should_behave_like "Validating emails"
  end
  
  describe "Translating in french" do
    let!(:locale){ :fr }
    
    let!(:errors) { [ "est invalide" ] }
    it_should_behave_like "Validating emails"
  end

  describe "validating email with a custom message that contains the invalid value" do
    class EmailValidatorClassWithCustomMessage
      include ActiveModel::Validations
      attr_accessor :email
      validates :email, :email => {:message => "\"%{value}\" is not a valid email address"}
    end

    subject { EmailValidatorClassWithCustomMessage.new }

    it "should fail and contain the invalid value in the error message" do
      subject.email = 'joh@doe'
      subject.valid?.should be_false
      subject.errors[:email].should == ["\"#{subject.email}\" is not a valid email address"]
    end
  end

  describe "validating mx record with a custom message that contains the invalid value" do
    class MxRecordValidatorClassWithCustomMessage
      include ActiveModel::Validations
      attr_accessor :email
      validates :email, :email => {:mx => true, :message => "\"%{value}\" does not have a valid MX record"}
    end

    subject { MxRecordValidatorClassWithCustomMessage.new }

    it "should fail and contain the invalid value in the error message" do
      subject.email = 'joh@doe'
      subject.valid?.should be_false
      subject.errors[:email].should == ["\"#{subject.email}\" does not have a valid MX record"]
    end
  end

end
