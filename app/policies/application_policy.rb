class ApplicationPolicy
  attr_reader :token, :record, :action_scope

  def initialize(token, record)
    @token  = token.deep_symbolize_keys
    @record = record
    @action_scope = ActionScope.new(@token)
  end

  def method_missing(name)
    action_scope.action_allowed?(self.class, name)
  end

  def scope
    Pundit.policy_scope!(token, record.class)
  end

  class Scope
    attr_reader :token, :scope

    def initialize(token, scope)
      @token = token.deep_symbolize_keys
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
