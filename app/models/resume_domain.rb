class ResumeDomain < HashModel::Simple
  
  def self.data
    # [
    #   {:id => resume_model_id, :name => resume_model_name}
    # ]
    
    [
      # first 100 ids are reserved by general versions ...
      {:id => 10, :name => "不限方向"},
      
      {:id => 110, :name => "销售"},
      {:id => 120, :name => "研发"}
    ]
  end
  
  
  def self.general_version_id
    10
  end
  
  def self.general?(domain_id)
    self.general_version_id == domain_id
  end
  
end
