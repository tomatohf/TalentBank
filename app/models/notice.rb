class Notice < ActiveRecord::Base
  
  validates_presence_of :type_id, :account_type_id, :account_id, :content
  
  
  def self.generate(account_type_id, account_id, type_name, locals = {})
    type = Type.find_by(:name, type_name)
    
    def self.template_binding(locals)
      eval(locals.keys.map { |key| "#{key} = locals[:#{key}];" }.join)
      binding
    end
    
    self.new(
      :account_type_id => account_type_id,
      :account_id => account_id,
      :type_id => type[:id],
      :content => ERB.new(type[:template]).result(template_binding(locals))
    ).save!
  end
  
  
  class Type < HashModel::Simple
    def self.data
      [
        {
          :id => 10, :name => "add_resume_comment", :label => "添加简历评注", :icon => "add_resume_comment.gif",
          :template => %Q{
            <%= h(account) %>在<%= resume %>的简历中添加了评注, <a href="<%= url %>" target="_blank">去简历修改模式中看看</a>
          }.strip
        }
      ]
    end
  end
  
end
