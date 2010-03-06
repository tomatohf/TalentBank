class School < ActiveRecord::Base
  
  acts_as_trashable
  
  
  validates_presence_of :abbr, :message => "请输入 英文缩写"
  validates_presence_of :password, :message => "请输入 密码"
  
  validates_length_of :abbr, :maximum => 15, :message => "英文缩写 超过长度限制", :allow_nil => false
  
  validates_uniqueness_of :abbr, :case_sensitive => false, :message => "英文缩写 已经存在"
  
  attr_accessor :password_confirmation
  validates_confirmation_of :password, :message => "密码 与 确认密码 不相同"
  
  
  
  include Utils::NotDeletable
  
  after_save { |school|
    self.set_school_info_cache(school.abbr, school)
  }
  
  
  
  def self.authenticate(abbr, uid, pwd)
    return nil unless abbr == uid
    
    s = self.get_from_abbr(abbr)
    s = nil if s && s.password != pwd
    s
  end
  
  def self.get_from_abbr(abbr)
    self.find(:first, :conditions => ["abbr = ?", abbr])
  end
  
  
  CKP_info = "school_info"
  
  def self.school_info_key(abbr)
    "#{CKP_info}_#{abbr}"
  end
  
  def self.get_school_info(abbr)
    school_info = Rails.cache.read(self.school_info_key(abbr))
    
    unless school_info
      school = self.get_from_abbr(abbr)
      school_info = self.set_school_info_cache(abbr, school)
    end
    
    school_info
  end
  
  def self.set_school_info_cache(abbr, school)
    school_info = [school.id, school.abbr, school.active]
    Rails.cache.write(self.school_info_key(abbr), school_info, :expires_in => Cache_TTL[:never])
    school_info
  end
  
  def self.clear_school_info_cache(abbr)
    Rails.cache.delete(self.school_info_key(abbr))
  end
  
end