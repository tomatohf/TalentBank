class Notice < ActiveRecord::Base
  
  validates_presence_of :type_id, :account_type_id, :account_id, :content
  
  
  after_save { |notice|
    self.clear_unread_count_cache(AccountType.find(notice.account_type_id)[:name], notice.account_id)
  }
  after_destroy { |notice|
    self.clear_unread_count_cache(AccountType.find(notice.account_type_id)[:name], notice.account_id)
  }
  
  
  CKP_unread_count = "notice_unread_count"
  def self.count_unread(account_type_name, account_id)
    count = Rails.cache.read(self.unread_count_key(account_type_name, account_id))
    
    unless count
      count = self.set_unread_count_cache(
        account_type_name, account_id,
        self.count(
          :conditions => [
            "account_type_id = ? and account_id = ? and unread = ?",
            AccountType.find_by(:name, account_type_name)[:id], account_id, true
          ]
        )
      )
    end
    
    count
  end
  
  def self.unread_count_key(account_type_name, account_id)
    "#{CKP_unread_count}_#{account_type_name}_#{account_id}"
  end
  def self.set_unread_count_cache(account_type_name, account_id, count)
    Rails.cache.write(
      self.unread_count_key(account_type_name, account_id),
      count,
      :expires_in => Cache_TTL[:long]
    )
    count
  end
  def self.clear_unread_count_cache(account_type_name, account_id)
    Rails.cache.delete(self.unread_count_key(account_type_name, account_id))
  end
  
  
  def self.generate(account_type, account_id, type_name, locals = {})
    type = Type.find_by(:name, type_name)
    account_type_id = AccountType.find_by(:name, account_type)[:id]
    
    def self.template_binding(locals)
      eval(locals.keys.map { |key| "#{key} = locals[:#{key}];" }.join)
      binding
    end
    
    content = ERB.new(type[:template]).result(template_binding(locals))
    
    # avoid generate repeat notices with same content
    self.find(
      :all,
      :conditions => [
        "account_type_id = ? and account_id = ? and unread = ? and updated_at > ?",
        account_type_id, account_id, true, 10.minutes.ago
      ]
    ).each do |n|
      return false if n.content == content
    end
    
    self.create!(
      :account_type_id => account_type_id,
      :account_id => account_id,
      :type_id => type[:id],
      :content => content
    )
  end
  
  
  class Type < HashModel::Simple
    def self.data
      [
        {
          :id => 10, :name => "add_resume_comment", :label => "添加简历评注", :icon => "add_resume_comment.gif",
          :template => %Q{
            <%= h(account) %>在<%= resume %>中添加了评注, <a href="<%= url %>" target="_blank">去简历修改模式中看看</a>
          }.strip
        },
        
        {
          :id => 20, :name => "add_resume_revision", :label => "添加简历修改意见", :icon => "add_resume_revision.gif",
          :template => %Q{
            <%= h(teacher) %>在<%= resume %>中添加了修改意见, <a href="<%= url %>" target="_blank">去简历修改模式中看看</a>
          }.strip
        }
      ]
    end
  end
  
end
