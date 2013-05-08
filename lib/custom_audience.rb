require 'koala'
require 'json'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'
require 'custom_audience/version'

module CustomAudience
  class CustomAudience
    attr_accessor :users
    attr_reader :attributes, :token

    def initialize(name_or_hash = {})
      if name_or_hash.is_a?(Hash)
        @attributes = name_or_hash.stringify_keys
      else
        @attributes = {"name" => name_or_hash}
      end

      self.token = @attributes.delete('token')
      fetch_attributes!
    end

    def exists?
      id.present?
    end

    def save
      # Should try and fetch attributes?
      create if ! exists?

      add_users
    end

    def account_id=(account_id)
      attributes["account_id"] = account_id
      fetch_attributes!
    end

    def token=(token)
      @token = token
      fetch_attributes!
    end

    def account_id
      attributes['account_id'].to_s.gsub(/^act_/, '')
    end

    def name
      attributes["name"]
    end

    def id
      attributes["id"]
    end

    private
    def graph
      @graph ||= Koala::Facebook::API.new(token)
    end

    def create
      id = graph.put_connections("act_" + account_id, 'customaudiences', name: name)["id"]

      @attributes = graph.get_object(id)
    end

    def add_users
      graph.put_connections id, 'users', users: JSON.dump(users.map {|user| {"id" => user } })
    end

    def all
      @all ||= graph.get_connections("act_" + account_id, 'customaudiences').map do |audience_data|
        CustomAudience.new audience_data
      end
    end

    def fetch_attributes!
      return unless account_id.present? && token.present?

      if match = all.detect {|audience| audience.name == name }
        @attributes = match.attributes
      end
    end
  end
end
