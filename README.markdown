Reducable
=========

This is a module for MongoMapper which provides an easy way to add in some simple 
map/reduce functions to your data. If you have time series data and you want to show
some sort of counter per date or time, then this should do it.

Concept
-------
You have a bunch of objects in your MongoDB. You need to get some basic information
about them such as:
Simple aggregation of documents per key,
Finding an average of a value,
Counting the number of documents that contain a key.

You've probably read you can do this sort of stuff with MongoDB's map/reduce
functionality, maybe you already know exactly how that works or maybe you don't
really have a clue. Every guide I've seen for MongoMapper recommends you execute
the map/reduce calculation every single time it's accessed, and they all demand
that you write your own map and reduce functions.

Here are some use cases

```ruby
# Count how many times each tag is used
Model.count_by(:tag, query = {})
# Sum all the weights of the different types of wrestlers 
Model.sum_of(:weight, :wrestler_type, query = {})
# Find Average Weight of the different types of wrestlers
Model.average_of(:weight, :wrestler_type, query = {})
```

Coming Soon
----------
+ mongoid support
+ Sum by composite index
+ More Unit Tests :(

Installation
------------
```
gem install reduceable
# or
sudo gem install reduceable
```

Usage
-----
```ruby
require 'mongo_mapper'
require 'reduceable'

MongoMapper.database = 'my_database_name'

class BlogPost
  include MongoMapper::Document
  include Reduceable

  key :article_body, String
  key :categories, Array
  key :time_posted, Time
  key :article_length, Integer
end

# Insert some data

BlogPost.count_by(:categories).to_a.each do |x| 
  puts "You have posted #{x['value']} posts from catefory #{x['_id']}"
end
BlogPost.sum_of(:article_length, :categories).to_a.each do |x|
  puts "You have written #{x['value']} characters in category #{x['_id']}"
end
BlogPost.average_of(:article_length, :categories).to_a.each do |x|
  puts "An article in category #{x['_id']} has an average of #{x['value']} characters"
end
```

See example.rb

```ruby
# require the example model
require './example.rb'  #=> true
# setup some base data
setup #=> #<Test _id: BSON: ...... 
#
# Calculate how many times each tag is used
# You will use a similar map/reduce for a tag cloud
Test.count_by(:tags).to_a
#=> [{"_id"=>"alternative", "value"=>1.0}, {"_id"=>"book", "value"=>5.0}, {"_id"=>"classical", "value"=>1.0}, {"_id"=>"fantasy", "value"=>2.0}, {"_id"=>"fiction", "value"=>2.0}, {"_id"=>"music", "value"=>4.0}, {"_id"=>"non-fiction", "value"=>1.0}, {"_id"=>"pop", "value"=>1.0}, {"_id"=>"rock", "value"=>1.0}]

# Sum up the sale_amounts per tag
Test.sum_of(:sale_amount, :tags).to_a

# Find the average sale_amounts per tag
Test.average_of(:sale_amount, :tags).to_a

# Sum up the sale_amounts per tag where tags contains 'book'
Test.sum_of(:sale_amount, :tags, {:tags => 'book'}).to_a
# you can optionally pass in a mongo query that limits the initial dataset being
# fed to the map function.

# Find the average of sale_amounts per tag where tags contains 'book'
Test.average_of(:sale_amount, :tags, {:tags => 'book'}).to_a
# you can optionally pass in a mongo query that limits the initial dataset being
# fed to the map function.
```

For such a small collection the speed benefits aren't present, but once you get to
several hundred thousand record, recreating the map_reduce collection on every call 
really slows things down. Reduceable solves that problem.

