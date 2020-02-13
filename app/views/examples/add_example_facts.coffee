$('#example-facts-modal-content').empty()
  .append('<%= j render partial: "example_facts/form",
                        locals: { example: @example,
                                  satisfied: @satisfied,
                                  available_properties: @available_properties } %>')
$('#example_factsModalLabel').empty()
  .append('<%= @satisfied ? t("example.add_example_facts.add_truths") : t("example.add_example_facts.add_falsehoods") %>')
$('#example_factsModal').modal('show')