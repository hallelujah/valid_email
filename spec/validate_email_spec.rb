# encoding: utf-8
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
      ValidateEmail.valid?('Hgft@(()).com').should be_falsey
    end

    context 'when mx: true option passed' do
      it 'should return true when mx record exist' do
        ValidateEmail.valid?('user@gmail.com', mx: true).should be_truthy
      end

      it "should return false when mx record doesn't exist" do
        ValidateEmail.valid?('user@example.com', mx: true).should be_falsey
      end
    end

    context 'when domain: true option passed' do
      context 'with valid domains' do
        valid_domains = [
          'example.org',
          '0-mail.com',
          '0815.ru',
          '0clickemail.com',
          'test.co.uk',
          'fux0ringduh.com',
          'girlsundertheinfluence.com',
          'h.mintemail.com',
          'mail-temporaire.fr',
          'mt2009.com',
          'mega.zik.dj',
          'e.test.com',
          'a.aa',
          'test.xn--clchc0ea0b2g2a9gcd',
          'my-domain.com',
        ]

        valid_domains.each do |valid_domain|
          it "should return true for #{valid_domain}" do
            email = "john@#{valid_domain}"
            ValidateEmail.valid?(email, domain: true).should be_truthy
          end
        end
      end

      context 'with invalid domain' do
        invalid_domains = [
          '-eouae.test',
          'oue-.test',
          'oeuoue.-oeuoue',
          'oueaaoeu.oeue-',
          'ouoeu.eou_ueoe',
          'тест.рф',
          '.test.com',
          'test..com',
          'test@test.com',
          "example.org$\'",
        ]

        invalid_domains.each do |invalid_domain|
          it "should return false for #{invalid_domain}" do
            email = "john@#{invalid_domain}"
            ValidateEmail.valid?(email, domain: true).should be_falsey
          end
        end
      end
    end
  end

  describe '.valid_local?' do
    it 'should return false if the local segment is too long' do
      ValidateEmail.valid_local?(
        'abcdeabcdeabcdeabcdeabcdeabcdeabcdeabcdeabcdeabcdeabcdeabcdeabcde'
      ).should be_falsey
    end

    it 'should return false if the local segment has an empty dot atom' do
      ValidateEmail.valid_local?('.user').should be_falsey
      ValidateEmail.valid_local?('.user.').should be_falsey
      ValidateEmail.valid_local?('user.').should be_falsey
      ValidateEmail.valid_local?('us..er').should be_falsey
    end

    it 'should return false if the local segment has a special character in an unquoted dot atom' do
      ValidateEmail.valid_local?('us@er').should be_falsey
      ValidateEmail.valid_local?('user.\\.name').should be_falsey
      ValidateEmail.valid_local?('user."name').should be_falsey
    end

    it 'should return false if the local segment has an unescaped special character in a quoted dot atom' do
      ValidateEmail.valid_local?('test." test".test').should be_falsey
      ValidateEmail.valid_local?('test."test\".test').should be_falsey
      ValidateEmail.valid_local?('test."te"st".test').should be_falsey
      ValidateEmail.valid_local?('test."\".test').should be_falsey
    end

    it 'should return true if special characters exist but are properly quoted and escaped' do
      ValidateEmail.valid_local?('"\ test"').should be_truthy
      ValidateEmail.valid_local?('"\\\\"').should be_truthy
      ValidateEmail.valid_local?('test."te@st".test').should be_truthy
      ValidateEmail.valid_local?('test."\\\\\"".test').should be_truthy
      ValidateEmail.valid_local?('test."blah\"\ \\\\"').should be_truthy
    end

    it 'should return true if all characters are within the set of allowed characters' do
      ValidateEmail.valid_local?('!#$%&\'*+-/=?^_`{|}~."\\\\\ \"(),:;<>@[]"').should be_truthy
    end
  end
end
