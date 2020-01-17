# clean up from previous error messages
$('#axiom_stuff_w_props').removeClass('is-invalid')
$('#axiom-stuff-error').empty()
$('#axiom_satisfies_id').removeClass('is-invalid')
$('#axiom-satisfies-error').empty()

# display error message
<% if @errors[:atom].present? %>
$('#axiom-stuff-error')
  .append('<%= @errors[:atom].join(" ") %>').show()
$('#axiom_stuff_w_props').addClass('is-invalid')
$('#axiom-satisfies-error')
  .append('<%= @errors[:atom].join(" ") %>').show()
$('#axiom_satisfies_id').addClass('is-invalid')
<% end %>
