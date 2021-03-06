# Examples controller
class ExamplesController < ApplicationController
  before_action :set_example, only: [:show, :edit, :update, :add_example_facts,
                                     :update_example_facts, :destroy]
  def show
    @satisfied_atoms = @example.satisfied_atoms
    @satisfied_atoms_with_proof = @example.satisfied_atoms_with_proof
    @violated_atoms = @example.violated_atoms
    @violated_atoms_with_proof = @example.violated_atoms_with_proof
  end

  def edit
    @bbr_hash = @example.structure.example_building_block_realizations
  end

  def new
    @example = Example.new(structure_id: params[:structure_id].to_i)
    @bbr_hash = @example.structure.example_building_block_realizations
    @property = Property.find_by_id(params[:property_id])
    @satisfied = params[:satisfied]
  end

  def create
    extract_example_and_property!
    extract_building_block_realizations!
    @example.save
    if @example.valid?
      if @property.present?
        ExampleFact.create(example: @example,
                           property: @property,
                           satisfied: @satisfied)
        CachePopulator.perform_async
        redirect_to edit_property_path(@property)
      else
        redirect_to edit_structure_path(@example.structure)
      end
      return
    end
    @errors = @example.errors
    render :update
  end

  def update
    update_building_block_realizations!
    @example.update(description: example_params[:description])
    if @example.valid?
      CachePopulator.perform_async
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
                               @example.violated_atoms.map(&:property)
                             else
                               @example.satisfied_atoms.map(&:property)
                             end
  end

  def update_example_facts
    create_new_example_facts!
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
    CachePopulator.perform_async
    redirect_to edit_example_path(@example)
  end

  def find
    @structure = Structure.find_by_id(find_params[:structure_id])
    @satisfies = Atom.where(id: find_params[:satisfies]).to_a.compact
    @violates = Atom.where(id: find_params[:violates]).to_a.compact

    @proof = Example.find_contradiction(@structure, @satisfies, @violates)
    return if @proof

    @hits = Example.find_match(@structure, @satisfies, @violates)
  end

  def destroy
    @example.destroy
    redirect_to edit_structure_path(@example.structure)
  end

  private

  def example_params
    params.require(:example).permit(:description, :structure_id, :property_id,
                                    :satisfied,
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

    example_params[:building_block_realizations].each do |k, v|
      @example.building_block_realizations.build(building_block_id: k.to_i,
                                                 realization_id: v.to_i)
    end
  end

  def extract_example_and_property!
    @example = Example.new(structure_id: example_params[:structure_id],
                           description: example_params[:description])
    @property = Property.find_by_id(example_params[:property_id])
    @satisfied = example_params[:satisfied] == 'true'
  end

  def update_building_block_realizations!
    return unless example_params[:building_block_realizations]

    bbrs = @example.building_block_realizations.to_a
    example_params[:building_block_realizations].each do |k, v|
      bbr = bbrs.find { |x| x.id == k.to_i }
      next unless bbr && bbr.realization_id != v.to_i

      bbr.realization_id = v
    end
    @example.update(building_block_realizations: bbrs)
  end

  def set_example
    @example = Example.find_by_id(params[:id])
    return if @example.present?

    redirect_to :root, alert: I18n.t('controllers.no_example')
  end

  def create_new_example_facts!
    example_facts_params[:properties].each do |k, v|
      next unless v.to_i == 1

      fact = ExampleFact.new(example_id: @example.id,
                             property_id: k.to_i,
                             satisfied: example_facts_params[:satisfied])
      fact.save
    end
  end
end
