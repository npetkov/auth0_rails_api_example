# frozen_string_literal: true

class CreateNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :notes do |t|
      t.string :name
      t.string :content
      t.string :uid

      t.timestamps
    end
  end
end
