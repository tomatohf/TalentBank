class College < HashModel::Grouped
  
  def self.data
    # {
    #   university_id => [
    #     {:id => college_id, :name => college_name}
    #   ]
    # }
    
    {
      100100 => [
        {:id => 100100, :name => "求职学院"},
        {:id => 100200, :name => "销售学院"}
      ],
      
      
      100200 => [
        {:id => 100300, :name => "经济管理学院"}
      ]
    }
  end
  
end
