class JobsResultId < ActiveRecord::Migration
  def self.up
    
    add_column :jobs, :result_id, :integer, :limit => 2
    
  end

  def self.down
    
    remove_column :jobs, :result_id
    
  end
end
