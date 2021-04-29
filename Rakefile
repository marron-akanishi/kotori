require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
Dir[File.dirname(__FILE__) + "/models/**"].each do |model|
  require model
end

ActiveRecord::Base.configurations = YAML.load_file('./database.yml')
ActiveRecord::Base.establish_connection(:development)