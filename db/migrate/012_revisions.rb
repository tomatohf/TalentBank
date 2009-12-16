class Revisions < ActiveRecord::Migration
  def self.up
    
    add_column :teachers, :resume, :boolean, :default => true
    add_column :teachers, :revision, :boolean, :default => false
    add_index :teachers, [:school_id, :revision]
    
  end

  def self.down
    
    remove_index :teachers, [:school_id, :revision]
    remove_column :teachers, :revision
    remove_column :teachers, :resume
    
  end
end
