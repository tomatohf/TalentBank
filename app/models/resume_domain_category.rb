class ResumeDomainCategory < HashModel::Simple
  
  def self.data
    # [
    #   {:id => category_id, :name => category_name}
    # ]
    
    [
      {:id => 100, :name => "不限方向类"},
      
      {:id => 200, :name => "销售和市场类"},
      {:id => 300, :name => "研发类"},
      {:id => 400, :name => "财会类"},
      {:id => 500, :name => "行政类"},
      
      {:id => 600, :name => "师范类"}
    ]
  end
  
end
