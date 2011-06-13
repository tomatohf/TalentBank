class StudentImports < ActiveRecord::Migration
  def self.up
    
    create_table :student_imports, :force => true do |t|
      t.column :school_id, :integer
      t.column :teacher_id, :integer
      
      t.column :data, :text
      t.column :saved, :text
      t.column :failed, :text
      
      t.column :updated_at, :datetime
    end
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO student_imports (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM student_imports WHERE id = 10000")
    
  end

  def self.down
    
    drop_table :student_imports
    
  end
end
