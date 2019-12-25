$('#building-block-modal-content').empty()
	.append('<%= j render partial: "building_blocks/form",
												locals: { building_block: @building_block } %>')
$('#buildingBlockModal').modal('show')