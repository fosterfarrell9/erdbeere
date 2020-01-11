# clean up from previous error messages
$('#example_description').removeClass('is-invalid')
$('#example-description-error').empty()

# display error message
<% if @errors[:description].present? %>
$('#example-description-error')
  .append('<%= @errors[:description].join(" ") %>').show()
$('#example_description').addClass('is-invalid')
<% end %>