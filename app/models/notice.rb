class Notice < ActiveRecord::Base
  
  validates_presence_of :type_id, :account_type_id, :account_id, :content
  
  
  class Type < HashModel::Simple
    def self.data
      # [
      #   {:id => type_id, :name => type_name}
      # ]

      [
        {:id => 10, :name => "add_resume_comment"}
      ]
    end
  end
  
end
