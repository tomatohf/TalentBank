class CorporationsNameIndex < ActiveRecord::Migration
  def self.up
    
    add_index :corporations, [:school_id, :name], :unique => true
    
  end

  def self.down
    
    remove_index :corporations, [:school_id, :name]
    
  end
end
