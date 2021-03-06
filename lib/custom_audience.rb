require 'koala'
require 'json'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'
require 'custom_audience/version'

module CustomAudience
  class CustomAudience
    MAX_USERS_PER_REQUEST = 1000
    attr_accessor :users
    attr_reader :attributes, :token

    def initialize(attributes = {})
      @attributes = attributes.stringify_keys

      self.token = attributes.delete('token')
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

    def delete_users!(users)
      users.each_slice(MAX_USERS_PER_REQUEST) do |slice|
        graph.delete_connections id, 'users', users: user_ids_for_api(slice)
      end
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
      users.each_slice(MAX_USERS_PER_REQUEST) do |slice|
        # TODO Use the #batch API here
        # TODO Ensure all the calls work
        #  * either retry failed calls, or raise an error at the end with the failed batches.
        # TODO Find out how the API handles duplicate users (in theory they handle it fine)
        graph.put_connections id, 'users', users: user_ids_for_api(slice)
      end
    end

    def all
      @all ||= graph.get_connections("act_" + account_id, 'customaudiences').map do |audience_data|
        CustomAudience.new audience_data
      end
    end

    def fetch_attributes!
      return unless token.present? && !@fetched

      if id.present?
        @fetched = true

        @attributes = graph.get_object(id)
      elsif account_id.present? && match = all.detect {|audience| audience.name == name }
        @fetched = true

        @attributes = match.attributes
      end
    end

    def user_ids_for_api(users = users)
      JSON.dump(users.map {|user| {"id" => user } })
    end
  end
end
