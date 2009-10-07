class StudentsIndex < ActiveRecord::Migration
  def self.up
    
    add_index :schools, :abbr, :unique => true
    
    add_index :teachers, [:school_id, :uid], :unique => true
    add_index :teachers, [:school_id, :created_at]
    
    add_index :students, [:school_id, :number], :unique => true
    
  end

  def self.down
    
    remove_index :students, [:school_id, :number]
    
    remove_index :teachers, [:school_id, :created_at]
    remove_index :teachers, [:school_id, :uid]
    
    remove_index :schools, :abbr
    
  end
end
