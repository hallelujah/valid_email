# Purpose

It validates email for application use (registering a new account for example)

# Usage

In your Gemfile :

    gem 'valid_email'


In your code :

    require 'valid_email'
    class Person
      include ActiveModel::Validations
      attr_accessor :name, :email

      validates :name, :presence => true, :length => { :maximum => 100 }
      validates :email, :presence => true, :email => true
    end


    p = Person.new
    p.name = "hallelujah"
    p.email = "john@doe.com"
    p.valid? # => true

    p.email = "john@doe"
    p.valid? # => false

    p.email = "John Does <john@doe.com>"
    p.valid? # => false

You can check if email domain has MX record :

    validates :email, :email => {:mx => true, :message => I18n.t('validations.errors.models.user.invalid_email')}

Or

    validates :email, :email => {:message => I18n.t('validations.errors.models.user.invalid_email')}, :mx => {:message => I18n.t('validations.errors.models.user.invalid_mx')}

Alternatively, you can check if an email domain has a MX or A record by using `:mx_with_fallback` instead of `:mx`.

You can detect disposable accounts

    validates :email, :email => {:ban_disposable_email => true, :message => I18n.t('validations.errors.models.user.invalid_email')}

If you don't want the MX validator stuff, just require the right file

    require 'valid_email/email_validator'

Or in your Gemfile

    gem 'valid_email', :require => 'valid_email/email_validator'

## Usage outside of Ruby on Rails

If you want to run the validation outside of rails, the module `ValidateEmail` is provided and can be used in this way:

    require 'valid_email'
    ValidateEmail.valid?('john@doe.com', mx: true) # mx can be omitted and will be false

If you want to check mx only:

    require 'valid_email'
    ValidateEmail.mx_valid?('john@doe.com')

## String monkeypatch

There is also the option to use `String#email?` method if you include the file:

    require 'valid_email/all_with_string'
    'john@doe.com'.email? # => true
    nil.email?            # => false

Or in `Gemfile` you can write:

    gem 'valid_email', :require => 'valid_email/all_with_string'

# Credits

* Dush dusanek[at]iquest.cz
* Ramihajamalala Hery hery[at]rails-royce.org
* Marco Perrando mperrando[at]soluzioninrete.it
* MIke Carter mike[at]mcarter.me
* Oleg Shur workshur[at]gmail.com
* Jörg Thalheim joerg[at]higgsboson.tk
* Jean Boussier jean.boussier[at]gmail.com

# Note on Patches/Pull Requests

* Fork the project.

* Make your feature addition or bug fix.

* Add tests for it. This is important so I don’t break it in a future version unintentionally.

* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)

* Send me a pull request. Bonus points for topic branches.

# Copyright

Copyright &copy; 2011 Ramihajamalala Hery. See LICENSE for details
