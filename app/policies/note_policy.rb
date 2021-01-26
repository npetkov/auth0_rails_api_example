# frozen_string_literal: true

class NotePolicy < ApplicationPolicy
  def permitted_attributes
    %i[name content]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      Note.unscoped
    end
  end
end
