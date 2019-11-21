[![Build Status](https://travis-ci.com/martintomas/reactive_observers.svg?branch=master)](https://travis-ci.com/martintomas/reactive_observers)
[![codecov](https://codecov.io/gh/martintomas/reactive_observers/branch/master/graph/badge.svg)](https://codecov.io/gh/martintomas/reactive_observers)

# ReactiveObservers

This gem allows you to write down specialized Observer classes or make observer from every possible class or object that You can think of. Observable module is using build in Active Record hooks or database triggers which can be turned on for specified tables in multiple App environment.

```ruby
class Topic < ActiveRecord::Base; end
class CustomObserver
  include ReactiveObservers::Base
  
  def changed(topic, **observer); end
end

# possible usage of observer
CustomObserver.observe(:topics) # our observer klass is observing Topic (Active Record klass)
CustomObserver.observe(Topic.first) # observer is observing specific topic
CustomObserver.new.observe(:topics) # specific observer is observing Topic
CustomObserver.new.observe(Topic.first) # specific observer is observing specific topic
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reactive_observers'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install reactive_observers

## Usage

Observing can be initialized by object/class and record/active record class can be observed. It is preferred to observe Class when You wish to observe all record independently. It is preferred to use Observer as Class when observer is Active Record as well, observer is not holding any additional internal logic or this logic directly depends on observed data.

To make from your class observer, just include following module:

    $ include ReactiveObservers::Base

Your class have access to `observe` method now and can observe any active record object or class. Registering of observer can be done for example by:

    $ YourClass.observe(ActiveRecord::Base)
    
Observe method accepts several additional arguments which are:
* filtering options
    * `on` - observer is notified only when specific types of action happens, for example: `on: [:create, :update]`
    * `fields` - observer is notified only when specified active record attributes are changed, for example: `fields: [:first_name, :last_name]`
    * `only` - excepts Proc and can do other complex filtering, for example: `only: ->(active_record) { active_record.type == 'ObservableType' }`
* action options
    * `trigger` - can be symbol or Proc and defines action which is called on observer, for example: `trigger: :recompute_statistics`. Default value, which can be changed through configuration is `:changed`. 
    * `notify` - can be Symbol or Proc and defines action which is used to initialize observed objects, for example: `notify: :load_all_dependent_objects`
    * `refine` - excepts Proc and defines operation which is done with active record before observer is called, for example: `refine: ->(active_record) { active_record.topics }`
* additional options
    * `context` - observer can be registered with context information which is provided back from observed object when notification happens. Example of this is: `context: :topic`

### Active Record as Observer

Every Active Record class can be transformed to observer - can observe and be observed at same time. Let's have following example:

```ruby
class Comment < ActiveRecord::Base; end
class Topic < ActiveRecord::Base
  include ReactiveObservers::Base

  # register observer for comments
  # when Comment is created, call update_topic_dashboard of Topic
  # notify param tells observed objects which topic call
  observe :comments, on: :create, trigger: :update_topic_dashboard, notify: ->(comment) { comment.topic }
  
  def update_topic_dashboard(**observer); end
end
```

### Observer as part of any class

Every possible class can be transformed to observer. Let's define simple class as our first example:

```ruby
class TopicsStatisticService
  include ReactiveObservers::Base

  observe :topics, fields: :active_users, trigger: :recompute_statistics
  observe :comments, on: :create, trigger: :recompute_statistics, refine: ->(comment) { comment.topic }

  # you can recompute statistics for topic which changed
  def recompute_statistics(topic, **observer); end
end
```

Perfect, let's increase difficulty a bit and add custom initialization to our Service class.

```ruby
class TopicStatisticService
  include ReactiveObservers::Base

  observe :topics, fields: :active_users, trigger: :recompute_statistics, only: -> (topic) { topic.active? },
          notify: ->(topic) { TopicStatisticService.new(topic, topic.active_comments) }

  def initialize(topic, active_comments); end

  def recompute_statistics(topic, **observer); end
end
```

Initialize method of class can quickly get out of the hands and It can be impossible to initialize it only with observed objects. In this case, you probably want to use create observer from specific object.

```ruby
class ComplexStatisticsService
  include ReactiveObservers::Base

  def initialize(unknown_param1, unknown_param2); end

  def changed(record, **observer); end
end

# Class.observe pattern cannot be used in this case, because observed record cannot probably instantiate this service.
# You can of course register specific service as observer
 
ComplexStatisticsService.new(param1, param2).observe(:topics) # all topics will be observed
ComplexStatisticsService.new(param1, param2).observe(Topic.first) # only first topic will be observed
```

### Observer Class

All observing definition can be put into one class - in reality, this is preferred way how to define observers. Simple example of such observer class can be:

```ruby
class ActivityObserver
  include ReactiveObservers::Base

  observe :topics, fields: :last_activity
  observe :comments, refine: ->(comment) { comment.topic }
  observe :users, fields: :open_topic, refine: ->(user) { user.open_topic }
  observe :images, on: :create, trigger: :image_uploaded

  def changed(topic, **observer); end
  def image_uploaded(image, **observer); end
end
```

### Database Triggers (Advanced)

Data that are observed can be sometimes changed by several different sources (different apps can manipulate with data) and active record hooks cannot catch such updates. For this purpose, this gem supports observers which use database triggers. Unfortunately, only __PostgreSQL database__ is supported now!

To enable database observers, following configuration needs to be put into initializers:

    ReactiveObservers.configure do |config| 
      config.observed_tables = [:topics] # names of tables which should be observed
    end
    
It is also required to create appropriate database triggers. TODO: prepare jobs that generate appropriate triggers for defined tables.

Gem listen on `TG_TABLE_NAME_notices` which means that observer for topic table will listen on `topic_notices`. This default behaviour can be changed at configuration:

    $ ReactiveObservers.configure { |config| config.listening_job_name = "%{table_name}_notices" }
    
Data obtained through trigger can be also used for different purposes (not just observing). It is possible to register any method that can proccess trigger data for appropriate model:

```ruby
class Topic < ActiveRecord::Base
  register_observer_listener :process_trigger
  
  def self.process_trigger(data); end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/martintomas/reactive_observers. This project is intended to be a safe and welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

