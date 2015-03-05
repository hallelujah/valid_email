require 'spec_helper'

describe ValidateEmail do
  describe '.valid?' do
    it 'should return true when passed email has valid format' do
      ValidateEmail.valid?('user@gmail.com').should be_truthy
      ValidateEmail.valid?('valid.user@gmail.com').should be_truthy
    end

    it 'should return false when passed email has invalid format' do
      ValidateEmail.valid?('user@gmail.com.').should be_falsey
      ValidateEmail.valid?('user.@gmail.com').should be_falsey
      ValidateEmail.valid?('.user@gmail.com').should be_falsey
      ValidateEmail.valid?('us..er@gmail.com').should be_falsey
    end

    context 'when mx: true option passed' do
      it 'should return true when mx record exist' do
        ValidateEmail.valid?('user@gmail.com', mx: true).should be_truthy
      end

      it "should return false when mx record doesn't exist" do
        ValidateEmail.valid?('user@example.com', mx: true).should be_falsey
      end
    end
  end
end