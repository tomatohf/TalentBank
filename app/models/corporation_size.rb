class CorporationSize < HashModel::Simple
  
  def self.data
    # [
    #   {:id => size_id, :name => size_name}
    # ]
    
    [
      {:id => 10, :name => "5人以下"},
      {:id => 20, :name => "5-10人"},
      {:id => 30, :name => "11-50人"},
      {:id => 40, :name => "51-100人"},
      {:id => 50, :name => "101-500人"},
      {:id => 60, :name => "501-1000人"},
      {:id => 70, :name => "1000人以上"}
    ]
  end
  
end
