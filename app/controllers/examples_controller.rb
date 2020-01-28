class ExamplesController < ApplicationController
  before_action :set_example, only: [:show, :edit, :update, :add_example_facts,
                                     :update_example_facts]

  def show
  end

  def edit
    @bbr_hash = @example.structure.example_building_block_realizations
  end

  def new
    @example = Example.new(structure_id: params[:structure_id].to_i)
    @bbr_hash = @example.structure.example_building_block_realizations
  end

  def create
    @example = Example.new(structure_id: example_params[:structure_id],
                           description: example_params[:description])
    extract_building_block_realizations!
    @example.save
    if @example.valid?
      redirect_to edit_structure_path(@example.structure)
      return
    end
    @errors = @example.errors
    pp @errors
    render :update
  end

  def update
    @example.update(description: example_params[:description])
    update_building_block_realizations!
    if @example.valid?
      redirect_to edit_example_path(@example)
      return
    end
    @errors = @example.errors
  end

  def add_example_facts
    @satisfied = params[:sort] == 'truth'
    @available_properties = @example.structure.original_properties
    @available_properties -= @example.example_facts.map(&:property)
    @available_properties -= if @satisfied
                               @example.violated_atoms_by_sat.map(&:property)
                             else
                               @example.satisfied_atoms_by_sat.map(&:property)
                             end
  end

  def update_example_facts
    example_facts_params[:properties].each do |k,v|
      next unless v.to_i == 1
      fact = ExampleFact.new(example_id: @example.id,
                             property_id: k.to_i,
                             satisfied: example_facts_params[:satisfied])
      fact.save
    end
    if example_facts_params[:new_property].present?
      new_property = Property.new(name: example_facts_params[:new_property],
                                  structure_id: @example.structure.id)
      new_property.save
      if new_property.valid?
          ExampleFact.create(example_id: @example.id,
                             property_id: new_property.id,
                             satisfied: example_facts_params[:satisfied])
      end
    end
    redirect_to edit_example_path(@example)
  end

  def find
    @structure = Structure.find_by_id(find_params[:structure_id])
    @satisfies = Atom.where(id: find_params[:satisfies]).to_a.compact
    @violates = Atom.where(id: find_params[:violates]).to_a.compact

    if (@satisfies + @violates).empty?
      flash[:alert] = I18n.t('examples.find.flash.no_search_params')
      redirect_to main_search_path
      return
    end

    @proof = Example.find_restricted(@structure, @satisfies, @violates)
    return if @proof

    @hits = Example.where(structure_id: @structure.id).all.to_a.find_all do |e|
      e.valid? && (@satisfies - e.satisfied_atoms_by_sat).empty? && (@violates - e.violated_atoms_by_sat).empty?
    end
  end

  private

  def example_params
    params.require(:example).permit(:description, :structure_id,
                                    building_block_realizations: {})
  end

  def example_facts_params
    params.require(:example_facts).permit(:satisfied, :new_property,
                                          properties: {})
  end

  def find_params
    params.require(:find).permit(:structure_id,
                                 satisfies: [],
                                 violates: [])
  end

  def extract_building_block_realizations!
    return unless example_params[:building_block_realizations]
    example_params[:building_block_realizations].each do |k,v|
      @example.building_block_realizations.build(building_block_id: k.to_i,
                                                 realization_id: v.to_i)
    end
  end

  def update_building_block_realizations!
    return unless example_params[:building_block_realizations]
    example_params[:building_block_realizations].each do |k,v|
      bbr = @example.building_block_realizations.find_by(id: k)
      next unless bbr && bbr.realization_id != v.to_i
      bbr.update(realization_id: v)
    end
  end

  def set_example
    @example = Example.find_by_id(params[:id])
    return if @example.present?
    redirect_to :root, alert: I18n.t('controllers.no_example')
  end
end
