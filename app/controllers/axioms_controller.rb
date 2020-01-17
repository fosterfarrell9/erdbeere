class AxiomsController < ApplicationController
	before_action :set_axiom, only: [:destroy]

	def new
		@axiom = Axiom.new(structure_id: params[:structure_id])
		@structure = Structure.find_by_id(params[:structure_id])
	end

	def create
		extract_atom!
		@structure = Structure.find_by_id(axiom_params[:structure_id])
		value = axiom_params[:value].to_i.zero? ? false : true
		@axiom = Axiom.new(structure: @structure,
											 atom: @atom,
											 value: value)
		@axiom.save
		if @axiom.valid?
			redirect_to edit_structure_path(@axiom.structure)
		end
    @errors = @axiom.errors
    pp @errors
	end

	def destroy
		@axiom.destroy
		redirect_to edit_structure_path(@axiom.structure)
	end

	private

  def set_axiom
    @axiom = Axiom.find_by_id(params[:id])
    return if @axiom.present?
    redirect_to :root, alert: I18n.t('controllers.no_axiom')
  end

  def axiom_params
  	params.require(:axiom).permit(:structure_id, :atom_id,
  																:stuff_w_props, :satisfies_id,
  																:value)
  end

  def extract_atom!
  	return if axiom_params[:stuff_w_props].blank?
  	return if axiom_params[:satisfies_id].blank?
    stuff = axiom_params[:stuff_w_props].split('-')
    stuff_type = stuff.first == 's' ? 'Structure' : 'BuildingBlock'
    stuff_id = stuff.second.to_i
		@atom = Atom.find_or_create_by(stuff_w_props_type: stuff_type,
     	                             stuff_w_props_id: stuff_id,
      	                           satisfies_type: 'Property',
        	                         satisfies_id: axiom_params[:satisfies_id])
  end
end