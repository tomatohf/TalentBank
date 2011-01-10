class Corporations < ActiveRecord::Migration
  def self.up
    
    create_table :corporations, :force => true do |t|
      t.column :uid, :string, :limit => 25
      t.column :password, :string
      t.column :active, :boolean, :default => true
      
      t.column :school_id, :integer
      
      t.column :allow_query, :boolean, :default => false
      
      t.column :name, :string, :limit => 50
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :corporations, [:school_id, :uid], :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO corporations (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM corporations WHERE id = 10000")
    
    
    create_table :corporation_profiles, :force => true do |t|
      t.column :corporation_id, :integer
      
      t.column :email, :string
      t.column :phone, :string
      t.column :contact, :string, :limit => 100
      t.column :contact_gender, :boolean
      t.column :contact_title, :string, :limit => 15
      t.column :address, :string
      t.column :zip, :string, :limit => 10
      t.column :website, :string
      
      t.column :nature_id, :integer, :limit => 2
      t.column :size_id, :integer, :limit => 2
      t.column :industry_id, :integer, :limit => 2
      t.column :province_id, :integer, :limit => 2
      t.column :city_id, :integer, :limit => 2
      
      t.column :desc, :string, :limit => 1000
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :corporation_profiles, :corporation_id, :unique => true
    # reserve first 10000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO corporation_profiles (id) VALUES (10000)")
    ActiveRecord::Base.connection.execute("DELETE FROM corporation_profiles WHERE id = 10000")

  end

  def self.down
    
    drop_table :corporation_profiles
    
    drop_table :corporations
    
  end
end
