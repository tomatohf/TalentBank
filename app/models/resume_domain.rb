class ResumeDomain < HashModel::Simple
  
  def self.data
    # [
    #   {:id => resume_domain_id, :name => resume_domain_name, :category_id => resume_domain_category}
    # ]
    
    [
      # first 100 ids are reserved by general versions ...
      {:id => 10, :name => "不限方向", :category_id => 100},
      
      {:id => 110, :name => "销售", :category_id => 200},
      {:id => 120, :name => "市场", :category_id => 200},
      {:id => 130, :name => "客服", :category_id => 200},
      
      {:id => 140, :name => "软件工程师", :category_id => 300},
      {:id => 150, :name => "机械工程师", :category_id => 300},
      {:id => 160, :name => "网络工程师", :category_id => 300},
      {:id => 170, :name => "质量控制员", :category_id => 300},
      
      {:id => 180, :name => "财务", :category_id => 400},
      
      {:id => 190, :name => "助理", :category_id => 500},
      {:id => 200, :name => "HR", :category_id => 500}
    ]
  end
  
end
