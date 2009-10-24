class Skill < HashModel::Simple
  
  def self.data
    # [
    #   {:id => skill_id, :name => skill_name, :value_type => skill_value_type}
    # ]
    
    [
      {
        :id => 100100,
        :name => "CPA证书",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "通过"}
        ]
      },
      
      
      {
        :id => 100200,
        :name => "大学英语六级(CET6)",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "通过"},
          {:value => 20, :label => "优秀"}
        ]
      },
      
      
      {
        :id => 100300,
        :name => "上海计算机等级考试",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "1 级"},
          {:value => 20, :label => "2 级"},
          {:value => 30, :label => "3 级"}
        ]
      },
      
      
      {
        :id => 100400,
        :name => "乔布堂销售技能培训",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "毕业"}
        ]
      }
    ]
  end
  
end