class StructuresController < ApplicationController
  before_action :set_structure, except: [:index]
  def index
    @structures = Structure.all.to_a
  end

  def show
  end

  def edit
  end

  def update
    @structure.update(structure_params)
    redirect_to edit_structure_path(@structure)
  end

  private

  def set_structure
    @structure = Structure.find_by_id(params[:id])
    return if @structure.present?
    redirect_to :root, alert: I18n.t('controllers.no_structure')
  end

  def structure_params
    params.require(:structure).permit(:definition, :name)
  end
end