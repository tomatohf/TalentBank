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
