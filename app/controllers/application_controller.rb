class ApplicationController < ActionController::Base

  include ApplicationHelper
  devise_for :users

end