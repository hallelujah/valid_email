shared_examples 'Translated errors' do |scope, returns, options = {}|
  around do |example|
    old_locale = I18n.locale
    I18n.locale = options[:lang] || :en
    example.run
    I18n.locale = old_locale
  end

  it 'should use I18n' do
    const = stub_const("I18n", double)
    expect(const).to receive(:t).with(:invalid, scope: "valid_email.validations.#{scope}").and_return(returns)
    expect(subject).to be_invalid
    subject.errors[:email].should eq [returns]
  end

end
