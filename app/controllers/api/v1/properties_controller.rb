# PropertiesController for API
class Api::V1::PropertiesController < ApplicationController
#	respond_to :json

	# example call: /api/v1/properties/show/1
  def show
    property = Property.find_by_id(params[:id])

    unless property
      render json: { embedded_html: '' }
      return
    end

    embedded_html = render_to_string(partial: 'properties/show/show',
                             	       formats: :html,
                             		     layout: false,
                             		     locals:
                               		     { property: property,
                                         api: true,
                                         positive_hardcoded_facts:
                                           property.positive_hardcoded_facts,
                                         positive_derived_examples:
                                           property.positive_derived_examples,
                                         negative_hardcoded_facts:
                                           property.negative_hardcoded_facts,
                                         negative_derived_examples:
                                           property.negative_derived_examples })

  	render json: { embedded_html: embedded_html }
  end

  def view_info
    render json: PropertySerializer.new(Property.find_by_id(params[:id]))
                                   .serialized_json
  end
end