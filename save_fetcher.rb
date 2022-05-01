require 'json'
require 'singleton'
require 'aws-sdk-dynamodb'

class SaveFetcher
  include Singleton

  def self.handler(...)
    instance.handler(...)
  end

  def initialize
    @table = Aws::DynamoDB::Table.new('cookie_clicker_saves', Aws::DynamoDB::Client.new)
  end

  MALFORMED_REQUEST = {statusCode: 400, body: nil}
  OWNER_UUID_NOT_FOUND = {statusCode: 403, body: nil}

  def handler(event:, context:)
    event_body = JSON.parse(event['body'])

    owner_uuid = event_body['owner_uuid']
    return MALFORMED_REQUEST if owner_uuid.nil?

    save_item = table.get_item({key: {'owner_secret_uuid' => owner_uuid}}).item

    return OWNER_UUID_NOT_FOUND unless save_item

    {statusCode: 200, body: save_item['save']}
  end

  private

  attr_reader :table
end
