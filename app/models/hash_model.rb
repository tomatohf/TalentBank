module HashModel
  
  class Base
    def self.data
      nil
    end
    
    def self.select_one(array, field, value)
      (array || []).detect do |record|
        record[field] == value
      end
    end
  end
  
  
  class Simple < Base
    def self.find(id)
      self.find_by(:id, id)
    end
    
    def self.find_by(field, value)
      self.select_one(self.data, field, value)
    end
    
    def self.data
      [
        # {id => 10000, attr1 => value1, attr2 => value2, ...}
      ]
    end
  end
  
  
  class Grouped < Base
    def self.find(group_id, id)
      self.find_by(group_id, :id, id)
    end
    
    def self.find_by(group_id, field, value)
      self.select_one(self.data[group_id], field, value)
    end
    
    def self.find_by_id(id)
      self.select_one(self.data.values.flatten, :id, id)
    end
    
    def self.find_group(group_id)
      self.data[group_id] || []
    end
    
    def self.get_group_id(id)
      self.data.keys.detect { |key|
        self.find(key, id)
      }
    end
    
    def self.data
      {
        # group_id => [
        #   {id => 10000, attr1 => value1, attr2 => value2, ...},
        #   { .. }
        # ]
      }
    end
  end
  
end
