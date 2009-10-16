class CorporationNature < HashModel::Simple
  
  def self.data
    # [
    #   {:id => nature_id, :name => nature_name}
    # ]
    
    [
      {:id => 10, :name => "外企独资"},
      {:id => 20, :name => "中外合资"},
      {:id => 30, :name => "国有企业"},
      {:id => 40, :name => "私营企业"},
      {:id => 50, :name => "事业单位"},
      {:id => 60, :name => "政府/非营利组织"},
      {:id => 70, :name => "股份制企业"}
    ]
  end
  
end
