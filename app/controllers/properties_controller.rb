class PropertiesController < ApplicationController
  before_action :set_property, except: [:create, :new]
  before_action :set_facts_and_examples, only: [:show, :edit]

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
      return
		end
    @errors = @property.errors
    render :update
  end

  def update
  	@property.update(property_params)
    if @property.valid?
  	  redirect_to edit_property_path(@property)
      return
    end
    @errors = @property.errors
  end

  def add_example_facts
    @satisfied = params[:sort] == 'truth'
    @available_examples = @property.structure.examples
    @available_examples -= @property.example_facts.map(&:example)
    @available_examples -= if @satisfied
                               @property.negative_examples
                             else
                               @property.positive_examples
                             end
  end

  def update_example_facts
    example_facts_params[:examples]&.each do |k,v|
      next unless v.to_i == 1
      fact = ExampleFact.new(example_id: k.to_i,
                             property_id: @property.id,
                             satisfied: example_facts_params[:satisfied])
      fact.save
    end
    if example_facts_params[:new_example].present?
      new_example = Example.new(description: example_facts_params[:new_example],
                                structure_id: @property.structure.id)
      new_example.save
      if new_example.valid?
          ExampleFact.create(example_id: new_example.id,
                             property_id: @property.id,
                             satisfied: example_facts_params[:satisfied])
      end
    end
    redirect_to edit_property_path(@property)
  end

  def destroy
    @property.destroy
    redirect_to edit_structure_path(@property.structure)
  end

  private

  def property_params
  	params.require(:property).permit(:name, :definition, :structure_id,
  																	 :stackstag)
  end

  def example_facts_params
    params.require(:example_facts).permit(:satisfied, :new_example,
                                          examples: {})
  end

  def set_property
    @property = Property.find_by_id(params[:id])
    return if @property.present?
    redirect_to :root, alert: I18n.t('controllers.no_property')
  end

  def set_facts_and_examples
    @positive_hardcoded_facts = @property.positive_hardcoded_facts
    @negative_hardcoded_facts = @property.negative_hardcoded_facts
    @positive_derived_examples = @property.positive_derived_examples
    @negative_derived_examples = @property.negative_derived_examples
  end
end