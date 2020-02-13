$('#building_block-modal-content').empty()
	.append('<%= j render partial: "building_blocks/form",
												locals: { building_block: @building_block } %>')
$('#building_blockModal').modal('show')