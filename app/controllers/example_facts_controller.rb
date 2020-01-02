class ExampleFactsController < ApplicationController
  before_action :set_example_fact

  def edit
  end

  def update
    @example_fact.build_explanation if @example_fact.explanation.nil?
    @example_fact.explanation.update(text: example_fact_params[:text])
    redirect_to edit_example_path(@example_fact.example)
  end

  def destroy
    @example_fact.destroy
    redirect_to edit_example_path(@example_fact.example)
  end

  private

  def set_example_fact
    @example_fact = ExampleFact.find_by_id(params[:id])
    return if @example_fact.present?
    redirect_to :root, alert: I18n.t('controllers.no_example_fact')
  end

  def example_fact_params
    params.require(:example_fact).permit(:text)
  end
end