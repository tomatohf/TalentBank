class CorporationProfile < ActiveRecord::Base
  
  belongs_to :corporation, :class_name => "Corporation", :foreign_key => "corporation_id"
  
  
  attr_accessor :registering
  validates_presence_of :corporation_id, :unless => Proc.new { |profile| profile.registering == true }
  
  validates_presence_of :email, :message => "请输入 邮箱"
  validates_length_of :email, :maximum => 250, :message => "邮箱 超过长度限制", :allow_nil => false
  
  validates_presence_of :phone, :message => "请输入 联系电话"
  validates_length_of :phone, :maximum => 25, :message => "联系电话 超过长度限制", :allow_nil => false
  
  validates_presence_of :contact, :message => "请输入 联系人"
  validates_length_of :contact, :maximum => 15, :message => "联系人 超过长度限制", :allow_nil => false
  
  
  validates_length_of :contact_title, :maximum => 15, :message => "联系人职位 超过长度限制", :allow_nil => true
  
  
  validates_length_of :address, :maximum => 250, :message => "联系地址 超过长度限制", :allow_nil => true
  
  validates_length_of :zip, :maximum => 10, :message => "邮编 超过长度限制", :allow_nil => true
  
  validates_length_of :website, :maximum => 250, :message => "企业网站 超过长度限制", :allow_nil => true
  
  validates_length_of :desc, :maximum => 500, :message => "企业简介 超过长度限制", :allow_nil => true
  
  validates_length_of :business_scope, :maximum => 250, :message => "经营范围 超过长度限制", :allow_nil => true
  
  
  
  Belongs_To_Keys = [:corporation_id]
  include Utils::UniqueBelongs
  
  
  
  after_save { |profile|
    profile.corporation.renew_updated_at(profile.updated_at)
  }
  
end
