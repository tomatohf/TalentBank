class Request < ActiveRecord::Base
  
  validates_presence_of :account_type_id, :account_id, :requester_type_id, :requester_id, :type_id
  
  
  include Utils::FieldHashable
  hash_field :data
  
  
  def requests_of_target
    
  end
  
  
  def self.generate(account_type_name, account, type_name, options = {})
    type = Type.find_by(:name, type_name)
    
    TypeAdapter.new(type[:name]).generate(
      AccountType.find_by(:name, account_type_name), account, type,
      options
    )
  end
  
  
  class Type < HashModel::Simple
    def self.data
      [
        {:id => 10, :name => "revise_resume", :label => "修改简历", :icon => "revise_resume.gif"}
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
  end
  
end
