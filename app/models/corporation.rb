class Corporation < ActiveRecord::Base
  
  belongs_to :school, :class_name => "School", :foreign_key => "school_id"
  
  has_one :profile, :class_name => "CorporationProfile", :foreign_key => "corporation_id", :dependent => :destroy
  
  
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
  
  
  def name?
    !self.name.blank?
  end
  
end
