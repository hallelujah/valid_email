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

  person_class_mx_with_fallback = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :email => {:mx_with_fallback => true}
  end

  person_class_disposable_email = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :email => {:ban_disposable_email => true}
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

  person_class_mx_separated = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :mx => true
  end

  person_class_mx_with_fallback_separated = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :mx_with_fallback => true
  end

  person_class_domain = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :email => { :domain => true }
  end

  person_class_domain_separated = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :domain => true
  end

  person_message_specified = Class.new do
    include ActiveModel::Validations
    attr_accessor :email
    validates :email, :email => { :message => 'custom message', :ban_disposable_email => true }
  end

  shared_examples_for "Invalid model" do
    before { subject.valid? }

    it { is_expected.not_to be_valid }
    specify { expect(subject.errors[:email]).to match_array errors }
  end

  shared_examples_for "Validating emails" do

    before :each do
      I18n.locale = locale
    end

    describe "validating email" do
      subject { person_class.new }

      it "fails when email empty" do
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end

      it "fails when email is not valid" do
        subject.email = 'joh@doe'
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end

      it "fails when email domain is prefixed with dot" do
        subject.email = 'john@.doe'
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end

      it "fails when email domain contains two consecutive dots" do
        subject.email = 'john@doe-two..com'
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end

      it "fails when email is valid with information" do
        subject.email = '"John Doe" <john@doe.com>'
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end

      it "passes when email is simple email address" do
        subject.email = 'john@doe.com'
        expect(subject.valid?).to be_truthy
        expect(subject.errors[:email]).to be_empty
      end

      it "fails when email is simple email address not stripped" do
        subject.email = 'john@doe.com            '
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end

      it "fails when domain contains a space" do
        subject.email = 'john@doe .com'
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end

      it "fails when passing multiple simple email addresses" do
        subject.email = 'john@doe.com, maria@doe.com'
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end

    end

    describe "validating email with MX and fallback to A" do
      subject { person_class_mx_with_fallback.new }

      it "passes when email domain has MX record" do
        subject.email = 'john@gmail.com'
        expect(subject.valid?).to be_truthy
        expect(subject.errors[:email]).to be_empty
      end

      it "passes when email domain has no MX record but has an A record" do
        subject.email = 'john@subdomain.rubyonrails.org'
        expect(subject.valid?).to be_truthy
        expect(subject.errors[:email]).to be_empty
      end

      it "fails when domain does not exists" do
        subject.email = 'john@nonexistentdomain.abc'
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end
    end

    describe "validating email with MX" do
      subject { person_class_mx.new }

      it "passes when email domain has MX record" do
        subject.email = 'john@gmail.com'
        expect(subject.valid?).to be_truthy
        expect(subject.errors[:email]).to be_empty
      end

      it "fails when email domain has no MX record" do
        subject.email = 'john@subdomain.rubyonrails.org'
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end

      it "fails when domain does not exists" do
        subject.email = 'john@nonexistentdomain.abc'
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end
    end

    describe "validating MX with fallback to A" do
      subject { person_class_mx_with_fallback_separated.new }

      context "when domain is not specified" do
        before { subject.email = 'john' }
        it_behaves_like "Invalid model"
      end

      context "when domain is not specified but @ is" do
        before { subject.email = 'john@' }
        it_behaves_like "Invalid model"
      end
    end

    describe "validating MX" do
      subject { person_class_mx_separated.new }

      context "when domain is not specified" do
        before { subject.email = 'john' }
        it_behaves_like "Invalid model"
      end

      context "when domain is not specified but @ is" do
        before { subject.email = 'john@' }
        it_behaves_like "Invalid model"
      end
    end

    describe "validating email from disposable service" do
      subject { person_class_disposable_email.new }

      it "passes when email from trusted email services" do
        subject.email = 'john@mail.ru'
        expect(subject.valid?).to be_truthy
        expect(subject.errors[:email]).to be_empty
      end

      it "fails when email from disposable email services" do
        subject.email = 'john@grr.la'
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end
    end

    describe "validating domain" do
      subject { person_class_domain.new }

      it "does not pass with an invalid domain" do
        subject.email = "test@example.org$\'"
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end

      it "passes with valid domain" do
        subject.email = 'john@example.org'
        expect(subject.valid?).to be_truthy
        expect(subject.errors[:email]).to be_empty
      end
    end

    describe "validating domain separately" do
      subject { person_class_domain_separated.new }

      it "does not pass with an invalid domain" do
        subject.email = "test@example.org$\'"
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:email]).to eq errors
      end

      it "passes with valid domain" do
        subject.email = 'john@example.org'
        expect(subject.valid?).to be_truthy
        expect(subject.errors[:email]).to be_empty
      end

      context 'with a mail that would raise a parsing error' do
        it 'does not raise' do
          subject.email = '@example.org'
          expect(subject.valid?).to be_falsey
          expect { subject.valid? }.not_to raise_error
        end
      end
    end
  end

  describe "Can allow nil" do
    subject { person_class_nil_allowed.new }

    it "passes even if mail isn't set" do
      subject.email = nil
      expect(subject).to be_valid
      expect(subject.errors[:email]).to be_empty
    end
  end

  describe "Can allow blank" do
    subject { person_class_blank_allowed.new }

    it "passes even if mail is a blank string set" do
      subject.email = ''
      expect(subject).to be_valid
      expect(subject.errors[:email]).to be_empty
    end
  end

  describe "Accepts custom messages" do
    subject { person_message_specified.new }

    it "adds only the custom error" do
      subject.email = 'bad@mailnator.com'
      expect(subject.valid?).to be_falsey
      expect(subject.errors[:email]).to match_array [ 'custom message' ]
    end
  end

  describe "Translating in english" do
    let!(:locale){ :en }
    let!(:errors) { [ "is invalid" ] }
    it_behaves_like "Validating emails"
  end

  describe "Translating in french" do
    let!(:locale){ :fr }
    let!(:errors) { [ "est invalide" ] }
    it_behaves_like "Validating emails"
  end
end
