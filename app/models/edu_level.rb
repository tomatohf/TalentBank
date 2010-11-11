class EduLevel < HashModel::Simple
  
  def self.data
    # [
    #   {:id => edu_level_id, :name => edu_level_name}
    # ]
    
    [
      {:id => 10, :name => "博士"},
      {:id => 20, :name => "硕士"},
      {:id => 30, :name => "本科"},
      {:id => 40, :name => "大专"},
      {:id => 45, :name => "高中"},
      {:id => 50, :name => "中专"}
    ]
  end
  
end
