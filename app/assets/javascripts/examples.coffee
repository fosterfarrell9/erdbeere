$(document).on 'turbolinks:load', ->
  $(document).on 'change', '#example-form :input', ->
    $('#example-basics-warning').show()
    return

  $(document).on 'click', '.cancel-example-edit', ->
    location.reload(true)
    return

  $(document).on 'trix-change', '#example-fact-explanation-trix', ->
      $('#example-fact-explanation-preview').html($('#example-fact-explanation-trix').html())
      exampleFactExplanationPreview = document.getElementById('example-fact-explanation-preview')
      renderMathInElement exampleFactExplanationPreview,
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
        throwOnError: false
      return
    return

  return

# clean up everything before turbolinks caches
$(document).on 'turbolinks:before-cache', ->
  $(document).off 'click', '#example-form :input'
  $(document).off 'click', '.cancel-example-edit'
  $(document).off 'trix-change', '#example-fact-explanation-trix'
  return