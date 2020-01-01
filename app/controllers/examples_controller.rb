class ExamplesController < ApplicationController
  before_action :set_example, only: [:show, :edit, :update]

  def show
  end

  def edit
  end

  def new
    @example = Example.new(structure_id: params[:structure_id].to_i)
  end

  def create
    @example = Example.new(structure_id: example_params[:structure_id],
                           description: example_params[:description])
    extract_building_block_realizations!
    @example.save
    if @example.valid?
      redirect_to edit_structure_path(@example.structure)
    end
  end

  def update
    @example.update(description: example_params[:description])
    update_building_block_realizations!
    redirect_to edit_example_path(@example)
  end

  def find
    @satisfies = params[:satisfies].to_a.map { |i| Atom.find(i.to_i) }.to_a
    @violates = params[:violates].to_a.map { |i| Atom.find(i.to_i) }.to_a

    if (@satisfies + @violates).empty?
      flash[:alert] = I18n.t('examples.find.flash.no_search_params')
      redirect_to main_search_path
      return
    end

    @proof = Example.find_restricted(Structure.find(params[:structure_id]),
                                     @satisfies,
                                     @violates)
    if @proof
      render 'violates_logic'
      return
    end

    @almost_hits = Example.where('structure_id = ?', params[:structure_id].to_i).all.to_a.find_all do |e|
      (@satisfies - e.satisfied_atoms_by_sat).empty? && (@violates & e.satisfied_atoms_by_sat).empty?
    end

    if @almost_hits.empty?
      flash.now[:warning] = I18n.t('examples.find.flash.nothing_found')
    else
      @hits = @almost_hits.find_all do |e|
        (@violates - e.violated_atoms_by_sat).empty?
      end
    end
  end

  private

  def example_params
    params.require(:example).permit(:description, :structure_id,
                                    building_block_realizations: {})
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
