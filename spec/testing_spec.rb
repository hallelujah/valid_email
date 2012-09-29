require 'spec_helper'

describe "testing" do
  subject { PersonWithMx.new }
  before do
    load "valid_email/testing.rb"
  end

  after do
    MxValidator.class_eval do
      remove_method :validate_each
      alias_method :validate_each, :validate_each_old
      remove_method :validate_each_old
    end
  end

  it "should skip mx validation when skip_mx_validation is set" do
    MxValidator.skip_mx_validation = true
    subject.email = 'john1@nonexistentdomain.abc'
    subject.valid?.should be_true
    MxValidator.skip_mx_validation = false
    subject.valid?.should be_false
  end

  it "should validate domains when they are added to valid_domains" do
    MxValidator.add_valid_domain("nonexistentdomain.abc")
    subject.email = 'john2@nonexistentdomain.abc'
    subject.valid?.should be_true
  end
end
