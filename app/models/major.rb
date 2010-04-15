class Major < HashModel::Grouped
  
  def self.data
    # {
    #   college_id => [
    #     {:id => major_id, :name => major_name}
    #   ]
    # }
    
    {
      100100 => [
        {:id => 100100, :name => "求职特训"},
        {:id => 101400, :name => "简历特训"},
        {:id => 101500, :name => "面试特训"}
      ],
      100200 => [
        {:id => 100200, :name => "销售技巧"},
        {:id => 101600, :name => "拜访技巧"},
        {:id => 101700, :name => "形象和礼仪"}
      ],
      
      
      100300 => [
        {:id => 100300, :name => "农林经济管理系"},
        {:id => 100400, :name => "会计系"},
        {:id => 100500, :name => "金融学系"},
        {:id => 100600, :name => "国际经济与贸易系"},
        {:id => 100700, :name => "市场营销系"},
        {:id => 100800, :name => "物流系"}
      ]
    }
  end
  
end
