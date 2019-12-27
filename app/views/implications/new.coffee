$('#implication-modal-content').empty()
	.append('<%= j render partial: "implications/form",
												locals: { implication: @implication,
																	structure: @structure } %>')
$('#implicationModal').modal('show')