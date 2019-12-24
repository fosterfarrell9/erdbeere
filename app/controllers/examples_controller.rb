# coding: utf-8

class ExamplesController < ApplicationController
  def show
    @example = Example.find(params[:id])
  end

  def find
    @satisfies = params[:satisfies].to_a.map { |i| Atom.find(i.to_i) }.to_a
    @violates = params[:violates].to_a.map { |i| Atom.find(i.to_i) }.to_a

    if (@satisfies + @violates).empty?
      flash[:alert] = I18n.t('examples.find.flash.no_search_params')
      redirect_to main_search_path
    end

    @proof = Example.find_restricted(Structure.find(params[:structure_id]),
                                     @satisfies,
                                     @violates)
    if @proof
      flash.now[:alert] = I18n.t('examples.find.flash.violates_logic')
      render 'violates_logic'
    end

    @almost_hits = Example.where('structure_id = ?', params[:structure_id].to_i).all.to_a.find_all do |e|
      (@satisfies - e.satisfied_atoms_by_sat).empty? && (@violates & e.satisfied_atoms_by_sat).empty?
    end

    if @almost_hits.empty?
      flash.now[:warning] = I18n.t('examples.find.flash.nothing_found')
    else
      @hits = @almost_hits.find_all do |e|
        (@violates - e.computable_violations).empty?
      end
    end
  end
end
