# frozen_string_literal: true

class NoteSerializer < ActiveModel::Serializer
  attributes :name, :content
end
