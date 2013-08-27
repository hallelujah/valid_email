# Purpose

It validates email for application use (registering a new account for example)

# Usage

In your Gemfile :

```ruby
gem 'valid_email'
```

In your code :

```ruby
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
```

You can check if email domain has MX record (note that you need to require mx validator, see below):

```ruby
validates :email, :email => {:mx => true, :message => I18n.t('validations.errors.models.user.invalid_email')}
```

Or

```ruby
validates :email, :email => {:message => I18n.t('validations.errors.models.user.invalid_email')}, :mx => {:message => I18n.t('validations.errors.models.user.invalid_mx')}
```

If you want to use the MX validator stuff, just require the right file

```ruby
require 'valid_email/mx_validator'
```

Or in your Gemfile

```ruby
gem 'valid_email', :require => 'valid_email/mx_validator'
```

# I18n

Add to your locales file:

    en:
      valid_email:
        validations:
          email:
            invalid: "is invalid"

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
