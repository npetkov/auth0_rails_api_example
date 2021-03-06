# frozen_string_literal: true

class NotesController < ApplicationController
  def index
    notes = policy_scope Note
    authorize notes
    render json: notes.to_json, status: 200
  end

  def create
    note = Note.new
    authorize note
    note.assign_attributes(permitted_attributes(note))
    status = note.save ? 201 : 422
    render json: note.to_json, status: status
  end
end
