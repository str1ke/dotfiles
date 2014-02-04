require 'irb/completion'
require 'irb/ext/save-history'
require 'net-http-spy'

# awesome print
begin
  require 'awesome_print'
  begin
    AwesomePrint.irb!
  rescue
    warn 'cannot ap.irb!'
  end
rescue LoadError => err
  warn "Couldn't load awesome_print: #{err}"
end


#IRB.conf[:SAVE_HISTORY] = 1000
#IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
#IRB.conf[:PROMPT_MODE] = :SIMPLE
#IRB.conf[:AUTO_INDENT] = true

# Bash-like tab completion
# require 'bond'; Bond.start

module Kernel
  def rrequire(file)
    $:.unshift Dir.pwd
    require file
  end
end

class Object
  # Return a list of methods defined locally for a particular object.  Useful
  # for seeing what it does whilst losing all the guff that's implemented
  # by its parents (eg Object).
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
end

# load .railsrc in rails environments
railsrc_path = File.expand_path('~/.irbrc_rails')
if ( ENV['RAILS_ENV'] || defined? Rails ) && File.exist?( railsrc_path )
  begin
    load railsrc_path
  rescue Exception
    warn "Could not load: #{ railsrc_path } because of #{$!.message}"
  end
end


# interactive editor: use vim from within irb
#begin
#  require 'interactive_editor'
#rescue LoadError => err
#  warn "Couldn't load interactive_editor: #{err}"
#end

require 'stringio'
require 'timeout'

class Object
  def methods_returning(expected, *args, &blk)
    old_stdout = $>
    $> = StringIO.new

    methods.select do |meth|
      Timeout::timeout(1) { dup.public_send(meth, *args, &blk) == expected rescue false } rescue false
    end
  ensure
    $> = old_stdout
  end
end
