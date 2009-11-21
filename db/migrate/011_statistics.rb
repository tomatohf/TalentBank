class Statistics < ActiveRecord::Migration
  def self.up
    
    add_column :teachers, :statistic, :boolean, :default => false
    
    
    add_index :corp_queries, :updated_at
    add_index :corp_viewed_resumes, :updated_at
    
  end

  def self.down
    
    remove_index :corp_viewed_resumes, :updated_at
    remove_index :corp_queries, :updated_at
    
    
    remove_column :teachers, :statistic
    
  end
end
