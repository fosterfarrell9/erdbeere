# Application controller
class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :authenticate_user!

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
