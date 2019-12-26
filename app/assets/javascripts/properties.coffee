$(document).on 'turbolinks:load', ->
  $(document).on 'change', '#property-form :input', ->
    $('#property-basics-warning').show()
    return

  $(document).on 'click', '.cancel-property-edit', ->
    location.reload(true)
    return

  trixElement = document.querySelector('#property-definition-trix')
  if trixElement?
    trixElement.addEventListener 'trix-change', ->
      $('#property-basics-warning').show()
      $('#property-definition-preview').html($('#property-definition-trix').html())
      propertyDefinition = document.getElementById('property-definition-preview')
      renderMathInElement propertyDefinition,
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
  $(document).off 'click', '#property-form :input'
  $(document).off 'click', '.cancel-property-edit'
  return