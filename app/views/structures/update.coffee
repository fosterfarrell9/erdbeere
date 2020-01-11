# clean up from previous error messages
$('#structure_name').removeClass('is-invalid')
$('#structure-name-error').empty()

# display error message
<% if @errors[:name].present? %>
$('#structure-name-error')
  .append('<%= @errors[:name].join(" ") %>').show()
$('#structure_name').addClass('is-invalid')
<% end %>