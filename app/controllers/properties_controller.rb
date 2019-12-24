class PropertiesController < ApplicationController
  before_action :set_property, only: [:show]

  def show
  end

  private

  def set_property
    @property = Property.find_by_id(params[:id])
    return if @property.present?
    redirect_to :root, alert: I18n.t('controllers.no_property')
  end
end