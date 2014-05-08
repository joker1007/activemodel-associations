# Activemodel::Associations
[![Build Status](https://travis-ci.org/joker1007/activemodel-associations.svg?branch=master)](https://travis-ci.org/joker1007/activemodel-associations)
[![Coverage Status](https://coveralls.io/repos/joker1007/activemodel-associations/badge.png)](https://coveralls.io/r/joker1007/activemodel-associations)

`has_many` and `belongs_to` macro for Plain Ruby Object.

## Installation

Add this line to your application's Gemfile:

    gem 'activemodel-association'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activemodel-association

## Usage

### belongs\_to

```ruby
class User < ActiveRecord::Base; end

class Comment
  include ActiveModel::Model         # need ActiveModel::Model
  include ActiveModel::Associations  # include this

  attr_accessor :body, :user_id # belongs_to association need foreign_key attribute

  belongs_to :user

  # need hash like accessor, used internal Rails
  def [](attr)
    self.send(attr)
  end

  # need hash like accessor, used internal Rails
  def []=(attr, value)
    self.send("#{attr}=", value)
  end
end

user = User.create(name: "joker1007")
comment = Comment.new(user_id: user.id)
comment.user # => <User {name: "joker1007"}>
```

### Polymorphic belongs\_to

```ruby
class User < ActiveRecord::Base; end

class Comment
  include ActiveModel::Model         # need ActiveModel::Model
  include ActiveModel::Associations  # include this

  attr_accessor :body, :commenter_id, :commenter_type

  belongs_to :commenter, polymorphic: true

  # need hash like accessor, used internal Rails
  def [](attr)
    self.send(attr)
  end

  # need hash like accessor, used internal Rails
  def []=(attr, value)
    self.send("#{attr}=", value)
  end
end

user = User.create(name: "joker1007")
comment = Comment.new(commenter_id: user.id, commenter_type: "User")
comment.commenter # => <User {name: "joker1007"}>
```

### has\_many

```ruby
class User < ActiveRecord::Base; end

class Group
  include ActiveModel::Model
  include ActiveModel::Associations

  attr_accessor :name
  attr_reader :user_ids

  has_many :users

  def [](attr)
    self.send(attr)
  end

  def []=(attr, value)
    self.send("#{attr}=", value)
  end
end

user = User.create(name: "joker1007")
group = Group.new(user_ids: [user.id])
group.users # => ActiveRecord::Relation (SELECT * from users WHERE id IN (#{user.id}))
group.users.find_by(name: "none") # => []
```

## Limitation
Support associations is only `belongs_to` and simple `has_many`
`has_many` options is limited. following options is unsupported.

`:through :dependent :source :source_type :counter_cache :as`

## Contributing

1. Fork it ( https://github.com/[my-github-username]/activemodel-association/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
