            <div class="row-fluid sortable">        
              <div class="box span12">
                <div class="box-header well" data-original-title>
                  <h2><i class="fa fa-plug"></i> Setup Device</h2>
                  <div class="box-icon">
                    <a href="#" class="btn btn-setup-devices-setting btn-round"><i class="icon-cog"></i></a>
                    <a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
                    <a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>
                  </div>
                </div>
                <div class="box-content">
                  <table class="display compact" id="setdevicestable" cellspacing="0">
                    <thead>
                      <tr>
                        <th></th>
                        <th>Enabled</th>
                        <th>Device Type</th>
                        <th>Name</th>
                        <th>Description</th>
                      </tr>
                    </thead>  
                  </table>
                  <style>
                  td.details-control {
                      background: url('/img/details_open.png') no-repeat center center;
                      cursor: pointer;
                  }
                  tr.shown td.details-control {
                      background: url('/img/details_close.png') no-repeat center center;
                  }
                  td.DTE_EditorDetails:hover {
                      background-color: white !important;
                  }
                  select, input[type="file"] {
                      height: 22px !important;
                      line-height: 22px;
                      font-size: 11px;
                      margin-bottom: 0px;
                  }
                  select, input[type="text"] {
                      height: 18px;
                      line-height: 18px;
                      font-size: 11px;
                      margin-bottom: 0px;
                  }
                  div.DTE_Inline div.DTE_Inline_Field div.DTE_Form_Buttons button,
                  div.DTE_Inline div.DTE_Inline_Buttons div.DTE_Form_Buttons button {
                      padding: 2px;
                  }
                  div.selectize-dropdown {
                      z-index: 2001;
                  }
                  </style>
                  <script language="javascript">
                  var editor, editorNew;  // 2 Editors, one for inline and one for creating new records in a lightbox.
                  var Editor;
                  var table;
                  
                  (function ()
                   {
                      Editor = $.fn.dataTable.Editor;
                  
                      Editor.display.details = $.extend( true, {}, Editor.models.displayController,
                      {
                  
                          "init": function ( editor )
                          {
                              console.log("Init editor Object is:%o", editor);
                              // No initialisation needed - we will be using DataTables' API to display items
                              return Editor.display.details;
                          },
                  
                          "open": function ( editor, append, callback )
                          {
                              var table = $(editor.s.table).DataTable();
                              var row = editor.s.modifier;

                              // Close any rows which are already open
                              Editor.display.details.close( editor );
                  
                              // Open the child row on the DataTable
                              table
                                  .row( row )
                                  .child( append )
                                  .show();
                  
                              $( table.row( row ).node() ).addClass( 'shown' );
                  
                              if ( callback )
                              {
                                  callback();
                              }
                          },
                  
                          "close": function ( editor, callback )
                          {
                              var table = $(editor.s.table).DataTable();
                  
                              table.rows().every(
                                  function()
                                  {
                                      if ( this.child.isShown() )
                                      {
                                          this.child.hide();
                                          $( this.node() ).removeClass( 'shown' );
                                      }
                                  } );

                              if ( callback )
                              {
                                  callback();
                              }
                          }
                      } );
                   }
                  )();
                  
                  $(document).ready(
                      function()
                      {
                          // General and inline editor.
                          editor = new $.fn.dataTable.Editor( {
                              ajax:    "/dpwr/device",
                              table:   "#setdevicestable",
                              display: "details",
                              fields:  [ {
                                           label: "Enabled",
                                           name:  "device.enabled",
                                           type:  "select"
                                         }, {
                                           label: "Device Type",
                                           name:  "device.driverType",
                                           type:  "readonly"
                                         }, {
                                           label: "Name",
                                           name:  "device.name"
                                         }, {
                                           label: "Description",
                                           name:  "device.description"
                                         }
                                       ]
                          } );

                          // New record editor - need a lightbox.
                          editorNew = new $.fn.dataTable.Editor( {
                              ajax:     "/dpwr/device",
                              table:    "#setdevicestable",
                              display:  "lightbox",
                              timeout:  5000,
                              fields:   [ ]
                          } );

                          // Create a new driver using the Model template.
                          //
                          function loadEditorNew(modelIdx)
                          {
                              var json      = table.ajax.json();
                              var onDisplay = editorNew.displayed();

                              console.log(json);
                              console.log(onDisplay);

                              // First remove fields not available for this device.
                              //
                              for(var idx = 0; idx < onDisplay.length; idx++)
                              {
                                  if(json.model[modelIdx].params[onDisplay[idx].substring(7)] == undefined)
                                  {
                                      editorNew.clear(onDisplay[idx]);
                                  }
                              }
                              onDisplay = editorNew.displayed();
                              console.log(onDisplay);

                              // Add Device Type as the first item if it is not defined.
                              //
                              if(editorNew.field("device.driverType") == undefined)
                              {
                                  editorNew.add( { 
                                                   label:     json.model[modelIdx].params['driverType'].title,
                                                   name:      "device.driverType",
                                                   type:      "select",
                                                   options:   json.model[modelIdx].params['driverType'].choice,
                                                   fieldInfo: json.model[modelIdx].params['driverType'].info
                                                 });
                              }

                              // Next add any specific fields.
                              //
                              for(var item in json.model[modelIdx])
                              {
                                  if(json.model[modelIdx].params[item] == undefined) continue;

                                  if(editorNew.field("device." + item) == undefined)
                                  {
                                      var select = "", attr = { }, opts = { };
                                      var choice = json.model[modelIdx].params[item].choice;
                                      switch(json.model[modelIdx].params[item].varType)
                                      {
                                          case "Choice":
                                              select = "select";
                                              break;

                                          case "ChoiceArray":
                                              select = "selectize";
                                              opts = { width: "95%",
                                                       plugins: ['remove_button'],
                                                       delimiter: ',',
                                                       persist: true,
                                                       allowEmptyOption: true,
                                                       create: function(input)
                                                               {
                                                                   return { value: input, text: input }
                                                               }
                                              },
                                              attr = { multiple: true }; 

                                              // Need to map the Choice field into numbers as visually better to select Port numbers
                                              // than a set of choice field values.
                                              //
                                              choice = [ ];
                                              choice[0] = { label: "None", value: 0 };
                                              for(var idx = 1; idx <= json.model[modelIdx].params[item].elements; idx++)
                                              {
                                                  choice[idx] = { label: idx, value: idx };
                                              }
                                              console.log(choice);
                                              break;

                                          case "Integer":
                                              select = "text";
                                              break;

                                          default:
                                              select = "text";
                                              break;
                                      }

                                      editorNew.add( { 
                                                        label:     json.model[modelIdx].params[item].title,
                                                        name:      "device." + item,
                                                        type:      select,
                                                        opts:      opts,
                                                        attr:      attr,
                                                        options:   choice,
                                                        fieldInfo: json.model[modelIdx].params[item].info,
                                                        fieldMessage: json.model[modelIdx].params[item].info
                                                     });

                                      if(select == "selectize")
                                      {
                                           console.log("Registering field");
                                           selectize = editorNew.field("device." + item).inst();
                                           selectize.on('change',
                                               function() {
                                                              val = editorNew.field("device." + 'locked').val();
                                                              console.log('Field has changed:' + val);
                                                              if(val == '')
                                                              {
                                                                  editorNew.field("device.locked").val("0");
                                                                  console.log('Setting default: 0');
                                                              } else
                                                              {
                                                              console.log(val);
                                                                  var index = val.indexOf("0");
                                                                  if(index > -1 && val.length > 1)
                                                                  {
                                                                      console.log(index);
                                                                      val.splice(index, 1);
                                                                      editorNew.field("device.locked").val(val);
                                                                      console.log('Field after replace:' + val);
                                                                  }
                                                              console.log(val);
                                                              }
                                                          });
                                      }
                                  }
                              }

                              $('select', editorNew.field('device.driverType').node()).on('change',
                                  function()
                                  {
                                      console.log(editorNew.field('device.driverType').val()); 
                                      for(var modelIdx in json.model)
                                      {
                                          if(json.model[modelIdx].driverType == editorNew.field('device.driverType').val())
                                          { 
                                              loadEditorNew(modelIdx);
                                          }
                                      }
                                  });
                          }

                          // When the new button is pressed, load up the fields into the editor based on the first row.
                          //
                          editorNew.on('open',
                              function()
                              {
                                  loadEditorNew(0);
                              });
                  
                          // Define the basic table view showing key information, full information is via a details expansion.
                          //
                          table = $('#setdevicestable').DataTable( {
                              dom:      "Bfrtip",
                              ajax:     "/dpwr/device?cmd=get",
                              columns:  [ {
                                            className:      'details-control',
                                            orderable:      false,
                                            data:           null,
                                            defaultContent: ''
                                          },
                                          { 
                                            data:           "device.enabled"
                                          },
                                          {
                                            data:           "device.driverType",
                                            type:           "readonly"
                                          },
                                          {
                                            data:           "device.name"
                                          },
                                          {
                                            data:           "device.description"
                                          }
                                        ],
                              "order":  [ [1, 'asc'] ],
                              select:   true,
                              buttons:  [ { 
                                            text:           "Add Device",
                                            extend:         "create",
                                            editor:         editorNew
                                          },
                                          {
                                            text:           "Delete",
                                            extend:         "remove", 
                                            editor:         editorNew
                                          }
                                        ]
                              } );

                      $('#setdevicestable').on( 'click', 'tbody td:not(:first-child)',
                          function(e)
                          {
                              var table = $(editor.s.table).DataTable();
                              var idx = table.cell( this ).index().column;
                              var tr   = this.parentNode;

                              // If the detail is open, then no inline editting allowed.
                              if( table.row( tr ).child.isShown() )
                              {
                                  return;
                              }

                              // We cant edit/change the driver type, so exit if this is chosen.
                              //
                              if(table.column(idx).dataSrc().substring(7) == "driverType")
                              {
                                  return;
                              }

                              // Close any expanded detail as we intend to edit key fields only.
                              //
                              table.rows().every(
                                  function()
                                  {
                                      if ( this.child.isShown() )
                                      {
                                          this.child.hide();
                                          $( this.node() ).removeClass( 'shown' );
                                      }
                                  } );

                              // Show the driverType for inline editting.
                              editor.show("device.driverType");
                  
                              // Setup the inline editor to allow individual changes to data items.
                              //
                              editor.inline(this, {   buttons: {
                                                                   label: '&gt;',
                                                                   fn: function()
                                                                       {
                                                                           this.submit(function()
                                                                                       {
                                                                                           //alert('success');
                                                                                       },
                                                                                       function()
                                                                                       {
                                                                                           alert('error');
                                                                                       },
                                                                                       function()
                                                                                       {
                                                                                           console.log(this);
                                                                                       }
                                                                                      );
                                                                       }
                                                               },
                                                      submit: 'allIfChanged'
                                                  });
                          } );
                  
                      $('#setdevicestable').on( 'click', 'td.details-control',
                          function()
                          {
                              var tr   = this.parentNode;
                              var row  = table.row(tr).data();
                              var json = table.ajax.json();

                              console.log("table row is:%o", table.row(tr));
                              console.log("TR is:%o", tr);
                              console.log("Row is:%o", row);
                              console.log("JSON is:%o", json);
                  
                              if( table.row( tr ).child.isShown() )
                              //if ( row.child.isShown() )
                              {
                                  editor.close();
                              } else
                              {
                                  var onDisplay = editor.fields();

                                  for(var modelIdx in json.model)
                                  {
                                      if(json.model[modelIdx].driverType == row.device.driverType)
                                      { 
                                          // Remove fields not available for this device, only add new fields.
                                          //
                                          for(var idx = 0; idx < onDisplay.length; idx++)
                                          {
                                              if(json.model[modelIdx].params[onDisplay[idx].substring(7)] == undefined)
                                              {
                                                  editor.clear(onDisplay[idx]);
                                              }
                                          }
                                          onDisplay = editor.fields();
                                          console.log(onDisplay);

                                          for(var item in json.model[modelIdx].params)
                                          {
                                              var select = "", attr = { }, opts = { };
                                              var choice = json.model[modelIdx].params[item].choice;

                                              // Changing of the driver is not possible, so hide it.
                                              if(item == "driverType") { editor.hide("device."+item); continue;}

                                              // Skip existing fields, dont need to add.
                                              if(onDisplay.indexOf("device." + item) != -1) { continue; }

                                              switch(json.model[modelIdx].params[item].varType)
                                              {
                                                  case "Choice":
                                                      select = "select";
                                                      break;

                                                  case "ChoiceArray":
                                                      select = "selectize";
                                                      opts = { width: "95%",
                                                               plugins: ['remove_button'],
                                                               delimiter: ',',
                                                               persist: true,
                                                               allowEmptyOption: true,
                                                               create: function(input)
                                                                       {
                                                                           return { value: input, text: input }
                                                                       }
                                                      },
                                                      attr = { multiple: true }; 
        
                                                      // Need to map the Choice field into numbers as visually better to select Port numbers
                                                      // than a set of choice field values.
                                                      //
                                                      choice = [ ];
                                                      choice[0] = { label: "None", value: 0 };
                                                      for(var idx = 1; idx <= json.model[modelIdx].params[item].elements; idx++)
                                                      {
                                                          choice[idx] = { label: idx, value: idx };
                                                      }
                                                      console.log(choice);
                                                      break;

                                                  case "Integer":
                                                      select = "text";
                                                      break;

                                                  default:
                                                      select = "text";
                                                      break;
                                              }

                                              //alert(select + "=>" + "device." + item + "=>" + json.model.device.params[item].title);
                                              editor.add( { 
                                                                label:     json.model[modelIdx].params[item].title,
                                                                name:      "device." + item,
                                                                type:      select,
                                                                opts:      opts,
                                                                attr:      attr,
                                                                options:   choice,
                                                                fieldInfo: json.model[modelIdx].params[item].info,
                                                                fieldMessage: json.model[modelIdx].params[item].info
                                                             });

                                              if(select == "selectize")
                                              {
                                                   console.log("Registering field");
                                                   //$field = $('[data-selectize]').selectize();
                                                   selectize = editor.field("device." + item).inst();
                                                   selectize.on('change',
                                                       function() {
                                                                      val = editor.field("device." + 'locked').val();
                                                                      console.log('Field has changed:' + val);
                                                                      if(val == '')
                                                                      {
                                                                          editor.field("device.locked").val("0");
                                                                          console.log('Setting default: 0');
                                                                      } else
                                                                      {
                                                                      console.log(val);
                                                                          var index = val.indexOf("0");
                                                                          if(index > -1 && val.length > 1)
                                                                          {
                                                                              console.log(index);
                                                                              val.splice(index, 1);
                                                                              editor.field("device.locked").val(val);
                                                                              console.log('Field after replace:' + val);
                                                                          }
                                                                      console.log(val);
                                                                      }
                                                                  });
                                              }
                                          }

                                          editor.edit(
                                              tr,
                                              '',
                                              [
                                                  {
                                                      "label":     "Update",
                                                      "fn":        function()
                                                                   {
                                                                       console.log(editor);
                                                                       editor.submit();
                                                                   }
                                                  }
                                              ]
                                          );
                                      }
                                  }
                              }
                          } );

                          // Settings Menu Button Modal - See Modals.jsp for definition.
                          //
                          $(document).on('click', '.btn-setup-devices-setting', function(e)
                          {
                              e.preventDefault();
                              $('#id_setupDevicesModal').modal('show');
                          });
                      } );
                  </script>
                </div>
              </div><!--span-->
            </div><!--row-fluid -->
