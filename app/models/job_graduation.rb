class JobGraduation < HashModel::Simple
  
  def self.data
    year = Schools::Base.instance.coming_graduation_year
    
    [
      {:id => 20, :name => "已经毕业 (#{year}年以前毕业)"},
      {:id => 30, :name => "应届毕业 (#{year}年毕业)"},
      {:id => 40, :name => "在读学生 (#{year}年以后毕业)"}
    ]
  end
  
  
  def self.get_graduation_year_range(graduation_id)
    year = Schools::Base.instance.coming_graduation_year
    
    case graduation_id
    when 20
      2006 .. year
    when 30
      year
    when 40
      year .. (year + 10)
    else
      raise "Invalid Job Graduation Id"
    end
  end
  
end
