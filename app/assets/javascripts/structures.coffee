$(document).on 'turbolinks:load', ->
  $(document).on 'change', '#structure-form :input', ->
    $('#structure-basics-warning').show()
    return

  $(document).on 'change', '.atomStuffWProps', ->
    id = $(this).data('id')
    value = $(this).val()
    props = $(this).closest('form').data('properties')
    select = $('.atomSatisfies[data-id="'+id+'"]').get(0)
    select.options.length = 1
    for option in props[value]
      new_option = document.createElement('option')
      new_option.value = option[1]
      new_option.text = option[0]
      select.add(new_option, null)
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