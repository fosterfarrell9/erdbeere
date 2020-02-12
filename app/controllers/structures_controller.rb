# Structures controller
class StructuresController < ApplicationController
  before_action :set_structure, except: [:index, :create, :new]

  def index
    @structures = Structure.all.to_a
  end

  def show
  end

  def edit
    @locked = @structure.locked?
  end

  def update
    @structure.update(structure_params)
    if @structure.valid?
      redirect_to edit_structure_path(@structure)
      return
    end
    @errors = @structure.errors
  end

  def new
    @structure = Structure.new
  end

  def create
    @structure = Structure.create(structure_params)
    if @structure.valid?
      redirect_to structures_path
      return
    end
    @errors = @structure.errors
    render :update
  end

  def destroy
    @structure.destroy
    redirect_to structures_path
  end

  private

  def set_structure
    @structure = Structure.find_by_id(params[:id])
    return if @structure.present?

    redirect_to :root, alert: I18n.t('controllers.no_structure')
  end

  def structure_params
    params.require(:structure).permit(:definition, :name, :derives_from_id)
  end
end
