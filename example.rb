require 'mongo_mapper'
require './lib/reduceable'

MongoMapper.database = 'mr_test'

class Test
  include MongoMapper::Document
  include Reduceable
  
  key :date, String # or Time YYYYMMDD format
  key :sale_id, ObjectId # a link to the sale
  key :tags, Array # a list of tags you might want to query on
                   # eg: you can query on 'book' to find out 
                   # how many book sales you have per day

  reduce :date, :tags

end
