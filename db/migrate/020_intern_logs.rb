class InternLogs < ActiveRecord::Migration
  def self.up
    
    create_table :intern_logs, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :teacher_id, :integer
      
      t.column :job_id, :integer
      t.column :event_id, :integer, :limit => 2
      t.column :result_id, :integer, :limit => 2
      t.column :occur_at, :datetime
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :intern_logs, [:student_id, :occur_at]
    add_index :intern_logs, :updated_at
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO intern_logs (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM intern_logs WHERE id = 10000")
    
  end

  def self.down
    
    drop_table :intern_logs
    
  end
end
