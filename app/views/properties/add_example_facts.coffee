$('#example-facts-modal-content').empty()
  .append('<%= j render partial: "example_facts/properties_form",
                        locals: { property: @property,
                                  satisfied: @satisfied,
                                  available_examples: @available_examples,
                                  bbr_hash: @bbr_hash } %>')
$('#exampleFactsModalLabel').empty()
  .append('<%= @satisfied ? t("property.add_example_facts.add_positive_examples") : t("property.add_example_facts.add_negative_examples") %>')
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