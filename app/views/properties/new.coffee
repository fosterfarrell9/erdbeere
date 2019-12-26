$('#property-modal-content').empty()
	.append('<%= j render partial: "properties/modal_form",
												locals: { property: @property } %>')
$('#propertyModal').modal('show')