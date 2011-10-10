require 'mongo_mapper'
require './lib/reduceable'

module Helpers
  MongoMapper.database = 'reduceable_dev'

  def clear_database
    MongoMapper.database.collections.each do |collection|
      begin   
        collection.drop
      rescue Exception => e   
      end   
    end
  end
  def count_answers
    {'book'=>5.0, 'fiction'=>2.0, 'music'=>4.0, 'fantasy'=>2.0, 'non-fiction'=>1.0, 'rock'=>1.0, 'pop'=>1.0, 'classical'=>1.0, 'alternative'=>1.0}
  end
  def sum_answers
    {'book'=>200.0, 'fiction'=>80.0, 'music'=>82.0, 'fantasy'=>80.0, 'non-fiction'=>40.0, 'rock'=>20.5, 'pop'=>20.5, 'classical'=>20.5, 'alternative'=>20.5}
  end
  def average_answers
    {'book'=>40.0, 'fiction'=>40.0, 'music'=>20.5, 'fantasy'=>40.0, 'non-fiction'=>40.0, 'rock'=>20.5, 'pop'=>20.5, 'classical'=>20.5, 'alternative'=>20.5}
  end
  def load_data 
    # add some data
    Sale.create(:date => Date.today, :tags => ['book', 'fiction'], :sale_amount => 40)
    Sale.create(:date => Date.today, :tags => ['music', 'rock'], :sale_amount => 20.5)
    Sale.create(:date => Date.today, :tags => ['music', 'pop'], :sale_amount => 20.5)
    Sale.create(:date => Date.today, :tags => ['music', 'classical'], :sale_amount => 20.5)
    Sale.create(:date => Date.today, :tags => ['music', 'alternative'], :sale_amount => 20.5)
    Sale.create(:date => Date.today, :tags => ['book', 'fiction'], :sale_amount => 40)
    Sale.create(:date => Date.today, :tags => ['book', 'fantasy'], :sale_amount => 40)
    Sale.create(:date => Date.today, :tags => ['book', 'fantasy'], :sale_amount => 40)
    Sale.create(:date => Date.today, :tags => ['book', 'non-fiction'], :sale_amount => 40)
  end

  class Sale 
    include MongoMapper::Document
    include Reduceable

    key :date, String # or Time YYYYMMDD format
    key :sale_amount, Float
    key :tags, Array # a list of tags you might want to query on
    # eg: you can query on 'book' to find out 
    # how many book sales you have per day
  end
end
