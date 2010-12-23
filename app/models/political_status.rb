class PoliticalStatus < HashModel::Simple
  
  def self.data
    # [
    #   {:id => political_status_id, :name => political_status_name}
    # ]
    
    [
      {:id => 30, :name => "群众"},
      {:id => 20, :name => "共青团员"},
      {:id => 50, :name => "预备党员"},
      {:id => 10, :name => "中共党员"},
      {:id => 40, :name => "民主党派"}
    ]
  end
  
end
