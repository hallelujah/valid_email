require 'spec_helper'

shared_examples_for 'empty email pass' do
  context "when equals to nil" do
    it "should pass even if mail isn't set" do
      nilified.email = nil
      nilified.should be_valid
      nilified.errors[:email].should be_empty
    end
  end

  context "when blank" do
    it "should pass even if mail is a blank string set" do
      blanked.email = ''
      blanked.should be_valid
      blanked.errors[:email].should be_empty
    end
  end
end

describe 'validating with blank value' do
  describe 'using Mail::Address' do
    let(:nilified) { nil_allowed.new }
    let(:blanked) { blank_allowed.new }
    it_should_behave_like 'empty email pass'
  end

  describe 'using MX' do
    let(:nilified) { mx_nil_allowed.new }
    let(:blanked) { mx_blank_allowed.new }
    it_should_behave_like 'empty email pass'
  end
end
