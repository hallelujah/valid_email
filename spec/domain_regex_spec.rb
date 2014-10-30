describe 'domain regex' do
  let(:regex) { /\A(?:\w+(?:\-+\w+)*\.)*(?:[a-z0-9][a-z0-9-]*[a-z0-9])\Z/i }

  valid_domains = [
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
    '_eoueo.oeueu.nl',
  ]

  valid_domains.each do |valid_domain|
    it "says this domain is valid: #{valid_domain}" do
      expect(valid_domain =~ regex).to eq 0
    end
  end

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
  ]

  invalid_domains.each do |invalid_domain|
    it "says this domain is invalid: #{invalid_domain}" do
      expect(invalid_domain =~ regex).to be_nil
    end
  end
end
