# clean up from previous error messages
$('#property_name').removeClass('is-invalid')
$('#property-name-error').empty()

# display error message
<% if @errors[:name].present? %>
$('#property-name-error')
  .append('<%= @errors[:name].join(" ") %>').show()
$('#property_name').addClass('is-invalid')
<% end %>