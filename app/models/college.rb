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
      
      
      "shou" => [
        {:id => 100300, :name => "经济管理学院"}
      ]
    }
  end
  
end
