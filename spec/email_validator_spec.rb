require 'spec_helper'

describe EmailValidator do
  person_class = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :email => true
  end

  person_class_mx = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :email => {:mx => true}
  end

  person_class_mx_separated = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :mx => true
  end


  shared_examples_for "Invalid model" do
    before { subject.valid? }

    it { should_not be_valid }
    specify { subject.errors[:email].should =~ errors }
  end

  shared_examples_for "Validating emails" do

    before :each do
      I18n.locale = locale
    end

    describe "validating email" do
      subject { person_class.new }

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
      subject { person_class_mx.new }

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

    describe "validating MX" do
      subject { person_class_mx_separated.new }

      context "when domain is not specified" do
        before { subject.email = 'john' }
        it_should_behave_like "Invalid model"
      end

      context "when domain is not specified but @ is" do
        before { subject.email = 'john@' }
        it_should_behave_like "Invalid model"
      end
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
end
