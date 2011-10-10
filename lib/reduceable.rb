require 'active_support'
require 'mongo_mapper'
require 'uuidtools'

class MrStatus
  include MongoMapper::Document
  safe

  # mr collection to query
  key :collection_name, String, :unique => true
  # the base class the mr results are calculated from
  key :base_class, String 
  key :status, Boolean # true = dirty, clean = false
  
end

module Reduceable
  extend ActiveSupport::Concern

  included do
    after_save :mr_dirty!
  end

  module ClassMethods
    def sum_of(property, index, query={})
      collection = mr_collection_name("sum_of_#{property}_by_#{index}", query) 
      map = sum_map(property, index)
      reduce = sum_reduce
      return build(collection, map, reduce, query).find
    end
    def sum_map(property, index)
      index = index.to_s if index.is_a? Symbol
      if self.keys[index].type == Array
        "function(){var amount = this.#{property};this.#{index}.forEach(function(value){emit(value, amount);});}"
      else
        "function(){emit(this.#{index}, this.#{property});}"
      end
    end
    def sum_reduce 
      <<-REDUCE
        function(key, values) {
          var total = 0;
          for (var i=0; i<values.length; i++){
            total += values[i];
          }
          return total;
        }
      REDUCE
    end
    
    def average_of(property, index, query={})
      collection = mr_collection_name("average_of_#{property}_by_#{index}", query) 
      map = average_map(property, index)
      reduce = average_reduce
      return build(collection, map, reduce, query).find
    end
    def average_map(property, index)
      index = index.to_s if index.is_a? Symbol
      if self.keys[index].type == Array
        "function(){var amount = this.#{property};this.#{index}.forEach(function(value){emit(value, amount);});}"
      else
        "function(){emit(this.#{index}, this.#{property});}"
      end
    end
    def average_reduce
      <<-REDUCE
        function(key, values) {
          var total = 0;
          for (var i=0; i<values.length; i++){
            total += values[i];
          }
          return (total / values.length);
        }
      REDUCE
    end

    def count_by(index, query={})
      collection = mr_collection_name("count_by_#{index}", query) 
      map = count_map(index)
      reduce = count_reduce
      
      return build(collection, map, reduce, query).find
    end
    def count_map(key)
      # Not sure how to handle hashes yet
      key = key.to_s if key.is_a? Symbol
      if self.keys[key].type == Array
        "function(){this.#{key}.forEach(function(value){emit(value, 1);});}"
      else
        "function(){emit(this.#{key}, 1);}"
      end
    end
    def count_reduce
      <<-REDUCE
        function(key, values) {
          var total = 0;
          for (var i=0; i<values.length; i++){
            total += values[i];
          }
          return total;
        }
      REDUCE
    end

    def mr_collection_name(action, query = {})
      # we need a unique collection name based off the query
      # this introduces a fun bug where if your query params are in a random order
      # you won't get the performance increase of reusing map/reduce collections
      # TODO: come up with a better way of getting the collection name
      name_encoded = UUIDTools::UUID.md5_create(UUIDTools::UUID_DNS_NAMESPACE, action + query.to_s).to_s
      name = (self.to_s.downcase + name_encoded)
      puts "Name: #{name}"
      return name
    end

    def build(collection, map, reduce, query = {})
      if requires_mr_update collection
        mr_status = MrStatus.new
        mr_status.collection_name = collection
        mr_status.status = false
        mr_status.base_class = self.to_s
        mr_status.save
        opts = {:out => {:replace => collection}, :query => query}
        self.collection.map_reduce(map, reduce, opts)
      else
        self.database[collection]
      end
    end

    # Does this particular map reduce require an update?
    def requires_mr_update(collection)
      status_list = MrStatus.where(:collection_name => collection).all
      return true if status_list.count == 0
      status_list.each do |status|
        return status.status
      end
    end
  end

  module InstanceMethods
    def mr_dirty!
      MrStatus.where({:base_class => self.class.to_s}).all.each do |m|
        m.status = true
        m.save
      end
    end
  end
end

