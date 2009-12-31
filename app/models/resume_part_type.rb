class ResumePartType < HashModel::Simple
  
  def self.data
    # [
    #   {:id => part_type_id, :name => part_type_name}
    # ]
    
    [
      {:id => 10, :name => "job_intention", :label => "求职意向", :model => ResumeJobIntention},
      {:id => 20, :name => "edu", :label => "教育经历", :model => EduExp},
      {:id => 30, :name => "exp_section", :label => "经历块", :model => ResumeExpSection},
      {:id => 40, :name => "student_exp", :label => "经历", :model => StudentExp},
      {:id => 50, :name => "resume_exp", :label => "经历", :model => ResumeExp},
      {:id => 60, :name => "student_skill", :label => "技能和证书", :model => StudentSkill},
      {:id => 70, :name => "resume_skill", :label => "技能和证书", :model => ResumeListSkill},
      {:id => 80, :name => "award", :label => "荣誉和奖励", :model => ResumeAward},
      {:id => 90, :name => "hobby", :label => "特长和爱好", :model => ResumeHobby},
      {:id => 100, :name => "list_section", :label => "附加信息", :model => ResumeListSection}
    ]
  end
  
end
