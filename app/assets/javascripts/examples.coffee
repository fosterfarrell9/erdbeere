$(document).on 'turbolinks:load', ->
  $(document).on 'change', '#example-form :input', ->
    $('#example-basics-warning').show()
    return

  $(document).on 'click', '.cancel-example-edit', ->
    location.reload(true)
    return
  return

# clean up everything before turbolinks caches
$(document).on 'turbolinks:before-cache', ->
  $(document).off 'click', '#example-form :input'
  $(document).off 'click', '.cancel-example-edit'
  return