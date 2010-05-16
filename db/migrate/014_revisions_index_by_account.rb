class RevisionsIndexByAccount < ActiveRecord::Migration
  def self.up
    
    add_index :resume_revisions, [:teacher_id, :created_at]
    
    add_index :resume_comments, [:account_type_id, :account_id, :created_at],
              :name => :index_resume_comments_on_account_and_created_at
    
  end

  def self.down
    
    remove_index :resume_comments, :name => :index_resume_comments_on_account_and_created_at
    
    remove_index :resume_revisions, [:teacher_id, :created_at]
    
  end
end
