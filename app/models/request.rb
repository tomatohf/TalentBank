class Request < ActiveRecord::Base
  
  validates_presence_of :account_type_id, :account_id, :requester_type_id, :requester_id, :type_id
  
  
  include Utils::FieldHashable
  hash_field :data
  
  
  after_save { |request|
    self.clear_type_counts_cache(AccountType.find(request.account_type_id)[:name], request.account_id)
  }
  after_destroy { |request|
    self.clear_type_counts_cache(AccountType.find(request.account_type_id)[:name], request.account_id)
  }
  
  
  def self.requests_of_reference(account_type_name, account_id, type_name, reference_id, is_requester)
    account_key = is_requester ? "requester" : "account"
    
    self.paginate(
      :page => 1,
      :per_page => 3,
      :conditions => [
        "#{account_key}_type_id = ? and #{account_key}_id = ? and type_id = ? and reference_id = ?",
        AccountType.find_by(:name, account_type_name)[:id], account_id,
        Type.find_by(:name, type_name)[:id], reference_id
      ]
    )
  end
  
  
  CKP_type_counts = "request_type_counts"
  def self.count_by_type(account_type_name, account_id)
    counts = Rails.cache.read(self.type_counts_key(account_type_name, account_id))
    
    unless counts
      counts = self.set_type_counts_cache(
        account_type_name, account_id,
        self.count(
          :conditions => [
            "account_type_id = ? and account_id = ?",
            AccountType.find_by(:name, account_type_name)[:id], account_id
          ],
          :group => "type_id"
        )
      )
    end
    
    counts
  end
  
  def self.type_counts_key(account_type_name, account_id)
    "#{CKP_type_counts}_#{account_type_name}_#{account_id}"
  end
  def self.set_type_counts_cache(account_type_name, account_id, counts)
    Rails.cache.write(
      self.type_counts_key(account_type_name, account_id),
      counts,
      :expires_in => Cache_TTL[:long]
    )
    counts
  end
  def self.clear_type_counts_cache(account_type_name, account_id)
    Rails.cache.delete(self.type_counts_key(account_type_name, account_id))
  end
  
  
  def self.count_sent_by_type(requester_type_name, requester_id)
    self.count(
      :conditions => [
        "requester_type_id = ? and requester_id = ?",
        AccountType.find_by(:name, requester_type_name)[:id], requester_id
      ],
      :group => "type_id"
    )
  end
  
  
  def self.generate(account_type_name, account, type_name, options = {})
    type = Type.find_by(:name, type_name)
    
    TypeAdapter.new(type[:name]).generate(
      AccountType.find_by(:name, account_type_name), account, type,
      options
    )
  end
  
  
  def accept(options = {})
    adapter = TypeAdapter.new(Type.find(self.type_id)[:name])
    
    adapter.accept(self, options)
    adapter.reference_url(self, false)
  end
  
  
  class Type < HashModel::Simple
    def self.data
      [
        {
          :id => 10, :name => "revise_resume", :icon => "revise_resume.gif",
          :label => "修改简历", :accept_label => "现在就去修改"
        }
      ]
    end
  end
  
  
  class TypeAdapter
    def initialize(type_name)
      extend(instance_eval(type_name.camelize))
    end
    
    def generate(account_type, account, type, options = {})
      raise "Not Implemented"
    end
    
    def accept(request, options = {})
      # do nothing ...
    end
    
    def reference_url(request, is_requester)
      ""
    end
  end
  
  
  module ReviseResume
    def generate(account_type, account, type, options = {})
      return false unless account_type[:name] == "students"

      teacher = Teacher.find(options[:teacher])
      return false unless teacher.school_id == account.school_id
      
      resume = Resume.find(options[:resume])
      return false unless resume.student_id == account.id

      request = Request.new(
        :account_type_id => AccountType.find_by(:name, "teachers")[:id],
        :account_id => teacher.id,
        :requester_type_id => account_type[:id],
        :requester_id => account.id,
        :type_id => type[:id],
        :reference_id => resume.id
      )
      request.fill_data(:resume => "#{ResumeDomain.find(resume.domain_id)[:name]}的简历")

      request.save!

      [request, {"teachers" => {teacher.id => teacher}}]
    end
    
    
    def reference_url(request, is_requester)
      account_key = is_requester ? "requester" : "account"
      account_type = AccountType.find(request.send("#{account_key}_type_id"))
      "/#{account_type[:name]}/#{request.send(account_key+"_id")}/revise_resumes/#{request.reference_id}"
    end
  end
  
end
