# clean up from previous error messages
$('#implication-implies-error').empty()
$('#implication-premises-error').empty()
$('#implication-base-error').empty()

# display error message
<% if @errors[:implies].present? %>
$('#implication-implies-error')
  .append('<%= t("activerecord.errors.models.implication.attributes.implies.problem") %>').show()
<% end %>
<% if @errors[:premises].present? %>
$('#implication-premises-error')
  .append('<%= t("activerecord.errors.models.implication.attributes.premises.problem") %>').show()
<% end %>
<% if @errors[:base].present? %>
$('#implication-base-error')
  .append('<%= @errors[:base].join(" ") %>').show()
<% end %>