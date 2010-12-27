class JobsGender < ActiveRecord::Migration
  def self.up
    
    add_column :jobs, :gender, :boolean
    
  end

  def self.down
    
    remove_column :jobs, :gender
    
  end
end
