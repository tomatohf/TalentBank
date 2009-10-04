class School < ActiveRecord::Base
  
  validates_presence_of :abbr, :message => "请输入 英文缩写"
  validates_presence_of :name, :message => "请输入 名称"
  validates_presence_of :password, :message => "请输入 密码"
  
  validates_length_of :abbr, :maximum => 15, :message => "英文缩写 超过长度限制", :allow_nil => false
  validates_length_of :name, :maximum => 50, :message => "名称 超过长度限制", :allow_nil => false
  
  validates_uniqueness_of :abbr, :case_sensitive => false, :message => "英文缩写 已经存在"
  
  attr_accessor :password_confirmation
  validates_confirmation_of :password, :message => "密码 与 确认密码 不相同"
  
  
  
  after_save { |school|
    self.clear_post_cache(post.id)
    
    self.clear_posts_group_feed_cache(post.group_id)
    
    PointProfile.adjust_account_points_by_action(post.account_id, :add_post, false)
    # should also think about to decrease good post points, if it's good post
  }
  
  after_destroy { |post|
    if post.good_changed?
      PointProfile.adjust_account_points_by_action(post.account_id, :add_post_to_good, post.good)
    end
    
    # clear changed attributes, before we cache it ...
    post.clean_myself
    self.set_post_cache(post.id, post)
    
    self.clear_posts_group_feed_cache(post.group_id)
  }
  
  
  
  def self.authenticate(abbr, pwd)
    s = self.get_from_abbr(abbr)
    s = nil if s && s.password != pwd
    s
  end
  
  def self.get_from_abbr(abbr)
    self.find(:first, :conditions => ["abbr = ?", abbr])
  end
  
  
  CKP_school_info = :school_info
  
  def self.school_info_key(abbr)
    "#{CKP_school_info}_#{abbr}".to_sym
  end
  
  def self.get_school_info(abbr)
    s = Cache.get(self.school_info_key(abbr))
    
    unless s
      s = self.get_from_abbr(abbr)
      
      self.set_school_info_cache(abbr, s)
    end
    s
  end
  
  def self.set_school_info_cache(abbr, school)
    Cache.set(self.school_info_key(abbr), [school.id, school.abbr], Cache_TTL)
  end
  
  def self.clear_school_info_cache(abbr)
    Cache.delete(self.school_info_key(abbr))
  end
  
end