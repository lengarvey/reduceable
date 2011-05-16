require 'mongo_mapper'
require 'reduceable'

MongoMapper.database = 'mr_test'

def setup
  # add some data
  Test.collection.remove
  Test.create(:date => Date.today, :tags => ['book', 'fiction'], :sale_amount => 40)
  Test.create(:date => Date.today, :tags => ['music', 'rock'], :sale_amount => 20.5)
  Test.create(:date => Date.today, :tags => ['music', 'pop'], :sale_amount => 20.5)
  Test.create(:date => Date.today, :tags => ['music', 'classical'], :sale_amount => 20.5)
  Test.create(:date => Date.today, :tags => ['music', 'alternative'], :sale_amount => 20.5)
  Test.create(:date => Date.today, :tags => ['book', 'fiction'], :sale_amount => 40)
  Test.create(:date => Date.today, :tags => ['book', 'fantasy'], :sale_amount => 40)
  Test.create(:date => Date.today, :tags => ['book', 'fantasy'], :sale_amount => 40)
  Test.create(:date => Date.today, :tags => ['book', 'non-fiction'], :sale_amount => 40)
end

class Test
  include MongoMapper::Document
  include Reduceable
  
  key :date, String # or Time YYYYMMDD format
  key :sale_id, ObjectId # a link to the sale
  key :sale_amount, Float
  key :tags, Array # a list of tags you might want to query on
                   # eg: you can query on 'book' to find out 
                   # how many book sales you have per day


end
