# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :expire_after => 60*60*10, # set the session expire time to 10 hours
  :key         => '_TalentBank_session',
  :secret      => '4454a3f7a67e7cf2eec1f84f0bd91be2a2fe99455824fdd61862380c4a42d51a4917781bc369ec99944e99c677446a3d7d29795a912cbe69908632affab32727'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

# ActionController::Base.session_store = :mem_cache_store
ActionController::Base.session_store = Cache_Store_Name
