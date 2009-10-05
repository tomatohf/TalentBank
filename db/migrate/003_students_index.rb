class StudentsIndex < ActiveRecord::Migration
  def self.up
    
    add_index :students, [:school_id, :number], :unique => true
    add_index :students, [:school_id, :created_at]
    
    add_index :teachers, [:school_id, :uid], :unique => true
    add_index :teachers, [:school_id, :created_at]

  end

  def self.down
    
    remove_index :teachers, [:school_id, :created_at]
    remove_index :teachers, [:school_id, :uid]
    
    remove_index :students, [:school_id, :created_at]
    remove_index :students, [:school_id, :number]
    
  end
end
