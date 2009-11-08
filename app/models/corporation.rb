class Corporation < ActiveRecord::Base
  
  belongs_to :school, :class_name => "School", :foreign_key => "school_id"
  
  has_one :profile, :class_name => "CorporationProfile", :foreign_key => "corporation_id", :dependent => :destroy
  
  
  include Utils::Searchable
  
  define_index do
    
    indexes uid, name
    
    indexes profile.email, :as => :email
    indexes profile.phone, :as => :phone
    indexes profile.contact, :as => :contact
    indexes profile.address, :as => :address
    indexes profile.zip, :as => :zip
    indexes profile.website, :as => :website
    indexes profile.desc, :as => :desc
    
    
    has school_id, allow_query, updated_at
    
    has profile.nature_id, :as => :nature_id
    has profile.size_id, :as => :size_id
    has profile.industry_id, :as => :industry_id
    has profile.province_id, :as => :province_id
    
    
    set_property(
      :delta => DailyDelta,
      :column => :updated_at,
      # :rate => 70.minutes,
      :hour => Overall_Index_Hour,
      :minute => Overall_Index_Minute,
      :batch => 100
    )
    
  end
  
  
  attr_accessor :registering
  validates_presence_of :school_id, :unless => Proc.new { |corp| corp.registering == true }
  
  validates_presence_of :uid, :message => "请输入 用户名"
  validates_presence_of :password, :message => "请输入 密码"
  
  validates_length_of :uid, :maximum => 25, :message => "用户名 超过长度限制", :allow_nil => false
  
  validates_length_of :name, :maximum => 50, :message => "企业名称 超过长度限制", :allow_nil => true
  
  validates_uniqueness_of :uid, :case_sensitive => false, :scope => :school_id, :message => "用户名 已经存在"
  
  attr_accessor :password_confirmation
  validates_confirmation_of :password, :message => "密码 与 确认密码 不相同"
  
  
  named_scope :allow_query, :conditions => { :allow_query => true }
  
  
  include Utils::NotDeletable
  
  
  def self.authenticate(abbr, uid, pwd)
    corp = self.get_from_uid(abbr, uid)
    corp = nil if corp && (corp.password != pwd)
    corp
  end
  
  def self.get_from_uid(abbr, uid)
    self.find(:first, :conditions => ["school_id = ? and uid = ?", School.get_school_info(abbr)[0], uid])
  end
  
  
  def self.school_search(keyword, school_id, page = 1, per_page = 10, options = {})
    filters = {:school_id => school_id}
    filters.merge!(:allow_query => options[:allow_query]) unless options[:allow_query].nil?
    [:nature_id, :size_id, :industry_id, :province_id].each do |filter_key|
      filter_value = options[filter_key]
      filters.merge!(filter_key => filter_value) unless filter_value.blank?
    end
    
    self.search(
      keyword,
      :page => page,
      :per_page => per_page,
      :match_mode => Search_Match_Mode,
      :order => "@relevance DESC, updated_at DESC",
      :field_weights => {},
      :with => filters
    )
  end
  
  
  def name?
    !self.name.blank?
  end
  
end
