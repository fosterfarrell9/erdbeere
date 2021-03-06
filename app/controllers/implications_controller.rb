# Implications controller
class ImplicationsController < ApplicationController
  before_action :set_implication, except: [:create, :new]

  def new
    @structure = Structure.find_by_id(params[:structure_id])
    @implication = Implication.new
  end

  def create
    @implication = Implication.new(structure_id:
                                     implication_params[:structure_id])
    extract_premises!
    extract_conclusion!
    begin
      @implication.save
      if @implication.valid?
        CachePopulator.perform_async
        redirect_to edit_structure_path(params[:implication][:structure_id])
        return
      end
      @errors = @implication.errors
    rescue
      @implication.errors.add(:base, I18n.t('implication.create.contradiction'))
      @errors = @implication.errors
    end
  end

  def destroy
    @implication.destroy
    CachePopulator.perform_async
    redirect_to edit_structure_path(params[:structure_id])
  end

  private

  def implication_params
    params.require(:implication).permit(:atom_ids, :implies_id, :structure_id,
                                        premises: {}, implies: {})
  end

  def extract_premises!
    @extracted_premises = []
    implication_params[:premises].each do |_k, v|
      next if v['stuff_w_props'].blank? || v['satisfies'].blank? ||
              v['value'].blank?

      extract_premise_details!(v)
      atom = Atom.find_or_create_by(stuff_w_props_type: @stuff_type,
                                    stuff_w_props_id: @stuff_id,
                                    satisfies_type: 'Property',
                                    satisfies_id: @satisfies_id)
      @implication.premises.build(atom: atom, value: @value)
    end
  end

  def extract_conclusion!
    implies = implication_params[:implies]
    return if implies['stuff_w_props'].blank? || implies['satisfies'].blank?

    extract_conclusion_details!(implies)
    conclusion = Atom.find_or_create_by(stuff_w_props_type: @stuff_type,
                                        stuff_w_props_id: @stuff_id,
                                        satisfies_type: 'Property',
                                        satisfies_id: @satisfies_id)
    @implication.implies = conclusion
    @implication.implies_value = @implies_value
  end

  def set_implication
    @implication = Implication.find_by_id(params[:id])
    return if @implication.present?

    redirect_to :root, alert: I18n.t('controllers.no_implication')
  end

  def extract_premise_details!(premise)
    stuff = premise['stuff_w_props'].split('-')
    @stuff_type = stuff.first == 's' ? 'Structure' : 'BuildingBlock'
    @stuff_id = stuff.second.to_i
    @satisfies_id = premise['satisfies'].to_i
    if @stuff_type == 'Structure'
      @stuff_id = Property.find_by_id(@satisfies_id).structure.id
    end
    @value = premise['value'].to_i.zero? ? false : true
  end

  def extract_conclusion_details!(implies)
    stuff = implies['stuff_w_props'].split('-')
    @stuff_type = stuff.first == 's' ? 'Structure' : 'BuildingBlock'
    @stuff_id = stuff.second.to_i
    @satisfies_id = implies['satisfies'].to_i
    if @stuff_type == 'Structure'
      @stuff_id = Property.find_by_id(@satisfies_id).structure.id
    end
    @implies_value = implies['value'].to_i.zero? ? false : true
  end
end
