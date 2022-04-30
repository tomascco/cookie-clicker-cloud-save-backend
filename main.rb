require 'json'
require 'singleton'
require 'aws-sdk-dynamodb'

class SaveHandler
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

    required_params = event_body.values_at('owner_uuid', 'save')
    return MALFORMED_REQUEST if required_params.any?(&:nil?)

    owner_uuid, save = required_params

    return OWNER_UUID_NOT_FOUND unless owner_secret_uuid_exists!(owner_uuid)

    update_save!(owner_uuid, save)

    {statusCode: 200, body: 'ok'}
  end

  private

  attr_reader :table

  def owner_secret_uuid_exists!(uuid)
    !table.get_item({key: {'owner_secret_uuid' => uuid}}).item.nil?
  end

  def update_save!(owner_uuid, save)
    table.update_item({
      key: {'owner_secret_uuid' => owner_uuid},
      update_expression: 'SET #save = :save',
      expression_attribute_names: {'#save' => 'save'},
      expression_attribute_values: {':save' => save}
    })
  end
end
