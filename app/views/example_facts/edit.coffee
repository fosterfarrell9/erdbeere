$('#example-facts-modal-content').empty()
  .append('<%= j render partial: "example_facts/explanations_form",
                        locals: { example_fact: @example_fact,
                                  satisfied: @satisfied,
                                  available_properties: @available_properties } %>')
$('#exampleFactsModalLabel').empty()
  .append('<%= t("example_fact.edit.title") %>')
$('#exampleFactsModal').modal('show')
exampleFactsModalContent = document.getElementById('example-facts-modal-content')
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