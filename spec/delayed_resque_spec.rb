require 'spec_helper'
require 'resque_spec/scheduler'
require 'pry'
describe DelayedResque do
  before do
    ResqueSpec.reset!
  end

  class DummyObject      
    include DelayedResque::MessageSending
    @queue = "default"
  
    def self.first_method(param)
    end
  end
  
  describe "handle_asyncronously" do 
    class Story
      class << self ; def tell!(arg);end ; handle_asynchronously :tell! ;end 
      def tell!(arg);end
      handle_asynchronously :tell!
    end

    it "aliases original method for class methid" do 
      expect(Story).to respond_to(:tell_without_delay!)
      expect(Story).to respond_to(:tell_with_delay!)
    end

    it "aliases original method for instance method" do
      expect(Story.new).to respond_to(:tell_without_delay!)
      expect(Story.new).to respond_to(:tell_with_delay!)
    end
  end

  context "class methods can be delayed" do
    it "can delay method" do
      DummyObject.delay.first_method(123)
      DelayedResque::PerformableMethod.should have_queued({"obj"=>"CLASS:DummyObject", "method"=>:first_method, "args"=>[123]}).in(:default)
    end
    
    it "delayed method is called" do
      DummyObject.stub(:second_method).with(123, 456)
      with_resque do
        DummyObject.delay.second_method(123, 456)
      end
    end
    
    it "can't delay missing method" do
      expect {
        DummyObject.delay.non_existent_method
      }.to raise_error(NoMethodError)
    end
    
    it "can pass additional params" do
      DummyObject.delay(:params => {"k" => "v"}).first_method(123)
      DelayedResque::PerformableMethod.should have_queued({"obj"=>"CLASS:DummyObject", "method"=>:first_method, "args"=>[123], "k" => "v"}).in(:default)
    end
    
  end
  
  context "active record methods can be delayed" do
  
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'dummy_models'")
    ActiveRecord::Base.connection.create_table(:dummy_models) do |t|
      t.integer :value
    end

    class DummyModel < ActiveRecord::Base
      def update_value(new_value1, new_value2)
        self.value = new_value1 + new_value2
        save!
      end
      
      def copy_value(record)
        self.value = record.value
        save!
      end

      def tell!(args)
        p "SLEEEP"
      end 
      handle_asynchronously :tell!  
    end
    
    it "can delay method" do
      record = DummyModel.create(:value => 1)
      with_resque do
        record.delay.update_value(3, 7)
      end
      record.reload.value.should eq(10)
    end
    
    it "AR model can be parameter to delay" do
      record1 = DummyModel.create(:value => 1)
      record2 = DummyModel.create(:value => 3)
      with_resque do
        record1.delay.copy_value(record2)
      end
      record1.reload.value.should eq(3)
    end
    
    it "job are enqueue in redis" do 
      record1 = DummyModel.create
      record1.tell!(1)
      expect(Resque.size("default")).to eq(1)
    end  
  end
  
  context "methods can be delayed for an interval" do
    it "can delay method" do
      DummyObject.delay(:in => 5.minutes).first_method(123)
      DelayedResque::PerformableMethod.should have_scheduled({"obj"=>"CLASS:DummyObject", "method"=>:first_method, "args"=>[123]}).in(5 * 60)
    end
    
    it "can run at specific time" do
      at_time = Time.now.utc + 10.minutes
      DummyObject.delay(:at => at_time).first_method(123)
      DelayedResque::PerformableMethod.should have_scheduled({"obj"=>"CLASS:DummyObject", "method"=>:first_method, "args"=>[123]}).at(at_time)
      DelayedResque::PerformableMethod.should have_schedule_size_of(1)
    end
  end
  
  context "unique jobs" do
    it "can remove preceeding jobs" do
      DummyObject.delay.first_method(123)
      DelayedResque::PerformableMethod.should have_queued({"obj"=>"CLASS:DummyObject", "method"=>:first_method, "args"=>[123]})
      DelayedResque::PerformableMethod.should have_queue_size_of(1)
      DummyObject.delay.first_method(124)
      DelayedResque::PerformableMethod.should have_queue_size_of(2)
      DummyObject.delay(:unique => true).first_method(123)
      DelayedResque::PerformableMethod.should have_queue_size_of(2)
    end
    
    it "can remove preceeding delayed jobs" do
      at_time = Time.now.utc + 10.minutes
      DummyObject.delay(:at => at_time).first_method(123)
      DelayedResque::PerformableMethod.should have_scheduled({"obj"=>"CLASS:DummyObject", "method"=>:first_method, "args"=>[123]}).at(at_time)
      DelayedResque::PerformableMethod.should have_schedule_size_of(1)
      DummyObject.delay(:at => at_time + 1).first_method(123)
      DelayedResque::PerformableMethod.should have_schedule_size_of(2)
      DummyObject.delay(:at => at_time + 2, :unique => true).first_method(123)
      DelayedResque::PerformableMethod.should have_schedule_size_of(1)
    end
  end
end
