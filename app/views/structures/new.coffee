$('#structure-modal-content').empty()
	.append('<%= j render partial: "structures/form",
												locals: { structure: @structure } %>')
$('#structureModal').modal('show')