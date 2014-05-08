require "active_model"
require "active_record"
require "active_support"
require "active_model/associations"
require "active_model/associations/hooks"

# Load Railtie
begin
  require "rails"
rescue LoadError
end

if defined?(Rails)
  require "active_model/associations/railtie"
end
