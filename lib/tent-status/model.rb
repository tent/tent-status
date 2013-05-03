require 'sequel'

module TentStatus
  module Model
    class << self
      attr_accessor :db
    end

    def self.new(options = {})
      self.db ||= Sequel.connect(
        options[:database_url] || TentStatus.settings[:database_url],
        :logger => Logger.new(options[:database_logfile] || TentStatus.settings[:database_logfile])
      )

      require 'tent-status/model/user'
    end
  end
end
