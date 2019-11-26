# ReactiveObservers

[![Build Status](https://travis-ci.com/martintomas/reactive_observers.svg?branch=master)](https://travis-ci.com/martintomas/reactive_observers)
[![codecov](https://codecov.io/gh/martintomas/reactive_observers/branch/master/graph/badge.svg)](https://codecov.io/gh/martintomas/reactive_observers)

This gem can make observer from every possible class or object. Observer relation can be defined at Class level and processed dynamically when appropriate record changes. Observable module is using build in Active Record hooks or database triggers which can be turned on for specified tables in multiple App environment.

```ruby
class Topic < ActiveRecord::Base; end
class CustomObserver
  include ReactiveObservers::Base
  
  def changed(topic, **observer); end
end

# possible usage of observer
# when observer is defined at class level, observer object is initialized when observed record changes
CustomObserver.observe(:topics) # observer klass is observing Topic (Active Record klass)
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

Observing relation can be initialized between object/class pairs. Observer can be any class or object. Observable has to be always Active Record class or object. It is recommended to define class observers as often as possible, because It enables to observe all active records independently and initialize all required data after observer is triggered. 

Every class can be transformed to observer just by including following module:

    $ include ReactiveObservers::Base

Class has access to `observe` method now and can observe any active record object or class. Registering of observer can be done for example by:

    $ YourClass.observe(ActiveRecord::Base)
    
Observe method accepts several different arguments which are:
* filtering options
    * `on` - observer is notified only when specific types of action happens, for example: `on: [:create, :update]`
    * `fields` - observer is notified only when specified active record attributes are changed, for example: `fields: [:first_name, :last_name]`
    * `only` - accepts Proc and can do additional complex filtering, for example: `only: ->(active_record) { active_record.type == 'ObservableType' }`
* active options
    * `trigger` - can be symbol or Proc and defines action which is called on observer, for example: `trigger: :recompute_statistics`. Default value, which can be changed through configuration, is `:changed`. 
    * `notify` - can be Symbol or Proc and defines action which is used to initialize observes class, for example: `notify: :load_all_dependent_objects`
    * `refine` - accepts Proc and defines operation which is done with active record object before observer is called, for example: `refine: ->(active_record) { active_record.topics }`
* additional options
    * `context` - observer can be registered with context information which is provided back from observed object when notification happens. Example of such option can be for example: `context: :topic`

### Active Record as Observer

Every Active Record class can be transformed to observer - It can observe and be observed at same time. Let's have following example:

```ruby
class Comment < ActiveRecord::Base; end
class Topic < ActiveRecord::Base
  include ReactiveObservers::Base

  # register observer for comments
  # when Comment is created, call update_topic_dashboard of Topic
  # notify param tells observed objects which topic should be called
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

  # you can recompute statistics for topic which has changed
  def recompute_statistics(topic, **observer); end
end
```

Class observers can become a bit tricky when initialization method is defined inside observer.

```ruby
class TopicStatisticService
  include ReactiveObservers::Base

  observe :topics, fields: :active_users, trigger: :recompute_statistics, only: -> (topic) { topic.active? },
          notify: ->(topic) { TopicStatisticService.new(topic, topic.active_comments) }

  # observed object will use notify param to instanciate TopicStatisticService object
  # this param is required because initialize requires additional arguments 
  def initialize(topic, active_comments); end

  def recompute_statistics(topic, **observer); end
end
```

Initialize method of class can quickly get out of the hand and It can be impossible to initialize it only with observed object information. Fortunately, observing can be defined at object level which doesn't require initialization.

```ruby
class ComplexStatisticsService
  include ReactiveObservers::Base
 
  # both params are unknown and It is impossible to initialize ComplexStatisticsService with observed data
  def initialize(unknown_param1, unknown_param2); end

  def changed(record, **observer); end
end

# Class.observe pattern cannot be used in this case, because observed record cannot probably instantiate this service.
# You can register specific service as observer
ComplexStatisticsService.new(param1, param2).observe(:topics) # all topics will be observed
ComplexStatisticsService.new(param1, param2).observe(Topic.first) # only first topic will be observed
```

### Observer Class

Implementation of specific observers can be encapsulated into one class which makes future maintenance quite simple - in reality, this is preferred way how to define observers. Quite dummy example of such observer class can be:

```ruby
# Example of Activity Observer
# observe appropriate record and recompute topic activity when data changes 
class ActivityObserver
  include ReactiveObservers::Base

  observe :topics, fields: :last_activity
  observe :comments, refine: ->(comment) { comment.topic }
  observe :users, fields: :open_topic, refine: ->(user) { user.open_topic }
  observe :images, on: :create, trigger: :image_uploaded

  # activity data at topic changed, recompute it
  def changed(topic, **observer); end

  # image upload requires specifies approach, use special trigger for it
  def image_uploaded(image, **observer); end
end
```

### Remove Observer

It is possible to remove observers from observed class or object at any time.

```ruby
Topic.remove_observer(ActivityObserver) # remove activity observer from Topic class
Topic.first.remove_observer(ActivityObserver) # remove observer from first topic
Topic.remove_observer(observing_service) # observer can be also object and this observer can be removed same way as class observer

# remove_observer method accepts additional arguments that specifies which observers should be removed
Topic.remove_observer(ActivityObserver, trigger: :image_uploaded) # only observer with appropriate trigger will be removed
Topic.remove_observer(ActivityObserver, trigger: :image_uploaded, on: [:create, :update])
Topic.remove_observer(ActivityObserver, fields: [:first_name, :last_name])
Topic.remove_observer(ActivityObserver, notify: :prepare_observer)
Topic.remove_observer(ActivityObserver, context: :topic) # only observer with appropriate context will be removed
```

### Database Triggers (Advanced)

Observed data can be sometimes manipulated by several different sources - for example different apps can update it. Unfortunately, active record hooks in our Rails App cannot catch such change - which can cause that observers are not notified. For this purpose, this gem supports observers which use database triggers.

Only __PostgreSQL database__ is supported now but You are welcomed to add other database adapters!

To enable database observers, following configuration needs to be put into initializers:

    ReactiveObservers.configure do |config| 
      config.observed_tables = [:topics] # names of tables which should be observed
    end
    
It is also required to create appropriate database triggers. __TODO:__ prepare jobs that generates appropriate triggers for defined tables.

Gem listens on `TG_TABLE_NAME_notices` which for example means that observer for topic table will listen on `topic_notices`. This default behaviour can be changed at configuration:

    $ ReactiveObservers.configure { |config| config.listening_job_name = "%{table_name}_notices" }
    
Data obtained through trigger are forwarded to observers, but can be also used for different purposes (not just observing). It is possible to register any method that can process trigger data at any active record model:

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

