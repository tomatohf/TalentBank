class StudentsComplete < ActiveRecord::Migration
  def self.up
    
    add_column :students, :complete, :boolean, :default => false
    
  end

  def self.down
    
    remove_column :students, :complete
    
  end
end
