class ResumePartType < HashModel::Simple
  
  def self.data
    # [
    #   {:id => part_type_id, :name => part_type_name}
    # ]
    
    [
      {:id => 10, :name => "exp_section"},
      {:id => 20, :name => "exp"}
    ]
  end
  
end
