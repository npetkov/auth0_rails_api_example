class NotePolicy < ApplicationPolicy
  def permitted_attributes
    %i(:name :content)
  end

  class NotePolicy::Scope < ApplicationPolicy::Scope
    def resolve
      Note.unscoped
    end
  end
end
