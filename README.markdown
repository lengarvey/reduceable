Reducable
========

This is a module for MongoMapper which provides an easy way to add in some simple 
map/reduce functions to your data. If you have time series data and you want to show
some sort of counter per date or time, then this should do it.

Usage
-----

See example.rb
```ruby
# add some data
t = Test.new
t.date = Date.today
t.tags = ['book', 'fiction'] # or any other tag you want to associate with this sale
t.save
t = Test.new
t.date = Date.today
t.tags = ['book', 'non-fiction']
t.save
t = Test.new
t.date = Date.tomorrow
t.tags = ['book', 'fiction']
t.save

Test.per_date.to_a #=> [{"_id"=>"2011-05-07", "value"=>2.0}, {"_id"=>"2011-05-08", "value"=>1.0}]
Test.per_date({'tags'=>{'$all'=>['book']}}).to_a #=> [{"_id"=>"2011-05-07", "value"=>2.0}, {"_id"=>"2011-05-08", "value"=>1.0}]
Test.per_date({'tags'=>{'$all'=>['fiction']}}).to_a #=> [{"_id"=>"2011-05-07", "value"=>1.0}, {"_id"=>"2011-05-08", "value"=>1.0}]
```

For such a small collection the speed benefits aren't present, but once you get to
several hundred thousand record, recreating the map_reduce collection on every call 
really slows things down. Reduceable solves that problem.

