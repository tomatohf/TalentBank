class InternLogEventResult < HashModel::Grouped
  
  def self.data
    {
      10 => [
        {:id => 10, :name => "接受", :intern_status => :interview},
        {:id => 20, :name => "拒绝", :intern_status => :unemployed}
      ],
      
      20 => [
        {:id => 30, :name => "通过", :intern_status => :intern},
        {:id => 40, :name => "失败", :intern_status => :unemployed},
        {:id => 50, :name => "没去", :intern_status => :unemployed}
      ],
      
      30 => [
        {:id => 60, :name => "到期", :intern_status => :unemployed},
        {:id => 70, :name => "留用", :intern_status => :employed},
        {:id => 80, :name => "流动", :intern_status => :unemployed},
        {:id => 90, :name => "劝退", :intern_status => :unemployed}
      ]
    }
  end
  
  
  
  def self.determine_intern_status(event_id, result_id)
    result = self.find(event_id, result_id)
    result && result[:intern_status]
  end
  
  
  def self.find_by_intern_status(status_key)
    (self.data.values || []).flatten.select { |result| result[:intern_status] == status_key }
  end
  
  
  def self.inform_interview_accepted
    self.find(10, 10)
  end
  
  def self.interview_result_passed
    self.find(20, 30)
  end
  
  def self.intern_end_employed
    self.find(30, 70)
  end
  
  def self.intern_end_leave
    self.find(30, 80)
  end
  
  def self.intern_end_fire
    self.find(30, 90)
  end
  
end
