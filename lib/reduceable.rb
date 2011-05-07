require 'active_support'
require 'mongo_mapper'
require 'base64'

class MrStatus
  include MongoMapper::Document
  safe

  # mr collection to query
  key :collection_name, String, :unique => true
  # the base class the mr results are calculated from
  key :base_class, String 
  key :status, Boolean # true = dirty, clean = false
  
  timestamps!
end

module Reduceable
  extend ActiveSupport::Concern

  module ClassMethods
   

    class << self; attr_accessor :date_key end
    class << self; attr_accessor :properties_key end

    def reduce(date=:date, properties=:properties)
      class_eval { after_save :mr_dirty! }
      @date_key = date
      @properties_key = properties
    end
    def per_date_map
      @date_key = "date" unless @date_key
      "function(){emit(this.#{@date_key}, 1);}"
    end
    def per_date_reduce
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
    # Does this particular map reduce require an update?
    def requires_mr_update(collection)
      status_list = MrStatus.where(:collection_name => collection).all
      return true if status_list.count == 0
      status_list.each do |status|
        return status.status
      end
    end
    def per_date_collection_name(query = {})
      # we need a unique collection name based off the query
      # this introduces a fun bug where if your query params are in a random order
      # you won't get the performance increase of reusing map/reduce collections
      self.to_s + "_mr_" + Base64.urlsafe_encode64(query.to_s)
    end
    def per_date(query = {})
      build_per_date(query).find
    end
    def build_per_date(query = {})
      collection_name = per_date_collection_name(query)
      if requires_mr_update collection_name
        mr_status = MrStatus.new
        mr_status.collection_name = collection_name
        mr_status.status = false
        mr_status.base_class = self.to_s
        #mr_status.save
        opts = {:out => {:replace => collection_name}, :query => query}
        self.collection.map_reduce(per_date_map, per_date_reduce, opts)
      else
        self.database[collection_name]
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

