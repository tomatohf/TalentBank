class JobGraduation < HashModel::Simple
  
  def self.data
    year = Schools::Base.instance.coming_graduation_year
    
    [
      {:id => 20, :name => "已毕业未就业 (#{year}年以前毕业)"},
      {:id => 30, :name => "应届毕业生 (#{year}年毕业)"},
      {:id => 40, :name => "在读学生 (#{year}年以后毕业)"}
    ]
  end
  
end
