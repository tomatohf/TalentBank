class ResumeExpTag < HashModel::Grouped
  
  def self.data
    # {
    #   resume_domain_id => [
    #     {:id => resume_exp_tag_id, :name => resume_exp_tag_name}
    #   ]
    # }
    
    {
      10 => [
        {:id => 100100, :name => "学习能力"},
        {:id => 100200, :name => "创新能力"},
        {:id => 100300, :name => "团队协作"},
        {:id => 100400, :name => "领导能力"},
        {:id => 100500, :name => "沟通能力"},
        {:id => 100600, :name => "适应环境"}
      ],
      
      110 => [
        {:id => 100700, :name => "沟通"},
        {:id => 100800, :name => "说服"}
      ]
    }
  end
  
end
