# encoding: utf-8
require 'spec_helper'

describe ValidateEmail do
  describe '.valid?' do
    it 'returns true when passed email has valid format' do
      expect(ValidateEmail.valid?('user@gmail.com')).to be_truthy
      expect(ValidateEmail.valid?('valid.user@gmail.com')).to be_truthy
    end

    it 'returns false when passed email has invalid format' do
      expect(ValidateEmail.valid?('user@gmail.com.')).to be_falsey
      expect(ValidateEmail.valid?('user.@gmail.com')).to be_falsey
      expect(ValidateEmail.valid?('Hgft@(()).com')).to be_falsey
    end

    context 'when mx: true option passed' do
      it 'returns true when mx record exist' do
        expect(ValidateEmail.valid?('user@gmail.com', mx: true)).to be_truthy
      end

      it "returns false when mx record doesn't exist" do
        expect(ValidateEmail.valid?('user@example.com', mx: true)).to be_falsey
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
          it "returns true for #{valid_domain}" do
            email = "john@#{valid_domain}"
            expect(ValidateEmail.valid?(email, domain: true)).to be_truthy
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
          "foo bar.com",
        ]

        invalid_domains.each do |invalid_domain|
          it "returns false for #{invalid_domain}" do
            email = "john@#{invalid_domain}"
            expect(ValidateEmail.valid?(email, domain: true)).to be_falsey
          end
        end
      end
    end
  end

  describe '.valid_local?' do
    it 'returns false if the local segment is too long' do
      expect(
        ValidateEmail.valid_local?(
          'abcdeabcdeabcdeabcdeabcdeabcdeabcdeabcdeabcdeabcdeabcdeabcdeabcde'
        )
      ).to be_falsey
    end

    it 'returns false if the local segment has an empty dot atom' do
      expect(ValidateEmail.valid_local?('.user')).to be_falsey
      expect(ValidateEmail.valid_local?('.user.')).to be_falsey
      expect(ValidateEmail.valid_local?('user.')).to be_falsey
      expect(ValidateEmail.valid_local?('us..er')).to be_falsey
    end

    it 'returns false if the local segment has a special character in an unquoted dot atom' do
      expect(ValidateEmail.valid_local?('us@er')).to be_falsey
      expect(ValidateEmail.valid_local?('user.\\.name')).to be_falsey
      expect(ValidateEmail.valid_local?('user."name')).to be_falsey
    end

    it 'returns false if the local segment has an unescaped special character in a quoted dot atom' do
      expect(ValidateEmail.valid_local?('test." test".test')).to be_falsey
      expect(ValidateEmail.valid_local?('test."test\".test')).to be_falsey
      expect(ValidateEmail.valid_local?('test."te"st".test')).to be_falsey
      expect(ValidateEmail.valid_local?('test."\".test')).to be_falsey
    end

    it 'returns true if special characters exist but are properly quoted and escaped' do
      expect(ValidateEmail.valid_local?('"\ test"')).to be_truthy
      expect(ValidateEmail.valid_local?('"\\\\"')).to be_truthy
      expect(ValidateEmail.valid_local?('test."te@st".test')).to be_truthy
      expect(ValidateEmail.valid_local?('test."\\\\\"".test')).to be_truthy
      expect(ValidateEmail.valid_local?('test."blah\"\ \\\\"')).to be_truthy
    end

    it 'returns true if all characters are within the set of allowed characters' do
      expect(ValidateEmail.valid_local?('!#$%&\'*+-/=?^_`{|}~."\\\\\ \"(),:;<>@[]"')).to be_truthy
    end
  end

  describe '.mx_valid?' do
    let(:dns) { double(Resolv::DNS) }
    let(:dns_resource) { double(Resolv::DNS::Resource::IN::MX) }

    before do
      expect(Resolv::DNS).to receive(:new).and_return(dns)
      expect(dns).to receive(:close)
    end

    it "returns true when MX is true and it doesn't timeout" do
      expect(dns).to receive(:getresources).and_return [dns_resource]
      expect(ValidateEmail.mx_valid?('aloha@kmkonline.co.id')).to be_truthy
    end

    it "returns false when MX is false and it doesn't timeout" do
      expect(dns).to receive(:getresources).and_return []
      expect(ValidateEmail.mx_valid?('aloha@ga-ada-mx.com')).to be_falsey
    end

    it "returns config.default when times out", focus: true do
      Timeout.should_receive(:timeout).and_raise(Timeout::Error)
      expect(ValidateEmail.mx_valid?('aloha@ga-ada-mx.com')).to eq(ValidEmail.dns_timeout_return_value)
    end
  end
end
