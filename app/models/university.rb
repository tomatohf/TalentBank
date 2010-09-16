class University < HashModel::Simple
  
  def self.data
    # [
    #   {:id => university_id, :name => university_name}
    # ]
    
    [
      {:id => 100100, :name => "乔布堂"},
      {:id => 100200, :name => "上海海洋大学"}
    ]
  end
  
end
