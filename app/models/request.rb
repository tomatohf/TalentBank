class Request < ActiveRecord::Base
  
  validates_presence_of :account_type_id, :account_id, :requester_type_id, :requester_id, :type_id
  
  
  include Utils::FieldHashable
  hash_field :data
  
  
  def requests_of_target
    
  end
  
  
  def self.generate(account_type, account_id, requester_type, requester_id, type_name, options = {})
    type = Type.find_by(:name, type_name)
    
    request = self.new(
      :account_type_id => AccountType.find_by(:name, account_type)[:id],
      :account_id => account_id,
      :requester_type_id => AccountType.find_by(:name, requester_type)[:id],
      :requester_id => requester_id,
      :type_id => type[:id],
      :target_id => options[:target_id]
    )
    request.fill_data(options[:data] || {})
    
    request.save!
    
    request
  end
  
  
  class Type < HashModel::Simple
    def self.data
      [
        {:id => 10, :name => "revise_resume", :label => "修改简历", :icon => "revise_resume.gif"}
      ]
    end
  end
  
  
  class TypeAdapter
    def initialize(type_name)
      extend(instance_eval(type_name.camelize))
    end
  end
  
  
  module ReviseResume
    
  end
  
end
