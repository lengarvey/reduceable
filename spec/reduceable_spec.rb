$: << File.dirname(__FILE__)
require 'helpers'

RSpec.configure do |c|
    c.include Helpers
end

describe "Reduceable" do
  before(:each) do
    clear_database
    load_data  
  end
  it "should count_by" do
    Sale.respond_to?(:count_by).should eql true
  end
  it "should sum_of" do
    Sale.respond_to?(:sum_of).should eql true
  end
  it "returns a cursor when asked to count" do
    values = Sale.count_by(:tags)
    values.class.should eql(Mongo::Cursor)
  end
  it "should be able to count" do 
    values = Sale.count_by(:tags).to_a
    answers = count_answers
    values.each do |value|
      id = value['_id']
      answer = answers[id]
      answer.should eql(value['value']), "Number of #{id}s calculated. Expected #{value['value']} got #{answer}"
    end  
  end
  it "should be able to add" do
    values = Sale.sum_of(:sale_amount,:tags).to_a
    answers = sum_answers
    values.each do |value|
      id = value['_id']
      answer = answers[id]
      answer.should eql(value['value']), "Number of #{id}s calculated. Expected #{value['value']} got #{answer}"
    end  
  end
  it "should be able to average" do
    values = Sale.average_of(:sale_amount,:tags).to_a
    answers = average_answers
    values.each do |value|
      id = value['_id']
      answer = answers[id]
      answer.should eql(value['value']), "Number of #{id}s calculated. Expected #{value['value']} got #{answer}"
    end  
  end
end
