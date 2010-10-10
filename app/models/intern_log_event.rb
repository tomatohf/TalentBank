class InternLogEvent < HashModel::Simple
  
  def self.data
    [
      {:id => 10, :name => "通知面试"},
      {:id => 20, :name => "面试结果"},
      {:id => 30, :name => "实习结束"}
    ]
  end
  
  
  def self.inform_interview
    self.find(10)
  end
  
end
