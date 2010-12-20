class Notes < ActiveRecord::Migration
  def self.up
    
    create_table :teacher_notes, :force => true do |t|
      t.column :target_type_id, :integer, :limit => 2
      t.column :target_id, :integer
      
      t.column :teacher_id, :integer
      
      t.column :content, :string, :limit => 500
      
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :teacher_notes, [:target_type_id, :target_id, :created_at],
              :name => :index_teacher_notes_on_target_and_created_at
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO teacher_notes (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM teacher_notes WHERE id = 10000")
    
  end

  def self.down
    
    drop_table :teacher_notes
    
  end
end
