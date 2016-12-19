class ActionScope
  attr_accessor :token

  def initialize(token)
    @token = token
  end

  def action_allowed?(policy_class, action_name)
    return false unless token[:scopes].key?(:actions)

    scope_name = policy_class.name.downcase[/^(.*)policy$/, 1].pluralize.to_sym
    allowed_actions = token[:scopes][:actions][scope_name] || []
    allowed_actions.include?('*') || allowed_actions.include?(action_name.to_s[/^(.*)\?$/, 1])
  end
end
