class CorporationsJobDistrict < ActiveRecord::Migration
  def self.up
    
    add_column :corporation_profiles, :job_district_id, :integer, :limit => 2
    
  end

  def self.down
    
    remove_column :corporation_profiles, :job_district_id
    
  end
end
