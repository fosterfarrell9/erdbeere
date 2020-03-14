# ExamplesController for API
class Api::V1::ExamplesController < ApplicationController
#	respond_to :json

	# example call: /api/v1/examples/show/1
  def show
    example = Example.find_by_id(params[:id])

    unless example
    	render json: { embedded_html: '' }
    	return
    end

    embedded_html = render_to_string(partial: 'examples/show/show',
                             		 formats: :html,
                             		 layout: false,
                             		 locals:
                               		   { example: example,
                                         api: true,
                                		 satisfied_atoms_with_proof:
                                 		   example.satisfied_atoms_with_proof,
                                 		 satisfied_atoms:
                                 		   example.satisfied_atoms,
                                 		 violated_atoms_with_proof:
                                 		   example.violated_atoms_with_proof,
                                 		 violated_atoms:
                                 		   example.violated_atoms })

  	render json: { embedded_html: embedded_html }
  end

  def search
		embedded_html = render_to_string(partial: 'main/search',
                             		 		 formats: :html,
                             		 		 layout: false)
  	render json: { embedded_html: embedded_html }
  end
end