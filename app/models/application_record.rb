# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  validates :uid,
            format: { with: /\A[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}\z/i },
            uniqueness: true,
            allow_blank: true

  before_create do |record|
    self.uid = SecureRandom.uuid unless record.uid
  end
end
