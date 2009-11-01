require "thinking_sphinx"


# added by Tomato
# 
# to make thinking sphinx recognize the parameter: charset_dictpath
# and build its value into sphinx configure file
# 
# we have to use this kind of *hack* way
# since *charset_dictpath* is not a sphinx parameter, but a Coreseek's
# for Chinese word segmentation

module Riddle
  class Configuration
    class Section
      
      alias original_settings_body settings_body
      
      private
      
      def settings_body
        charset_dictpath = if ThinkingSphinx::Configuration.environment == "production"
          "/home/tomato/websites/app/CareerCommunity/shared/sphinx/dict"
        else
          "/Users/tomato/Dev/git/projects/CareerCommunity/db/sphinx/dict"
        end
        
        if self.class.name == "Riddle::Configuration::Index"
          original_settings_body << "  charset_dictpath = #{charset_dictpath}"
        else
          original_settings_body
        end
      end
      
    end
  end
end


# added by Tomato
# 
# to fix the boolean not being converted to int bug,
# the boolean value true/false can NOT be used to pack

module Riddle
  class Client
    class Message
      
      alias original_append_int append_int
      
      def append_int(int)
        int = int.to_i rescue (int ? 1 : 0)
        
        original_append_int(int)
      end
      
    end
  end
end
