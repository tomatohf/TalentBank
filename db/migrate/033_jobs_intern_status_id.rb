class JobsInternStatusId < ActiveRecord::Migration
  def self.up
    
    add_column :jobs, :intern_status_id, :integer, :limit => 2
    
  end

  def self.down
    
    remove_column :jobs, :intern_status_id
    
  end
end
