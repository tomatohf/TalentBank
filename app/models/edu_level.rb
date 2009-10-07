class EduLevel < HashModel::Simple
  
  def self.data
    # [
    #   {:id => edu_level_id, :name => edu_level_name}
    # ]
    
    [
      {:id => 100100, :name => "博士"},
      {:id => 100200, :name => "硕士"},
      {:id => 100300, :name => "本科"},
      {:id => 100400, :name => "大专"}
    ]
  end
  
end
