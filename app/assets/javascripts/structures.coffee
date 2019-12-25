$(document).on 'turbolinks:load', ->
  $(document).on 'change', '#structure-form :input', ->
    $('#structure-basics-warning').show()
    return

  $(document).on 'click', '.cancel-structure-edit', ->
    location.reload(true)
    return

  trixElement = document.querySelector('#structure-definition-trix')
  if trixElement?
    trixElement.addEventListener 'trix-change', ->
      $('#structure-basics-warning').show()
      $('#structure-definition-preview').html($('#structure-definition-trix').html())
      structureDefinition = document.getElementById('structure-definition-preview')
      renderMathInElement structureDefinition,
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
  $(document).off 'click', '#structure-form :input'
  $(document).off 'click', '.cancel-structure-edit'
  return