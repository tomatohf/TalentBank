class JobResult < HashModel::Simple
  
  def self.data
    [
      {:id => 10, :name => "纯实习"},
      {:id => 20, :name => "可留任"},
      {:id => 30, :name => "兼职工作"},
      {:id => 40, :name => "正式入职"}
    ]
  end
  
end
