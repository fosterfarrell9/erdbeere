class ImplicationsController < ApplicationController
  before_action :set_implication, except: [:create, :new]

  def new
    @structure = Structure.find_by_id(params[:structure_id])
    @implication = Implication.new
  end

  def create
    @implication = Implication.new
    extract_premises!
    extract_conclusion!
    @implication.save
    if @implication.valid?
      redirect_to edit_structure_path(params[:implication][:structure_id])
      return
    end
    pp @implication.errors
  end

  def destroy
    @implication.destroy
    redirect_to edit_structure_path(params[:structure_id])
  end

  private

  def implication_params
  	params.require(:implication).permit(:atom_ids, :implies_id,
                                        premises: {}, implies: {})
  end

  def extract_premises!
    @extracted_premises = []
    implication_params[:premises].each do |k,v|
      next if v['stuff_w_props'].blank? || v['satisfies'].blank? || v['value'].blank?
      stuff = v['stuff_w_props'].split('-')
      stuff_type = stuff.first == 's' ? 'Structure' : 'BuildingBlock'
      stuff_id = stuff.second.to_i
      satisfies_id = v['satisfies'].to_i
      value = v['value'].to_i.zero? ? false : true
      atom = Atom.find_or_create_by(stuff_w_props_type: stuff_type,
                                    stuff_w_props_id: stuff_id,
                                    satisfies_type: 'Property',
                                    satisfies_id: satisfies_id)
      @implication.premises.build(atom: atom, value: value)
    end
  end

  def extract_conclusion!
    implies = implication_params[:implies]
    return if implies['stuff_w_props'].blank? || implies['satisfies'].blank?
    stuff = implies['stuff_w_props'].split('-')
    stuff_type = stuff.first == 's' ? 'Structure' : 'BuildingBlock'
    stuff_id = stuff.second.to_i
    satisfies_id = implies['satisfies'].to_i
    extracted_conclusion = Atom.find_or_create_by(stuff_w_props_type: stuff_type,
                                                  stuff_w_props_id: stuff_id,
                                                  satisfies_type: 'Property',
                                                  satisfies_id: satisfies_id)
    @implication.implies = extracted_conclusion
    implies_value = implies['value'].to_i.zero? ? false : true
    @implication.implies_value = implies_value
  end


  def set_implication
    @implication = Implication.find_by_id(params[:id])
    return if @implication.present?
    redirect_to :root, alert: I18n.t('controllers.no_implication')
  end
end