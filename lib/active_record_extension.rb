# THIS FILE GOES IN lib directory
# In config/initializers/ you put a single file called extensions.rb which just has:
#  require "active_record_extension" 

module ActiveRecordExtensions
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    #
    #
    # Note that all class methods need to start with def not def self.
    #
    #
    
    # Simple proof that a class extension works; apologies to Austin Powers
    def foo
      puts "Jam Baby Jam!!!"
    end

=begin
    attributes = ActiveSupport::HashWithIndifferentAccess.new
    
    attributes[:name] = "Reddit"
    attributes[:domain] = "reddit.com"
    attributes[:protocol] = "https"
    attributes[:url] = "https://www.reddit.com/"
    
    site = Site.find_or_create_by_attributes(attributes, :name)

    required_thing = {}
    required_thing[:name] = "Reddit"
    site = Site.find_or_create_by_attributes(attributes, required_thing)
    
    required_things = [:name, :protocol]
    site = Site.find_or_create_by_attributes(attributes, required_things)
    
=end    
    #
    # Accepts two forms - either a single key with the value
    # Site.find_or_create_by_attributes(attributes, :name)
    # Site.find_or_create_by_attributes(attributes, {:name => "foo", :type => "bar"})
    #
    def find_or_create_by_attributes(attributes, required_thing)

      if required_thing.is_a?(Hash)
        obj = self.where(required_thing).first
      elsif required_thing.is_a?(Array)
        query_params = {}
        required_thing.each do |rt|
          query_params[rt] = attributes[rt]
        end
        obj = self.where(query_params).first
      else
        obj = self.where(["#{required_thing.to_s} = ?", attributes[required_thing]]).first
      end
      return obj if obj
            
      obj = self.create(attributes)
      return obj if obj.persisted?
    
      raise obj.errors.full_messages
    end
        
    def find_or_create(params)
      begin
        return self.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        attrs = {}

        # search for valid attributes in params
        self.column_names.map(&:to_sym).each do |attrib|
          # skip unknown columns, and the id field
          next if params[attrib].nil? || attrib == :id

          attrs[attrib] = params[attrib]
        end

        # call the appropriate ActiveRecord finder method
        found = self.send("find_by_#{attrs.keys.join('_and_')}", *attrs.values) if !attrs.empty?

        if found && !found.nil?
          return found
        else
          return self.create(params)
        end
      end
    end
    alias create_or_find find_or_create
  end
end

ActiveRecord::Base.send(:include, ActiveRecordExtensions)