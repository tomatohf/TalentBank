class JobPeriod < HashModel::Simple
  
  def self.data
    [
      {:id => 10, :name => "一个月以内"},
      {:id => 20, :name => "一个月"},
      {:id => 30, :name => "二个月"},
      {:id => 40, :name => "三个月"},
      {:id => 50, :name => "四个月"},
      {:id => 60, :name => "五个月"},
      {:id => 70, :name => "六个月"},
      {:id => 80, :name => "六个月以上"}
    ]
  end
  
end
