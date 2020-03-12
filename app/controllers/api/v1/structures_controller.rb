# StructuresController for API
class Api::V1::StructuresController < ApplicationController
#	respond_to :json

	# example call: /api/v1/properties/show/1
  def show
    structure = Structure.find_by_id(params[:id])

    unless structure
      render json: { embedded_html: '' }
      return
    end

    embedded_html = render_to_string(partial: 'structures/show/show',
                              	     formats: :html,
                                 		 layout: false,
                                 		 locals:
                                 		   { structure: structure,
                                         api: true })

  	render json: { embedded_html: embedded_html }
  end

  def index
    render json: StructureSerializer.new(Structure.all,
                                         { include: [:original_properties] })
                                    .serialized_json
  end

  def view_info
    render json: StructureSerializer.new(Structure.find_by_id(params[:id]))
                                    .serialized_json
  end
end