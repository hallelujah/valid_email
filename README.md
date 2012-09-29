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


If you don't want the MX validator stuff, just require the right file

    require 'valid_email/email_validator'

Or in your Gemfile

    gem 'valid_email', :require => 'valid_email/email_validator'

# Testing Support

Require the `valid_email/testing` in your `{test|spec}_helper.rb`:

    require 'valid_email/testing'

This disable real (probably time expensive) mx lookups during validation.
Instead domains which should be treated as valid, have to be white-listed:

    p = Person.new
    p.name = "hallelujah"
    p.email = "john@example.com"
    p.valid? # => false
    MxValidator.add_valid_domain("example.com")
    p.valid? # => true

MxValidation can be also disabled at all ...

    MxValidator.skip_mx_validation = true
    p.email = "john@notexistentdomain.abc"
    p.valid? # => true


# Credits

* Dush dusanek[at]iquest.cz

# Note on Patches/Pull Requests

* Fork the project.

* Make your feature addition or bug fix.

* Add tests for it. This is important so I don’t break it in a future version unintentionally.

* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)

* Send me a pull request. Bonus points for topic branches.

# Copyright

Copyright &copy; 2011 Ramihajamalala Hery. See LICENSE for details
