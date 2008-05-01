require File.join(File.dirname(__FILE__), 'spec_helper')

class TestModel < MockAR::Base
  acts_as_lookup :title
end

class Other < MockAR::Base
  acts_as_lookup :title, :default_text => '-- Choose --', :conditions => 'id <> 3', :order => 'id DESC'
end

describe "ActsAsLookup Plugin" do
  E = RPH::ActsAsLookup::Error
  
  before(:each) do
    @tm = TestModel
  end
  
  describe "Models" do
    it "should respond to `acts_as_lookup'" do
      @tm.should respond_to(:acts_as_lookup)
    end
  
    it "should respond to `options_for_select'" do
      @tm.should respond_to(:options_for_select)
    end
    
    it "should respond to `field_to_select'" do
      @tm.should respond_to(:field_to_select)
    end
    
    it "should have field_to_select set to 'title'" do
      @tm.field_to_select.should eql(:title)
    end
    
    describe "default options" do
      it "should have no conditions by default" do
        @tm.options[:conditions].should be_nil
      end
      
      it "should have default text of '--' for first select item" do
        @tm.options[:default_text].should_not be_nil
        @tm.options[:default_text].should eql('--')
      end
    
      it "should have default order of field_to_select (for alphabetical list)" do
        @tm.options[:order].should_not be_nil
        @tm.options[:order].should eql(@tm.field_to_select.to_s)
      end
    end
    
    describe "customization" do      
      before(:each) do
        @other = Other
      end
      
      it "should support custom text for the first select entry" do
        @other.options_for_select.first[0].should eql('-- Choose --')
      end
    
      it "should support custom conditions for SQL" do
        @other.options[:conditions].should_not be_nil
        @other.options[:conditions].should eql('id <> 3')
      end
    
      it "should support custom order for SQL" do
        @other.options[:order].should_not be_nil
        @other.options[:order].should eql('id DESC')
      end
    end
  end
  
  describe "Views" do
    include ActionView::Helpers::FormOptionsHelper
    
    it "should respond to `lookup_for'" do
      ActionView::Base.new.should respond_to(:lookup_for)
    end
    
    it "`lookup_for' should act the same as regular select" do
      ActionView::Base.new.lookup_for(:other, :test_model_id).
        should eql(select(:other, :test_model_id, TestModel.options_for_select))
    end
  end
  
  describe "Errors" do
    it "should raise InvalidAttr if attr passed to `acts_as_lookup' does not exist" do
      TestModel.acts_as_lookup(:wrong) rescue E::InvalidAttr
    end
    
    it "should raise InvalidLookup if model passed to `lookup_for' does not have `acts_as_lookup'" do
      ActionView::Base.new.lookup_for(:wrong) rescue E::InvalidLookup
    end
    
    it "should raise InvalidModel if model passed to `lookup_for' does not exist" do
      class InvalidModel; self; end
      
      ActionView::Base.new.lookup_for(:invalid_model) rescue E::InvalidModel
    end
  end
end