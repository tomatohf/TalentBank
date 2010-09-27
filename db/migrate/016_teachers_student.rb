class TeachersStudent < ActiveRecord::Migration
  def self.up
    
    add_column :teachers, :student, :boolean, :default => false
    
    add_index :students, [:school_id, :created_at]
    add_index :students, :updated_at
    
  end

  def self.down
    
    remove_index :students, :updated_at
    remove_index :students, [:school_id, :created_at]
    
    remove_column :teachers, :student
    
  end
end
