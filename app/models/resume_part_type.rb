class ResumePartType < HashModel::Simple
  
  def self.data
    # [
    #   {:id => part_type_id, :name => part_type_name}
    # ]
    
    [
      {:id => 10, :name => "job_intention"},
      {:id => 20, :name => "edu"},
      {:id => 30, :name => "exp_section"},
      {:id => 40, :name => "student_exp"},
      {:id => 50, :name => "resume_exp"}
    ]
  end
  
end
