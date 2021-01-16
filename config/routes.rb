# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  post 'auth/token', to: 'auth#token'
  resources :notes, only: %i[index create]
  match '*path', via: [:options], to: ->(_) { [204, { 'Content-Type' => 'text/plain' }, []] }
end
