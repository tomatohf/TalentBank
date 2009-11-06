class StudentProfileCopies < ActiveRecord::Migration
  def self.up
    
    create_table :student_profile_copies, :force => true do |t|
      t.column :student_id, :integer
      
      t.column :phone, :string, :limit => 25
      t.column :email, :string
      
      t.column :address, :string
      t.column :zip, :string, :limit => 10
      
      t.column :gender, :boolean
      t.column :political_status_id, :integer, :limit => 2
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :student_profile_copies, :student_id, :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO student_profile_copies (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM student_profile_copies WHERE id = 10000")
    
  end

  def self.down
    
    drop_table :student_profile_copies
    
  end
end
