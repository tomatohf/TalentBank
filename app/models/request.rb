class Request < ActiveRecord::Base
  
  validates_presence_of :account_type_id, :account_id, :requester_type_id, :requester_id, :type_id
  
  
  class Type < HashModel::Simple
    def self.data
      # [
      #   {:id => type_id, :name => type_name}
      # ]

      [
        {:id => 10, :name => "revise_resume"}
      ]
    end
  end
  
end
