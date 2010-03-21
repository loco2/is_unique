require 'spec_helper'

class Location < ActiveRecord::Base
  # String name 
  # Float lat
  # Float lng
  # String alias
  # Integer unique_hash

  is_unique :ignore => :alias
end

describe "A unique model" do
  before(:each) do
    @it = Location.create(
      :name  => 'London',
      :lat   => '51.5084152563931',
      :lng   => '-0.125532746315002',
      :alias => 'Londinium'
    )
  end

  it "should not create a new record with the same attributes" do
    new_record = @it.clone
    lambda { new_record.save! }.
      should_not change(Location, :count)
  end

  it "should not create a new record with a different ignored attribute" do
    new_record = @it.clone
    new_record.alias = 'Greater London'
    lambda { new_record.save! }.
      should_not change(Location, :count)
  end
end