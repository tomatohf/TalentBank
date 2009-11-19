class Statistics < ActiveRecord::Migration
  def self.up
    
    add_column :teachers, :statistic, :boolean, :default => false
    
  end

  def self.down
    
    remove_column :teachers, :statistic
    
  end
end
