class ResumesIndexForSphinx < ActiveRecord::Migration
  def self.up
    
    add_index :resumes, :updated_at
    
  end

  def self.down
    
    remove_index :resumes, :updated_at
    
  end
end
