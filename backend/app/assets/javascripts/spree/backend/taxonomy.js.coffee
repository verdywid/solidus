taxons_template = null

get_taxonomy = ->
  Spree.ajax
    url: "#{Spree.routes.taxonomy_path}?set=nested"

draw_tree = (taxonomy) ->
  $('#taxonomy_tree')
    .html( taxons_template({ taxons: [taxonomy.root] }) )
    .find('ul')
    .sortable
      connectWith: '#taxonomy_tree ul'
      placeholder: 'sortable-placeholder ui-state-highlight'
      tolerance: 'pointer'
      cursorAt: { left: 5 }

redraw_tree = ->
  get_taxonomy().done(draw_tree)

resize_placeholder = (ui) ->
  handleHeight = ui.helper.find('.sortable-handle').outerHeight()
  ui.placeholder.height(handleHeight)

restore_sort_targets = ->
  $('.ui-sortable-over').removeClass('ui-sortable-over')

highlight_sort_targets = (ui) ->
  restore_sort_targets()
  ui.placeholder.parents('ul').addClass('ui-sortable-over')

@setup_taxonomy_tree = (taxonomy_id) ->
  return unless taxonomy_id?
  taxons_template_text = $('#taxons-list-template').text()
  taxons_template = Handlebars.compile(taxons_template_text)
  Handlebars.registerPartial( 'taxons', taxons_template_text )
  redraw_tree()
  $('#taxonomy_tree').on
      sortstart: (e, ui) ->
        resize_placeholder(ui)
      sortover: (e, ui) ->
        highlight_sort_targets(ui)
      sortstop: restore_sort_targets
