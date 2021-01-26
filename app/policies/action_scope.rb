# frozen_string_literal: true

class ActionScope
  attr_accessor :token

  def initialize(token)
    @token = token
  end

  def action_allowed?(policy_class, method_name)
    return false unless token.key?(:permissions)

    allowed_actions = resource_actions(policy_class)
    action = current_action(method_name)
    allowed_actions.include?(action)
  end

  private

  def resource_actions(policy_class)
    resource = policy_class.name.downcase[/^(.*)policy$/, 1].pluralize
    permissions = map_permissions
    permissions[resource] || []
  end

  def map_permissions
    hash = Hash.new { |map, key| map[key] = [] }
    token[:permissions].each_with_object(hash) do |permission, map|
      action, resource = permission.split(':')
      map[resource] << action
    end
  end

  def current_action(method_name)
    method_name.to_s[/^(.*)\?$/, 1]
  end
end
