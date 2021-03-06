class ResumesIndexForSphinx < ActiveRecord::Migration
  def self.up
    
    add_index :resumes, :updated_at
    
    add_index :resume_student_exps, :exp_id
    
    add_index :resume_skills, [:student_skill_id, :resume_id]
    
    
    add_index :corporations, :updated_at
    
  end

  def self.down
    
    remove_index :corporations, :updated_at
    
    
    remove_index :resume_skills, [:student_skill_id, :resume_id]
    
    remove_index :resume_student_exps, :exp_id
    
    remove_index :resumes, :updated_at
    
  end
end
