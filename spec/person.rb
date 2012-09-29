class Person
  include ActiveModel::Validations
  attr_accessor :email
  validates :email, :email => true
end

class PersonWithMx
  include ActiveModel::Validations
  attr_accessor :email
  validates :email, :email => {:mx => true}
end
