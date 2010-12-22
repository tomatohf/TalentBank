class CorporationsTeacherId < ActiveRecord::Migration
  def self.up
    
    add_column :corporations, :teacher_id, :integer
    
  end

  def self.down
    
    remove_column :corporations, :teacher_id
    
  end
end
