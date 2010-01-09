class AccountType < HashModel::Simple
  
  def self.data
    # [
    #   {:id => account_type_id, :name => account_type_name, :label => account_type_label}
    # ]
    
    [
      {:id => 10, :name => "students", :label => "学生"},
      {:id => 20, :name => "teachers", :label => "老师"},
      {:id => 30, :name => "corporations", :label => "企业"}
    ]
  end
  
end
