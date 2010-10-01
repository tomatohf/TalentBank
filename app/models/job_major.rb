class JobMajor < HashModel::Simple
  
  def self.data
    [
      {:id => 10, :name => "经济管理"},
      {:id => 20, :name => "电子信息、软件"},
      {:id => 30, :name => "机械制造"},
      {:id => 40, :name => "船舶海洋、建筑工程"},
      {:id => 50, :name => "生物、化工、医药"},
      {:id => 60, :name => "基础科学类（数学、物理、化学）"},
      {:id => 70, :name => "新闻、媒体设计、人文（文史哲）"},
      {:id => 80, :name => "法律"}
    ]
  end
  
end
