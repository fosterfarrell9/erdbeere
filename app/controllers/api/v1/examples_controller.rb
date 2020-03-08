# ExamplesController for API
class Api::V1::ExamplesController < ApplicationController
#	respond_to :json

	# example call: /api/v1/keks_questions/310
  def show
    @example = Example.find_by_id(params[:id])

    unless @example
    	render json: { embedded_html: '' }
    	return
    end
		@satisfied_atoms = @example.satisfied_atoms
    @satisfied_atoms_with_proof = @example.satisfied_atoms_with_proof
    @violated_atoms = @example.violated_atoms
    @violated_atoms_with_proof = @example.violated_atoms_with_proof

    embedded_html = render_to_string(partial: 'examples/show',
                             				 formats: :html,
                             				 layout: false,
                             				 locals:
                               				 { example: @example,
                                 				 satisfied_atoms_with_proof: @satisfied_atoms_with_proof,
                                 				 satisfied_atoms: @satisfied_atoms,
                                 				 violated_atoms_with_proof: @violated_atoms_with_proof,
                                 				 violated_atoms: @violated_atoms })

  	render json: { embedded_html: embedded_html }
  end
end