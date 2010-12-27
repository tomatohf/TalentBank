class IndustryCategory < HashModel::Simple
  
  def self.data
    [
      {:id => 10, :name => "计算机/互联网/通信/电子"},
      {:id => 20, :name => "会计/金融/银行/保险"},
      {:id => 30, :name => "贸易/消费/制造/营运"},
      {:id => 40, :name => "制药/医疗"},
      {:id => 50, :name => "广告/媒体"},
      {:id => 60, :name => "房地产/建筑"},
      {:id => 70, :name => "专业服务/教育/培训"},
      {:id => 80, :name => "服务业"},
      {:id => 90, :name => "物流/运输"},
      {:id => 100, :name => "能源/原材料"},
      {:id => 110, :name => "政府/非营利机构/其他"}
    ]
  end
  
end
