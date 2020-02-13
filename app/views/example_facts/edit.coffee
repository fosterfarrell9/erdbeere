$('#example_facts-modal-content').empty()
  .append('<%= j render partial: "example_facts/explanations_form",
                        locals: { example_fact: @example_fact,
                                  satisfied: @satisfied,
                                  available_properties: @available_properties,
                                  from: @from } %>')
$('#example_factsModalLabel').empty()
  .append('<%= t("example_fact.edit.title") %>')
$('#example_factsModal').modal('show')
exampleFactsModalContent = document.getElementById('example_facts-modal-content')
renderMathInElement exampleFactsModalContent,
  delimiters: [
    {
      left: '$$'
      right: '$$'
      display: true
    }
    {
      left: '$'
      right: '$'
      display: false
    }
    {
      left: '\\('
      right: '\\)'
      display: false
    }
    {
      left: '\\['
      right: '\\]'
      display: true
    }
  ]
  ignoredClasses: ['trix-content', 'form-control']
  throwOnError: false