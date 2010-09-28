class CorporationsIndustry < ActiveRecord::Migration
  def self.up
    
    add_column :corporation_profiles, :industry_category_id, :integer, :limit => 2
    
    add_column :corporation_profiles, :business_scope, :string
    
  end

  def self.down
    
    remove_column :corporation_profiles, :business_scope
    
    remove_column :corporation_profiles, :industry_category_id
    
  end
end
