class CorporationInternStatus < HashModel::Simple
  
  def self.data
    [
      {:id => 60, :name => "start", :label => "正在匹配"},
      {:id => 70, :name => "delay", :label => "之后联系"},
      {:id => 80, :name => "unreach", :label => "联系不上"},
      {:id => 90, :name => "finish", :label => "已经招满"}
    ]
  end
  
end
