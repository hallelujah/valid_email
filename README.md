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

You can check if email domain has MX record:

    validates :email, :email => {:mx => true, :message => I18n.t('validations.errors.models.user.invalid_email')}

Or

    validates :email, :email => {:message => I18n.t('validations.errors.models.user.invalid_email')}, :mx => {:message => I18n.t('validations.errors.models.user.invalid_mx')}

By default, the email domain is validated using a regular expression, which does not require an external service and improves performance.
Alternatively, you can check if an email domain has a MX or A record by using `:mx_with_fallback` instead of `:mx`.

    validates :email, :email => {:mx_with_fallback => true}

You can detect disposable accounts

    validates :email, :email => {:ban_disposable_email => true, :message => I18n.t('validations.errors.models.user.invalid_email')}

If you don't want the MX validator stuff, just require the right file

    require 'valid_email/email_validator'

Or in your Gemfile

    gem 'valid_email', :require => 'valid_email/email_validator'


### Usage outside of model validation
There is a chance that you want to use e-mail validator outside of model validation.  
If that's the case, you can use the following methods:

```ruby
ValidateEmail.valid?('email@randommail.com') # You can optionally pass a hash of options, same as validator
ValidateEmail.mx_valid?('email@randommail.com')
ValidateEmail.mx_valid_with_fallback?('email@randommail.com')
ValidateEmail.valid?('email@randommail.com')
```

Load it (and not the rails extensions) with 

    gem 'valid_email', require: 'valid_email/validate_email'


### String and Nil object extensions

There is also a String and Nil class extension, if you require the gem in this way in Gemfile:

```ruby
gem 'valid_email', require: ['valid_email/all_with_extensions']
```

You will be able to use the following methods:
```ruby
nil.email? # => false
"john@gmail.com".email? # => May return true if it exists. It accepts a hash of options like ValidateEmail.valid?
```

## Code Status

* [![Build Status](https://travis-ci.org/hallelujah/valid_email.svg?branch=master)](https://travis-ci.org/hallelujah/valid_email)

# Credits

* Ramihajamalala Hery hery[at]rails-royce.org
* Fire-Dragon-DoL francesco.belladonna[at]gmail.com
* dush dusanek[at]iquest.cz
* MIke Carter mike[at]mcarter.me
* Heng heng[at]reamaze.com
* Marco Perrando mperrando[at]soluzioninrete.it
* Jörg Thalheim joerg[at]higgsboson.tk
* Andrey Deryabin deriabin[at]gmail.com
* Nicholas Rutherford nick.rutherford[at]gmail.com
* Oleg Shur workshur[at]gmail.com
* Joel Chippindale joel[at]joelchippindale.com
* Sami Haahtinen sami[at]haahtinen.name
* Jean Boussier jean.boussier[at]gmail.com
* Masaki Hara - @qnighy

# Note on Patches/Pull Requests

* Fork the project.

* Make your feature addition or bug fix.

* Add tests for it. This is important so I don’t break it in a future version unintentionally.

* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)

* Send me a pull request. Bonus points for topic branches.

# Copyright

Copyright &copy; 2011 Ramihajamalala Hery. See LICENSE for details
