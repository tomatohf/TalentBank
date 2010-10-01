class JobPeriod < HashModel::Simple
  
  def self.data
    [
      {:id => 10, :name => "无限制"},
      {:id => 20, :name => "1个工作日"},
      {:id => 30, :name => "2个工作日"},
      {:id => 40, :name => "3个工作日"},
      {:id => 50, :name => "4个工作日"},
      {:id => 60, :name => "5个工作日"},
      {:id => 70, :name => "周末上班"}
    ]
  end
  
end
