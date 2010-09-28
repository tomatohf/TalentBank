class CorporationNature < HashModel::Simple
  
  def self.data
    # [
    #   {:id => nature_id, :name => nature_name}
    # ]
    
    [
      {:id => 10, :name => "外资(欧美)"},
      {:id => 20, :name => "外资(非欧美)"},
      {:id => 30, :name => "国有企业"},
      {:id => 40, :name => "私营企业"},
      {:id => 50, :name => "事业单位"},
      {:id => 60, :name => "政府机关"},
      {:id => 70, :name => "非营利机构"},
      {:id => 80, :name => "外企代表处"},
      {:id => 90, :name => "其他性质"}
    ]
  end
  
end
