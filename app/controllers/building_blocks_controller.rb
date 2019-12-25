class BuildingBlocksController < ApplicationController
	before_action :set_building_block, except: [:new, :create]

	def new
		@building_block = BuildingBlock.new(explained_structure_id: params[:structure_id])
		pp @building_block
		render 'edit'
	end

	def edit
	end

	def create
		@building_block = BuildingBlock.create(building_block_params)
		pp @building_block.errors
		if @building_block.valid?
			redirect_to edit_structure_path(@building_block.explained_structure)
		end
	end

	def update
		@building_block.update(building_block_params)
		redirect_to edit_structure_path(@building_block.explained_structure)
	end

	def destroy
		@building_block.destroy
		redirect_to edit_structure_path(@building_block.explained_structure)
	end

	private

  def set_building_block
    @building_block = BuildingBlock.find_by_id(params[:id])
    return if @building_block.present?
    redirect_to :root, alert: I18n.t('controllers.no_building_block')
  end

  def building_block_params
  	params.require(:building_block).permit(:name, :definition,
  																				 :structure_id,
  																				 :explained_structure_id)
  end
end