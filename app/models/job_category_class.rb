class JobCategoryClass < HashModel::Simple
  
  def self.data
    [
      {:id => 10, :name => "IT类"},
      {:id => 20, :name => "销售、客服、技术支持类"},
      {:id => 30, :name => "生产、营运、采购、物流类"},
      {:id => 40, :name => "研发类"},
      {:id => 50, :name => "财务类"},
      {:id => 60, :name => "人事、行政类"},
      {:id => 70, :name => "服务类"},
      {:id => 80, :name => "公务员、其他"}
    ]
  end
  
end
