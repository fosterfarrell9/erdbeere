class StructuresController < ApplicationController
  before_action :set_structure, only: [:show]
  def index
    @structures = Structure.all.to_a
  end

  def show
  end

  private

  def set_structure
    @structure = Structure.find_by_id(params[:id])
    return if @structure.present?
    redirect_to :root, alert: I18n.t('controllers.no_structure')
  end
end