class ResumeExpTag < HashModel::Grouped
  
  def self.data
    # {
    #   resume_domain_id => [
    #     {:id => resume_exp_tag_id, :name => resume_exp_tag_name}
    #   ]
    # }
    
    {
      110 => [
        {:id => 100100, :name => "沟通"},
        {:id => 100200, :name => "说服"}
      ],
      
      120 => [
        {:id => 100300, :name => "团队协作"},
        {:id => 100400, :name => "解决问题"}
      ]
    }
  end
  
end
