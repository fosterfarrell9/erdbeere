# clean up from previous error messages
$('#example_description').removeClass('is-invalid')
$('#example-description-error').empty()
$('.building_block_select').removeClass('is-invalid')
$('.building-block-error').empty()

# display error message
<% if @errors[:description].present? %>
$('#example-description-error')
  .append('<%= @errors[:description].join(" ") %>').show()
$('#example_description').addClass('is-invalid')
<% end %>
<% if @errors[:building_block_realizations].present? %>
$('.building-block-error')
  .append('<%= @errors[:building_block_realizations].first %>').show()
$('.building_block_select').addClass('is-invalid')
<% end %>