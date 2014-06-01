jQuery ->



  $selected = []
  $busy = []

  refreshBusy = () ->
    dataRows = oTable._('tr')
    busy_ids = []
    dataRows.forEach (obj, index, array) ->
      if obj.busy
        busy_ids.push obj.id
    setBusy(busy_ids)

  setBusy = (ids) ->
    ids.forEach (val, index, array) ->
     oTable.$("tr[id='#{val}']").addClass('busy')
     position = $busy.indexOf(val)
     unless ~position
       $busy.push val




  ajaxSetBusy = (XMLHttpRequest, textStatus) ->
    console.log "Ajax Response"
    console.log XMLHttpRequest
    console.log textStatus
    setBusy(XMLHttpRequest) if textStatus is "success"
    return


  ajaxRemoveSelected = (XMLHttpRequest, textStatus) ->
    console.log "Ajax Response"
    console.log XMLHttpRequest
    console.log textStatus
    refreshTable()

    return


  ajaxSelectButtonInit = (nButton, oConfig) ->
    $(nButton).addClass "DTTT_disabled"
    $(nButton).addClass "disabled"
    return

  selectAjaxSelectButton = (nButton, oConfig) ->
    if @fnGetSelected().length isnt 0
      $(nButton).removeClass "DTTT_disabled"
      $(nButton).removeClass "disabled"
    else
      $(nButton).addClass "DTTT_disabled"
      $(nButton).addClass "disabled"
    return

  $(".container.inbox-email").on 'click', '#reload_mail', (evt) ->
    #$('#email_table').dataTable().fnReloadAjax();
    $.getJSON $("#reload_mail").data('url'), (data_a) ->
      $that = $(this)
      setTimeout (->
        $that.blur()
        return
      ), 400
      refreshTable()
    return

  $(".container.inbox-email").on 'click', '#reset_mail', (evt) ->
    #$('#email_table').dataTable().fnReloadAjax();
    $.getJSON $("#reset_mail").data('url'), (data_a) ->
      $that = $(this)
      setTimeout (->
        $that.blur()
        return
      ), 400
      refreshTable()
    return

  $(".container.inbox-email").on 'click', '#process_inbox', (evt) ->
    #$('#email_table').dataTable().fnReloadAjax();
    $.getJSON $("#process_inbox").data('url'), (data_a) ->
      $that = $(this)
      setTimeout (->
        $that.blur()
        return
      ), 400
      refreshTable()
    return

  oTable = $("#email_table").dataTable
    sPaginationType: "bootstrap"
    bProcessing: true
    bFilter: true
    iDisplayLength: 25
    sAjaxSource: $('#email_table').data('url-headers')
    fnInitComplete: (oSettings, json) ->
      refreshBusy()
    aaSorting: [[ 3, "desc" ]]
    sDom: "<'row-fluid'<'span6'T><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>"
    oTableTools:
      sRowSelect: "multi",
      fnRowSelected: (nodes) ->
        position = $selected.indexOf(nodes[0].id)
        unless ~position
          $selected.push nodes[0].id
        return
      fnRowDeselected: (nodes) ->
        position = $selected.indexOf(nodes[0].id)
        if ~position
          $selected.splice(position, 1)
        return
      fnPreRowSelect: (e,nodes) ->
        position = $busy.indexOf(nodes[0].id)
        unless ~position
          return true
        return false

      aButtons: [
        "select_all",
        "select_none",
        {
          sExtends: "ajax"
          sButtonText: "Delete"
          fnSelect: selectAjaxSelectButton
          fnInit: ajaxSelectButtonInit
          fnAjaxComplete: ajaxRemoveSelected
          sAjaxUrl: $('#email_table').data('url-delete')
          mColumns: [0]
          bHeader: false
          sNewLine	: ","
          bSelectedOnly: true
        },
        {
          sExtends: "ajax"
          sButtonText: "Archive"
          fnSelect: selectAjaxSelectButton
          fnInit: ajaxSelectButtonInit
          fnAjaxComplete: ajaxRemoveSelected
          sAjaxUrl: $('#email_table').data('url-archive')
          bHeader: false
          mColumns: [0]
          bHeader: false
          sNewLine	: ","
          bSelectedOnly: true
        },
        {
          sExtends: "ajax"
          sButtonText: "Process"
          fnSelect: selectAjaxSelectButton
          fnInit: ajaxSelectButtonInit
          fnAjaxComplete: ajaxSetBusy
          sAjaxUrl: $('#email_table').data('url-process')
          mColumns: [0]
          bHeader: false
          sNewLine	: ","
          bSelectedOnly: true
        }
      ]

    aoColumns: [
      { "sTitle": "Id", "mData": "id", "bVisible": false, "bSearchable": false },#
      { "sTitle": "Busy", "mData": "busy", "bVisible": false, "bSearchable": false },
      { "sTitle": "Date", "mData": "date" },
      { "sTitle": "Subject", "mData": "subject" },
      { "sTitle": "Sender", "mData": "sender_email" },
      { "sTitle": "File", "mData": "attachment_name" },
      { "sTitle": "Size", "mData": "attachment_size" }]

  oTT = TableTools.fnGetInstance( 'email_table' );


  refreshSelectedRow = (element, index, array) ->
    oTT.fnSelect( $("tr[id='#{element}']")[0] );
    console.log $selected
    console.log "Reselecting " + element

    return
  refreshSelectedRows = () ->

    $selected.forEach refreshSelectedRow
    refreshBusy()

  refreshTable = ->
    $('#email_table').dataTable().fnReloadAjax(null,refreshSelectedRows,null)

  $intervalID = setInterval( refreshTable, 30000);
