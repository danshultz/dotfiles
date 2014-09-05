IRB.conf[:HISTORY_FILE] = File::expand_path("~/.irbhistory")

def load_wirble
  require 'wirble'
  Wirble.init
  Wirble.colorize
rescue
end

def load_pwd_irbrc
  local_irbrc = File.join(Dir.pwd, ".irbrc")
  if not Dir.pwd == File.expand_path("~") && File.exists?(local_irbrc)
    puts "local .irbrc file found in PWD. loading..."
    eval(IO.read(local_irbrc))
  end
end

module Kernel
  def ds_methods
    (self.public_methods - Object.instance_methods).sort
  end
end

require 'rubygems'
require 'irb/completion'
load_pwd_irbrc
#load_wirble

