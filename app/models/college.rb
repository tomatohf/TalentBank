class College < HashModel::Grouped
  
  def self.data
    # {
    #   school_abbr => [
    #     {:id => college_id, :name => college_name}
    #   ]
    # }
    
    {
      "qiaobutang" => [
        {:id => 100100, :name => "求职学院"},
        {:id => 100200, :name => "销售学院"}
      ],
      
      
      "shift" => [
        {:id => 100300, :name => "金融管理学院"},
        {:id => 100400, :name => "国际商务外语学院"}
      ]
    }
  end
  
end



class Major < HashModel::Grouped
  
  def self.data
    # {
    #   college_id => [
    #     {:id => major_id, :name => major_name}
    #   ]
    # }
    
    {
      100100 => [
        {:id => 100100, :name => "求职特训"}
      ],
      100200 => [
        {:id => 100200, :name => "销售技巧"}
      ],
      
      
      100300 => [
        {:id => 100300, :name => "金融学(国际银行业务方向)"},
        {:id => 100400, :name => "金融学(中加合作)"},
        {:id => 100500, :name => "财务管理(国际资产经营方向)"},
        {:id => 100600, :name => "财务管理(中加合作)"},
        {:id => 100700, :name => "金融工程"},
        {:id => 100800, :name => "保险和资产评估"}
      ],
      100400 => [
        {:id => 100900, :name => "商务英语专业"},
        {:id => 101000, :name => "新闻学"},
        {:id => 101100, :name => "法语"},
        {:id => 101200, :name => "日语"},
        {:id => 101300, :name => "对外汉语"}
      ]
    }
  end
  
end
