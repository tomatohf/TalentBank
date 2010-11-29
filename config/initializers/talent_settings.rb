# enable UTF-8 support
require 'jcode'
$KCODE9 = 'u'

# require "i18n"

##################################################
### END
##################################################





##################################################
### require gem files
##################################################

require "date"
require "mime/types"
require "will_paginate"
require "select_with_include"
require "thinking_sphinx"
require "RMagick"
require "pathname"
require "fileutils"
require "redcloth"

require "fastercsv"
Mime::Type.register "text/csv; charset=UTF-8; header=present", :csv


# require "digest/sha1"
# 
# require "hpricot"
# require "open-uri"
# 
# require "iconv"
# 
# require "xmpp4r-simple"
# require "system_timer"

##################################################
### END
##################################################





##################################################
### require middlewares
##################################################



##################################################
### END
##################################################





##################################################
### require lib files
##################################################

require "noisy_image"

require_dependency "utils"

require_dependency "schools/base"

require_dependency "skill_value_types/base"

require_dependency "thinking_sphinx/daily_delta"

require_dependency "pdf_export/base"
Mime::Type.register "application/pdf", :pdf

require "ofc"

##################################################
### END
##################################################





##################################################
### SMTP setting for email sending
##################################################

require "smtp_tls"

ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_charset = "utf-8"

ActionMailer::Base.raise_delivery_errors = true
# setting for Gmail
#ActionMailer::Base.smtp_settings = {
#  :address => "smtp.gmail.com",
#  :port => "587",
#  :authentication => :plain,
#  :user_name => "votingchina",
#  :password => "***REMOVED***"
#}

# setting for localhost smtp
ActionMailer::Base.smtp_settings = {  
  #:address =>  "localhost",
  :address =>  "qiaobutang.com",
  :domain =>  "qiaobutang.com",
  :authentication => :plain,
  :user_name => "noreply@qiaobutang.com",
  :password => "***REMOVED***"
}

##################################################
### END
##################################################
