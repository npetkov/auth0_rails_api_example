class ActionScope
  attr_accessor :token

  def initialize(token)
    @token = token
  end

  def action_allowed?(policy_class, method_name)
    return false unless token[:scopes].key?(:actions)

    allowed_actions = resource_actions policy_class
    action = current_action method_name
    allowed_actions.include?('*') || allowed_actions.include?(action)
  end

  private

  def resource_actions(policy_class)
    endpoint = policy_class.name.downcase[/^(.*)policy$/, 1].pluralize.to_sym
    token[:scopes][:actions][endpoint] || []
  end

  def current_action(method_name)
    method_name.to_s[/^(.*)\?$/, 1]
  end
end
