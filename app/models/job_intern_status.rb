class JobInternStatus < HashModel::Simple
  
  def self.data
    [
      {:id => 60, :name => "start", :label => "正在匹配"},
      {:id => 70, :name => "finish", :label => "已经招满"},
      {:id => 80, :name => "delete", :label => "已经删除"}
    ]
  end
  
end
