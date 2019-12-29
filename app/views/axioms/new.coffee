$('#axiom-modal-content').empty()
	.append('<%= j render partial: "axioms/form",
												locals: { axiom: @axiom,
																	structure: @structure } %>')
$('#axiomModal').modal('show')