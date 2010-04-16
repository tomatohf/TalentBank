# The skill id and skill data will be concated to the skill_values,
# which will be used as attribute for filtering in sphinx.
# So the skill id (which starts with 100100, step 100) should NOT be larger than ***6 numbers***,
# and the skill data (which starts with 0, step 10) should NOT be larger than ***3 numbers***

class Skill < HashModel::Simple
  
  def self.data
    # [
    #   {:id => skill_id, :name => skill_name, :value_type => skill_value_type}
    # ]
    
    [
      {
        :id => 100100,
        :name => "大学英语四级(CET4)",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "通过"},
          {:value => 20, :label => "优秀"}
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
        :name => "专业英语四级(TEM4)",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "通过"},
          {:value => 20, :label => "优秀"}
        ]
      },
      
      
      {
        :id => 100400,
        :name => "专业英语八级(TEM8)",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "通过"},
          {:value => 20, :label => "优秀"}
        ]
      },
      
      
      {
        :id => 100500,
        :name => "全国计算机等级证书",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "一级"},
          {:value => 20, :label => "二级"},
          {:value => 30, :label => "三级"},
          {:value => 40, :label => "四级"}
        ]
      },
      
      
      {
        :id => 100600,
        :name => "计算机技术与软件专业技术资格",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "初级"},
          {:value => 20, :label => "中级"},
          {:value => 30, :label => "高级"}
        ]
      },
      
      
      {
        :id => 100700,
        :name => "日本语能力测试(JLPT)",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "四级"},
          {:value => 20, :label => "三级"},
          {:value => 30, :label => "二级"},
          {:value => 40, :label => "一级"}
        ]
      },
      
      
      {
        :id => 100800,
        :name => "证券从业资格",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "通过"},
          {:value => 20, :label => "一级"},
          {:value => 30, :label => "二级"}
        ]
      },
      
      
      {
        :id => 100900,
        :name => "注册国际投资分析师(CIIA)",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "通过"}
        ]
      },
      
      
      {
        :id => 101000,
        :name => "特许金融分析师(CFA)",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "初级"},
          {:value => 20, :label => "中级"},
          {:value => 30, :label => "高级"}
        ]
      },
      
      
      {
        :id => 101100,
        :name => "报关员资格证书",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "通过"}
        ]
      },
      
      
      {
        :id => 101200,
        :name => "注册会计师(CPA)",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "通过"}
        ]
      },
      
      
      {
        :id => 101300,
        :name => "物流师职业资格认证",
        :value_type => "level",
        :data => [
          {:value => 0, :label => ""},
          {:value => 10, :label => "助理物流师"},
          {:value => 20, :label => "物流师"},
          {:value => 30, :label => "高级物流师"}
        ]
      },
    ]
  end
  
end
