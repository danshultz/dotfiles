cookbook_path ["."]
log_level :info
log_location STDOUT
local_mode true
if ENV['SECRET']
  encrypted_data_bag_secret(ENV['SECRET'])
end
knife[:editor] = 'vim'
