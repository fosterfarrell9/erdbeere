# clean up from previous error messages
$('#building_block_name').removeClass('is-invalid')
$('#building-block-name-error').empty()
$('#building_block_definition').removeClass('is-invalid')
$('#building-block-definition-error').empty()
$('#building_block_structure_id').removeClass('is-invalid')
$('#building-block-structure-error').empty()

# display error message
<% if @errors[:name].present? %>
$('#building-block-name-error')
  .append('<%= @errors[:name].join(" ") %>').show()
$('#building_block_name').addClass('is-invalid')
<% end %>
<% if @errors[:definition].present? %>
$('#building-block-definition-error')
  .append('<%= @errors[:definition].join(" ") %>').show()
$('#building_block_definition').addClass('is-invalid')
<% end %>
<% if @errors[:structure].present? %>
$('#building-block-structure-error')
  .append('<%= @errors[:structure].join(" ") %>').show()
$('#building_block_structure_id').addClass('is-invalid')
<% end %>