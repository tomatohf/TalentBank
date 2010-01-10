class Notice < ActiveRecord::Base
  
  validates_presence_of :type_id, :account_type_id, :account_id, :content
  
  
  def self.generate(account_type, account_id, type, data)
    
  end
  
  
  class Type < HashModel::Simple
    def self.data
      [
        {
          :id => 10, :name => "add_resume_comment", :icon => "", :template => %Q$
            
          $
        }
      ]
    end
  end
  
end
