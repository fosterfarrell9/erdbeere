$('#example-modal-content').empty()
	.append('<%= j render partial: "examples/modal_form",
												locals: { example: @example } %>')
$('#exampleModal').modal('show')
exampleModalContent = document.getElementById('example-modal-content')
renderMathInElement exampleModalContent,
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