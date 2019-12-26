class PropertiesController < ApplicationController
  before_action :set_property, except: [:create, :new]

  def show
  end

  def edit
  end

  def new
  	@property = Property.new(structure_id: params[:structure_id].to_i)
  end

  def create
  	@property = Property.create(property_params)
		if @property.valid?
			redirect_to edit_structure_path(@property.structure)
		end
  end

  def update
  	@property.update(property_params)
  	redirect_to edit_property_path(@property)
  end

  private

  def property_params
  	params.require(:property).permit(:name, :definition, :structure_id,
  																	 :stackstag)
  end

  def set_property
    @property = Property.find_by_id(params[:id])
    return if @property.present?
    redirect_to :root, alert: I18n.t('controllers.no_property')
  end
end