/*!
 * user.js v1.0.0
 * Copyright 2011-2014 Philip Smart.
 */

if (typeof jQuery === 'undefined') { throw new Error('Bootstrap\'s JavaScript requires jQuery') }

var maxPinger=9;

/* ========================================================================
 * user.js: 
 * ========================================================================
*/
function executeFunctionByName(functionName, context /*, args */)
{
    var args = [].slice.call(arguments).splice(2);
    var namespaces = functionName.split(".");
    var func = namespaces.pop();
    for(var i = 0; i < namespaces.length; i++)
    {
        context = context[namespaces[i]];
    }
    return context[func].apply(this, args);
}

/* Modal Manager - change default spinner.
*/
$.fn.modal.defaults.spinner = $.fn.modalmanager.defaults.spinner = 
    '<div class="loading-spinner" style="width: 200px; margin-left: -100px;">' +
        '<div class="progress progress-striped active">' +
            '<div class="progress-bar" style="width: 100%;"></div>' +
        '</div>' +
    '</div>';

//-------------------------------------------------------------------------------------------------------
// GENERAL - Code used by all pages.
//-------------------------------------------------------------------------------------------------------

// Function to set initial state of menu tree - all closed except for active tree.
//
function openActiveMenu()
{
    $('ul.tree').each(
      function()
      {
          if($(this).children('li.active').length == 0)
          {
              $(this).slideUp(200);
          }
      });
}

// Method to set to active the given item, based on its url.
//
function setActiveMenu(menuItem)
{
    // Firstly, remove any old active selections.
    //
    //$('ul.tree').children('li.active').removeClass('active');

    // Now search for the required item and set it active.
    //
    $('li a').each(
      function()
      {
          if($(this).data('url') == menuItem)
          {
              //if($(this).hasClass('accordion-menu'))
             // {
                  $(this).parent().addClass('active');
              //} else
              //{
               //   $(this).parent().addClass('active');
              //}
          } else
          {
              $(this).parent().removeClass("active");
          }
      });
}
    
function updateBreadCrumb()
{
    var html = ""; // = "<li><a data-url=\"dashboard.jsp\" class=\"ajaxload\">Home</a>";

    // First level.
    //
    $('li a.nav-header').each(
        function()
        {
            if($(this).parent().hasClass('active'))
            {
                html =  "<li><a data-url=\"" + $(this).data('url') + "\" class=\"ajaxload\">";
                html += $(this).parent().find("span").first().text() + "</a>";
                return false;
            }
        }
    );

    // Sub-menu level.
    //
    if(html == "")
    {
        html = "<li><a data-url=\"dashboard.jsp\" class=\"ajaxload\">Home</a>";
        $('ul.tree').each(
          function()
          {
              if($(this).children('li.active').length > 0)
              {
                  html += "<span class=\"divider\">/</span>";
                  html += $(this).parent().find("span").first().text();
                  html += "<span class=\"divider\">/</span>";
                  html += "<a data-url=\"" + $(this).find("li.active a").data('url') + "\" class=\"ajaxload\">";
                  html += $(this).parent().find("li.active span").first().text() + "</a>";
                  return false;
              }
          });
    }
    
    html += "</li>";
    //alert(html);
    return(html);
}

// Method to change the current theme.
//
function switchTheme(theme_name)
{
    $('#bs-css').attr('href','css/bootstrap-theme/bootstrap-'+theme_name+'.css');
}

// Method to use an ajax call to reload the main content display area.
//
function loadContent(url)
{
    // Set the cookie to the requested page, preserving the location for a refresh or next re-open of
    // the browser.
    //
    $.cookie('MainPage',url,{expires:365});

    // Use ajax to load into the content div.
    //
    $("#mainpage").load(url,
        function()
        {
            // Initialise the table and draw.
            //
            if( $('table.setoutputtable').length > 0 && ! $.fn.DataTable.isDataTable('.setoutputtable') )
            {
                var rowsPerPage = $.cookie('SetOutputRowsPerPage')==null ? 10 :$.cookie('SetOutputRowsPerPage');

                // Event on changes to the table property, need to store the rows per page.
                //
                $('.setoutputtable').on('length.dt', 
                    function()
                    {
                        // Store the selected rows per page as a cookie.
                        //
                        var info = $('.setoutputtable').DataTable().page.info();
                        $.cookie('SetOutputRowsPerPage',info.length,{expires:365});
                    });

                // Setup the paging options of the table.
                //
                $('.setoutputtable').dataTable( {
                    "lengthMenu": [ [5, 10, 25, 50, -1], [5, 10, 25, 50, "All"] ],
                    "pageLength": rowsPerPage
                });

                $('.setoutputtable').DataTable();
            }
            if( $('table.readinputtable').length > 0 && ! $.fn.DataTable.isDataTable('.readinputtable') )
            {
                var rowsPerPage = $.cookie('ReadInputRowsPerPage')==null ? 10 :$.cookie('ReadInputRowsPerPage');

                // Event on changes to the table property, need to store the rows per page.
                //
                $('.readinputtable').on('length.dt', 
                    function()
                    {
                        // Store the selected rows per page as a cookie.
                        //
                        var info = $('.readinputtable').DataTable().page.info();
                        $.cookie('ReadInputRowsPerPage',info.length,{expires:365});
                    });

                // Setup the paging options of the table.
                //
                $('.readinputtable').dataTable( {
                    "lengthMenu": [ [5, 10, 25, 50, -1], [5, 10, 25, 50, "All"] ],
                    "pageLength": rowsPerPage
                });

                $('.readinputtable').DataTable();
            }

            // Ensure the menu is opened and the correct choice activated.
            //
            setActiveMenu(url);

            // Update the breadcrumb trail to current menu selection.
            //
            $('#breadcrumb').html(updateBreadCrumb());

            openActiveMenu();
        }
    );
}

// Method to use an ajax call to reload the modals.
//
function loadModal(url)
{
    // Use ajax to load into the content div.
    //
    $("#modal").load(url,
        function()
        {
        }
    );
}

$(document).on('click', '.btn-close',
    function(e)
    {
        e.preventDefault();
        $(this).parent().parent().parent().fadeOut();
    });

$(document).on('click', '.btn-minimize',
    function(e)
    {
        e.preventDefault();
        var $target = $(this).parent().parent().next('.box-content');
        if($target.is(':visible')) $('i',$(this)).removeClass('icon-chevron-up').addClass('icon-chevron-down');
        else                        $('i',$(this)).removeClass('icon-chevron-down').addClass('icon-chevron-up');
        $target.slideToggle();
    });
    
/*$(document).on('click', ".accordion-menu-indent", 
    function()
    {
        $('.accordion-menu').parent().removeClass('active');
        $('ul.tree').children('li.active').removeClass('active');
        $(this).parent().addClass('active');
        var url = $(this).data('url');
        loadContent(url);
    }
);*/
    
/*$(document).on('click', ".accordion-menu", 
    function()
    {
        $('.accordion-menu').parent().removeClass('active');
        $('ul.tree').children('li.active').removeClass('active');
        $(this).parent().addClass('active');
        var url = $(this).data('url');
        loadContent(url);
//        $("#mainpage").load(url,
//            function()
//            {
//            });
    }
);*/

$(document).on('click', ".ajaxload", 
    function()
    {
        var url = $(this).data('url');
        loadContent(url);
    }
);

// Ajaxify menus
$(document).on('click', "a.ajax-link", 
    function(e)
    {
        if($.browser.msie) e.which=1;
        if(e.which!=1 || !$('#is-ajax').prop('checked') || $(this).parent().hasClass('active')) return;
        e.preventDefault();
        if($('.btn-navbar').is(':visible'))
        {
            $('.btn-navbar').click();
        }
        $('#loading').remove();
        $('#content').fadeOut().parent().append('<div id="loading" class="center">Loading...<div class="center"></div></div>');
        var $clink=$(this);
        History.pushState(null, null, $clink.attr('href'));
        $('ul.main-menu li.active').removeClass('active');
        $clink.parent('li').addClass('active');    
    }
);
            
$(document).on('click', ".accordion > a",
    function(e)
    {
        e.preventDefault();
        var $ul = $(this).siblings('ul');
        var $a = $(this).siblings('a');
        var $li = $(this).parent();
        if ($ul.is(':visible')) $li.removeClass('active');
        else                    $li.addClass('active');
        $a.removeClass('icon-plus');
        $ul.slideToggle();
    }
);

$(document).on('click', "#themes a",
    function(e)
    {
        e.preventDefault();
        currentTheme=$(this).attr('data-value');
        $.cookie('CurrentTheme',currentTheme,{expires:365});
        switchTheme(currentTheme);
        $('#themes i').removeClass('icon-ok');
        $(this).find('i').addClass('icon-ok');
    }
);

$(document).on('click', ".themeselect",
    function(e)
    {
        chosenTheme=$(this).attr('data-value');
        $.cookie('CurrentTheme',chosenTheme,{expires:365});
        switchTheme(chosenTheme);

        $('li.theme').each(
            function()
            {
                if($(this).children('span.themeselect').attr('data-value') == chosenTheme)
                {
                    $(this).children('span.themeselect').html("<i class='fa fa-check-square-o'></i>");
                    $(this).addClass('active');
                } else
                {
                    $(this).children('span.themeselect').html("<i class='fa fa-square-o'></i>");
                    $(this).removeClass('active');
                }
        });

        $.ajax(
        {
            type: 'POST',
            dataType: 'json',
            cache: false,
            data: {
                ACTION: "SETTHEME",
                THEME: chosenTheme
            },
            url: '/dpwr',
            success:
                function (msg)
                {
                    if(msg)
                    {
                        alert(msg);
                    }
                }
        }); 

    });

function documentReady()
{
    // Set up necessary functions to display the Date and Time in marked location on the browser screen.
    //
    // Create two variable with the names of the months and days in an array
    var monthNames = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]; 
    var dayNames= ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

    // Create a newDate() object
    var newDate = new Date();

    // Extract the current date from Date object
    newDate.setDate(newDate.getDate());

    // Output the day, date, month and year   
    $('#Date').html(dayNames[newDate.getDay()] + " " + newDate.getDate() + ' ' + monthNames[newDate.getMonth()] + ' ' + newDate.getFullYear());

    // Setup timers to update the Hours, Minutes and Seconds display.
    //
    setInterval(
        function()
        {
            // Create a newDate() object and extract the seconds of the current time on the visitor's
            var seconds = new Date().getSeconds();

            // Add a leading zero to seconds value
            $("#sec").html(( seconds < 10 ? "0" : "" ) + seconds);
        }, 1000);
    // 
    setInterval(
        function()
        {
            // Create a newDate() object and extract the minutes of the current time on the visitor's
            var minutes = new Date().getMinutes();

            // Add a leading zero to the minutes value
            $("#min").html(( minutes < 10 ? "0" : "" ) + minutes);
        }, 1000);
    //
    setInterval(
        function()
        {
            // Create a newDate() object and extract the hours of the current time on the visitor's
            var hours = new Date().getHours();
    
            // Add a leading zero to the hours value
            $("#hours").html(( hours < 10 ? "0" : "" ) + hours);
        }, 1000);

    // Highlight current / active link
    $('ul.main-menu li a').each(
        function()
        {
            if($($(this))[0].href==String(window.location))
            $(this).parent().addClass('active');
        });

    // Setup the auto-logout timer.
    //
    var autologout;

    var autologout_time = $('#id_ifHiddenHttpSessionTimeout').val();
    if(autologout_time === undefined)
    {
        autologout_time = 60;
    }
    var autologout_enable = $('#id_ifHiddenLoggedIn').val();
    if(autologout_enable === undefined)
    {
        autologout_enable = 0;
    }
            
    // Convert to milliseconds.
    //
    autologout_time = autologout_time * 1000;

    // If a user is logged in, enable logout timer.
    //
    if(autologout_enable == 1)
    {
        autologout = setTimeout(function(){ autoLogout(); }, autologout_time);
    }

    function autoLogout()
    {
        clearTimeout(autologout);
        autologout = setTimeout(function(){ autoLogout(); }, autologout_time);
        window.open('getpage?autologout', '_top');
    }

    // Setup the forward url timer.
    //
    var forward;
    var forward_url = $('#id_ifHiddenForwardUrl').val();
    if(forward_url === undefined)
    {
        forward_url = "";
    }
    var forward_time = $('#id_ifHiddenForwardTime').val();
    if(forward_time === undefined)
    {
        forward_time = 0;
    }

    // Convert to milliseconds.
    //
    forward_time = forward_time * 1000;

    // If values have been provided, setup the forwarding url timer.
    //
    if(forward_url !== "" && forward_time != 0)
    {
        forward = setTimeout(function(){ forwardUrl(); }, forward_time);
    }

    // When timeout occurs, open the forwarding url.
    //
    function forwardUrl()
    {
        window.open(forward_url, '_top');
    }

    // If a cookie doesnt exist with a selected theme, use Cerulean.
    //
    var currentTheme = $.cookie('CurrentTheme')==null ? 'cerulean' :$.cookie('CurrentTheme');
    switchTheme(currentTheme);
            
    $('#themes a[data-value="'+currentTheme+'"]').find('i').addClass('icon-ok');

    // Ajax menu checkbox
    $('#is-ajax').click(
        function(e)
        {
            $.cookie('is-ajax',$(this).prop('checked'),{expires:365});
        });
    $('#is-ajax').prop('checked',$.cookie('is-ajax')==='true' ? true : false);

    $('.accordion li.active:first').parents('ul').slideDown();
            
    // Animating menus on hover
    //
    $('ul.main-menu li:not(.nav-header) span:not(.themeselect)').hover(
        function()
        {
            $(this).animate({'margin-left':'+=3'},200);
        },
        function()
        {
            $(this).animate({'margin-left':'-=3'},200);
        }
    );

    // Prevent # links from moving to top
    $('a[href="#"][data-top!=true]').click(
        function(e)
        {
            e.preventDefault();
        }
    );

    // Function to open a menu tree if clicked on.
    //
    $('.tree-toggle').click(
        function()
        {
            $(this).parent().children('ul.tree').toggle(200);
        }
    );

    // Initial close the menu tree.
    //
    //openActiveMenu();

    // Delayed function to show the menu After the canvas has compressed to make way for it.
    //
    function show_menu()
    {
      var leftmenu = $('#leftmenu');
      leftmenu.show();
    }
  
    // If the Toggle Menu button is activated, un/compress the canvas and show/hide the menu.
    //
    $('[data-toggle="offcanvas"]').click(
        function()
        {
            $('#wrapper').toggleClass('toggled');

            var leftmenu = $('#leftmenu');
            if (leftmenu.hasClass('active'))
            {
                leftmenu.removeClass('active');
                leftmenu.hide();
            } else
            {
                leftmenu.addClass('active');
                var result;
                result = setTimeout(function(){ show_menu(); }, 300);
            }
        });  
};

//--------------------------------------- END OF GENERAL CODE -------------------------------------------



//-------------------------------------------------------------------------------------------------------
// SETTINGS - Code to aid forms in the Settings Menu Option.
//-------------------------------------------------------------------------------------------------------

    // SETTINGS - Email service selector.
    //
    $(function()
    {
        var noneKey = "";
        var smtpKey = "";
        var pop3Key = "";
    
        $('.mail-selector').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            //alert("mail-selector - VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);
    
            // Setup key Id values.
            //
            var pos = e.id.indexOf("NONE") + e.id.indexOf("SMTP") + e.id.indexOf("POP3") + 2;
            noneKey = e.id.substring(0, pos) + "NONE";
            smtpKey = e.id.substring(0, pos) + "SMTP";
            pop3Key = e.id.substring(0, pos) + "POP3";
    
            // Remove active/inactive classes en-masse.
            //
            $('#' + noneKey).removeClass('btn-grey');
            $('#' + noneKey).removeClass('btn-green');
            $('#' + noneKey).removeClass('active');
            $('#' + smtpKey).removeClass('btn-grey');
            $('#' + smtpKey).removeClass('btn-green');
            $('#' + smtpKey).removeClass('active');
            $('#' + pop3Key).removeClass('btn-grey');
            $('#' + pop3Key).removeClass('btn-green');
            $('#' + pop3Key).removeClass('active');
    
            // Flip state and button according to click input. NONE->SMTP->POP3
            //
            if(e.id === noneKey)
            {
                // Disable input fields as they are not needed when no email service is selected.
                //
                $('#id_ifMailServer').prop('disabled', true);
                $('#id_ifMailServerPort').prop('disabled', true);
                $('#id_ifPop3Server').prop('disabled', true);
                $('#id_ifPop3ServerPort').prop('disabled', true);
                $('#id_ifUserName').prop('disabled', true);
                $('#id_ifPassword').prop('disabled', true);
                $('#id_ifSender').prop('disabled', true);
                $('#id_ifRecipient1').prop('disabled', true);
                $('#id_ifRecipient2').prop('disabled', true);
                $('#id_ifRecipient3').prop('disabled', true);
                $('#id_ifSubject').prop('disabled', true);
                $('#id_ifMailBody').prop('disabled', true);
    
                $("#" + $(this).attr("id")).prop('value', 'NONE');
                $('#' + noneKey).addClass('btn-green');
                $('#' + noneKey).addClass('active');
                $('#' + smtpKey).addClass('btn-grey');
                $('#' + pop3Key).addClass('btn-grey');
            } else
            if(e.id == smtpKey)
            {
                // Disable/Enable input fields suitable for SMTP setup.
                //
                $('#id_ifMailServer').prop('disabled', false);
                $('#id_ifMailServerPort').prop('disabled', false);
                $('#id_ifPop3Server').prop('disabled', true);
                $('#id_ifPop3ServerPort').prop('disabled', true);
                $('#id_ifUserName').prop('disabled', false);
                $('#id_ifPassword').prop('disabled', false);
                $('#id_ifSender').prop('disabled', false);
                $('#id_ifRecipient1').prop('disabled', false);
                $('#id_ifRecipient2').prop('disabled', false);
                $('#id_ifRecipient3').prop('disabled', false);
                $('#id_ifSubject').prop('disabled', false);
                $('#id_ifMailBody').prop('disabled', false);
    
                $('#' + $(this).attr("id")).prop('value', 'SMTP');
                $('#' + noneKey).addClass('btn-grey');
                $('#' + smtpKey).addClass('btn-green');
                $('#' + smtpKey).addClass('active');
                $('#' + pop3Key).addClass('btn-grey');
            } else
            {
                // Disable/Enable input fields suitable for POP3 setup.
                //
                $('#id_ifMailServer').prop('disabled', true);
                $('#id_ifMailServerPort').prop('disabled', true);
                $('#id_ifPop3Server').prop('disabled', false);
                $('#id_ifPop3ServerPort').prop('disabled', false);
                $('#id_ifUserName').prop('disabled', false);
                $('#id_ifPassword').prop('disabled', false);
                $('#id_ifSender').prop('disabled', false);
                $('#id_ifRecipient1').prop('disabled', false);
                $('#id_ifRecipient2').prop('disabled', false);
                $('#id_ifRecipient3').prop('disabled', false);
                $('#id_ifSubject').prop('disabled', false);
                $('#id_ifMailBody').prop('disabled', false);
    
                $('#' + $(this).attr("id")).prop('value', 'POP3');
                $('#' + noneKey).addClass('btn-grey');
                $('#' + smtpKey).addClass('btn-grey');
                $('#' + pop3Key).addClass('btn-green');
                $('#' + pop3Key).addClass('active');
            }
    
            // Dont POST on this event, return FALSE to prevent it.
            //
            return false;
        });
    
        // Method to validate data, enrich and post.
        //
        $('#id_formChangeEmail').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // Get name of key pressed.
            //
            $keyValue = $('#' + e.id).attr("value");
    
            //alert("KEYVALUE="+ $keyValue + ", " + "VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);
    
            // Enrich the POST return message.
            //
            var params = [
              {
                name: "ACTION",
                value: $keyValue === "CANCEL" ? "CANCEL" : "SET_EMAIL"
              },
              {
                name: "MODE",
                value: $('#id_ifMailSelector').attr("value")
              }
            ];
            $.each(params, function(i,param)
                           {
                               $('<input />').attr('type', 'hidden')
                                   .attr('name', param.name)
                                   .attr('value', param.value)
                                   .appendTo(document.forms['id_formChangeEmail']);
                           });
    
            return true;
        });
    });
    
    // SETTINGS - Password Change service.
    //
    $(function()
    {
        // Method to validate data, enrich and post.
        //
        $('#id_formChangePassword').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // Get name of key pressed.
            //
            $keyValue = $('#' + e.id).attr("value");
    
            //alert("KEYVALUE="+ $keyValue + ", " + "VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);
    
            // Enrich the POST return message.
            //
            var params = [
              {
                name: "ACTION",
                value: $keyValue === "CANCEL" ? "CANCEL" : "SET_PASSWORD"
              }
            ];
            $.each(params, function(i,param)
                           {
                               $('<input />').attr('type', 'hidden')
                                   .attr('name', param.name)
                                   .attr('value', param.value)
                                   .appendTo(document.forms['id_formChangePassword']);
                           });
    
            return true;
        });
    });
    
    // SETTINGS - Time service selector.
    //
    $(function()
    {
        var localKey = "";
        var ntpKey = "";
    
        $('.time-selector').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            //alert("VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);
    
            // Setup key Id values.
            //
            var pos  = e.id.indexOf("LOCAL") + e.id.indexOf("NTP") + 1;
            localKey = e.id.substring(0, pos) + "LOCAL";
            ntpKey   = e.id.substring(0, pos) + "NTP";
    
            // Remove active/inactive classes en-masse.
            //
            $('#' + localKey).removeClass('btn-grey');
            $('#' + localKey).removeClass('btn-green');
            $('#' + localKey).removeClass('active');
            $('#' + ntpKey).removeClass('btn-grey');
            $('#' + ntpKey).removeClass('btn-green');
            $('#' + ntpKey).removeClass('active');
    
            // Flip state and button according to click input. LOCAL->NTP
            //
            if(e.id === localKey)
            {
                $('#id_ifLocalDate').prop('disabled', false);
                $('#id_ifLocalTime').prop('disabled', false);
                $('#id_ifNtpServerIP').prop('disabled', true);
                $("#" + $(this).attr("id")).prop('value', 'LOCAL');
                $('#' + localKey).addClass('btn-green');
                $('#' + localKey).addClass('active');
                $('#' + ntpKey).addClass('btn-grey');
            } else
            {
                $('#id_ifLocalDate').prop('disabled', true);
                $('#id_ifLocalTime').prop('disabled', true);
                $('#id_ifNtpServerIP').prop('disabled', false);
                $('#' + $(this).attr("id")).prop('value', 'NTP');
                $('#' + localKey).addClass('btn-grey');
                $('#' + ntpKey).addClass('btn-green');
                $('#' + ntpKey).addClass('active');
            }
    
            // Dont POST on this event, return FALSE to prevent it.
            //
            return false;
        });
    
        // Method to validate data, enrich and post.
        //
        $('#id_formChangeTime').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // Get name of key pressed.
            //
            $keyValue = $('#' + e.id).attr("value");
    
            //alert("KEYVALUE="+ $keyValue + ", " + "VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);
    
            // Enrich the POST return message.
            //
            var params = [
              {
                name: "ACTION",
                value: $keyValue === "CANCEL" ? "CANCEL" : "SET_TIME"
              },
              {
                name: "MODE",
                value: $('#id_ifTimeSelector').attr("value")
              },
              {
                name: "NTP_TIMEZONE_ID",
                value: $('#id_ifTimeZone option:selected').attr("data-timeZoneId")
              },
              {
                name: "NTP_TIMEZONE_DST",
                value: $('#id_ifTimeZone option:selected').attr("data-useDaylightTime")
              }
            ];
            $.each(params, function(i,param)
                           {
                               $('<input />').attr('type', 'hidden')
                                   .attr('name', param.name)
                                   .attr('value', param.value)
                                   .appendTo(document.forms['id_formChangeTime']);
                           });
    
            return true;
        });
    });
    
    // SETTINGS - DDNS service selector.
    //
    $(function()
    {
        var localKey = "";
        var ntpKey = "";
        var $keyValue = "";
    
        $('.ddns-selector').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // Get name of key pressed.
            //
            //$keyValue = $('#' + e.id).attr("value");
    
            //alert("KEYVALUE="+ $keyValue + ", " + "VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);
    
            // Setup key Id values.
            //
            var pos  = e.id.indexOf("DISABLED") + e.id.indexOf("ENABLED") + 1;
            disabledKey = e.id.substring(0, pos) + "DISABLED";
            enabledKey  = e.id.substring(0, pos) + "ENABLED";
    
            // Remove active/inactive classes en-masse.
            //
            $('#' + disabledKey).removeClass('btn-grey');
            $('#' + disabledKey).removeClass('btn-green');
            $('#' + disabledKey).removeClass('active');
            $('#' + enabledKey).removeClass('btn-grey');
            $('#' + enabledKey).removeClass('btn-green');
            $('#' + enabledKey).removeClass('active');
    
            // Flip state and button according to click input. DISABLED->ENABLED
            //
            if(e.id === disabledKey)
            {
                $('#id_ifProxyIP').prop('disabled', true);
                $('#if_ifProxyPort').prop('disabled', true);
                if(e.id.indexOf("Proxy") == -1)
                {
                    $('#id_ifServerIP').prop('disabled', true);
                    $('#id_ifClientDomain').prop('disabled', true);
                    $('#id_ifClientUserName').prop('disabled', true);
                    $('#id_ifClientPassword').prop('disabled', true);
                    $('#id_ifDDNSProxySelector_DISABLED').prop('disabled', true);
                    $('#id_ifDDNSProxySelector_ENABLED').prop('disabled', true);
                }
    
                $("#" + $(this).attr("id")).prop('value', 'DISABLED');
                $('#' + disabledKey).addClass('btn-green');
                $('#' + disabledKey).addClass('active');
                $('#' + enabledKey).addClass('btn-grey');
            } else
            {
                if(e.id.indexOf("Proxy") != -1)
                {
                    $('#id_ifProxyIP').prop('disabled', false);
                    $('#id_ifProxyPort').prop('disabled', false);
                } else
                {
                    $('#id_ifServerIP').prop('disabled', false);
                    $('#id_ifClientDomain').prop('disabled', false);
                    $('#id_ifClientUserName').prop('disabled', false);
                    $('#id_ifClientPassword').prop('disabled', false);
                    $('#id_ifDDNSProxySelector_DISABLED').prop('disabled', false);
                    $('#id_ifDDNSProxySelector_ENABLED').prop('disabled', false);
                    if($('#id_ifDDNSProxySelector').attr('value') === 'ENABLED')
                    {
                        $('#id_ifProxyIP').prop('disabled', false);
                        $('#id_ifProxyPort').prop('disabled', false);
                    }
                }
    
                $('#' + $(this).attr("id")).prop('value', 'ENABLED');
                $('#' + disabledKey).addClass('btn-grey');
                $('#' + enabledKey).addClass('btn-green');
                $('#' + enabledKey).addClass('active');
            }
    
            // Dont POST on this event, return FALSE to prevent it.
            //
            return false;
        });
    
        // Method to validate data, enrich and post.
        //
        $('#id_formChangeDDNS').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // Get name of key pressed.
            //
            $keyValue = $('#' + e.id).attr("value");
    
            //alert("KEYVALUE="+ $keyValue + ", " + "VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);
    
            // Enrich the POST return message.
            //
            var params = [
              {
                name: "ACTION",
                value: $keyValue === "CANCEL" ? "CANCEL" : "SET_DDNS"
              },
              {
                name: "MODE",
                value: $('#id_ifDDNSSelector').attr("value")
              },
              {
                name: "SERVER_IP",
                value: $('#id_ifServerIP').attr("value")
              },
              {
                name: "CLIENT_DOMAIN",
                value: $('#id_ifClientDomain').attr("value")
              },
              {
                name: "CLIENT_USERNAME",
                value: $('#id_ifClientUserName').attr("value")
              },
              {
                name: "CLIENT_PASSWORD",
                value: $('#id_ifClientPassword').attr("value")
              },
              {
                name: "PROXY_ENABLE",
                value: $('#id_ifDDNSProxySelector').attr("value")
              },
              {
                name: "PROXY_IP",
                value: $('#id_ifDDNSProxyIP').attr("value")
              },
              {
                name: "PROXY_PORT",
                value: $('#id_ifDDNSProxyPort').attr("value")
              }
            ];
            $.each(params, function(i,param)
                           {
                               $('<input />').attr('type', 'hidden')
                                   .attr('name', param.name)
                                   .attr('value', param.value)
                                   .appendTo(document.forms['id_formChangeDDNS']);
                           });
    
            return true;
        });
    });

    // SETTINGS - PARAMETERS service selector.
    //
    $(function()
    {
        var $keyValue = "";
    
        // Method to validate data, enrich and post.
        //
        $('#id_formParameters').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // Get name of key pressed.
            //
            $keyValue = $('#' + e.id).attr("value");
    
            //alert("KEYVALUE="+ $keyValue + ", " + "VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);
    
            // Enrich the POST return message.
            //
            var params = [
              {
                name: "ACTION",
                value: $keyValue === "CANCEL" ? "CANCEL" : "SET_PARAMETERS"
              }
            ];
            $.each(params, function(i,param)
                           {
                               $('<input />').attr('type', 'hidden')
                                   .attr('name', param.name)
                                   .attr('value', param.value)
                                   .appendTo(document.forms['id_formParameters']);
                           });
    
            return true;
        });
    });
//------------------------------------ END OF SETTINGS CODE ------------------------------------------


//-------------------------------------------------------------------------------------------------------
// I/O SETUP - Code to aid forms in the I/O Setup Menu Option.
//-------------------------------------------------------------------------------------------------------
//$(function()
//{
    // I/O Setup - PORTS - PORT ENABLED/DISABLED Selector.
    //
    $(function() {
        $('#id_ifPortState').click(function(e) {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // Toggle state on each click.
            //
            if($(this).attr("value") === "ENABLED")
            {
                $("#id_ifPortState").prop('value', 'DISABLED');
                $(this).removeClass('btn-green');
                $(this).addClass('btn-grey');
                $('#inoutData :input').attr('disabled', true);
            } else
            {
                $("#id_ifPortState").prop('value', 'ENABLED');
                $(this).removeClass('btn-grey');
                $(this).addClass('btn-green');
                $('#inoutData :input').attr('disabled', false);
            }
            $("#id_ifPortState").html($(this).attr("value"));
        });
    });
    
    // I/O Setup - PORTS - PORT HIGH/LOW State Selector.
    //
    $(function() {
        var lowKey = "";
        var hiKey  = "";
    
        $('.state-selector').click(function(e) {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // If de-activated, just return.
            //
            if($('#id_ifPortState').attr("value") === "DISABLED") { return; }
    
            // Setup key Id values.
            //
            var pos = e.id.indexOf("LOW") + e.id.indexOf("HIGH") + 1;
            lowKey = e.id.substring(0, pos) + "LOW";
            hiKey  = e.id.substring(0, pos) + "HIGH";
    
            // Remove active/inactive classes en-masse.
            //
            $('#' + lowKey).removeClass('btn-grey');
            $('#' + lowKey).removeClass('btn-green');
            $('#' + lowKey).removeClass('active');
            $('#' + hiKey).removeClass('btn-grey');
            $('#' + hiKey).removeClass('btn-green');
            $('#' + hiKey).removeClass('active');
    
            //alert($(this).attr("value") + "::" + lowKey + "::" + hiKey)
    
            // Flip state and button according to click input.
            //
            if($(this).attr("value") === "HIGH")
            {
                $('#' + $(this).attr("id")).prop('value', 'LOW');
                $('#' + lowKey).addClass('btn-green');
                $('#' + lowKey).addClass('active');
                $('#' + hiKey).addClass('btn-grey');
            } else
            {
                $("#" + $(this).attr("id")).prop('value', 'HIGH');
                $('#' + lowKey).addClass('btn-grey');
                $('#' + hiKey).addClass('btn-green');
                $('#' + hiKey).addClass('active');
            }
        });
    });
    
    // I/O Setup - PORTS PORT OFF/ON/CURRENT Selector.
    //
    $(function() {
        var offKey = "";
        var onKey  = "";
        var curKey = "";
    
        $('.onoff-selector').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            //alert("VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);
    
            // If de-activated, just return.
            //
            if($('#id_ifPortState').attr("value") === "DISABLED") { return; }
    
            // Setup key Id values.
            //
            var pos = e.id.indexOf("OFF") + e.id.indexOf("ON") + e.id.indexOf("CURRENT") + 2;
            offKey = e.id.substring(0, pos) + "OFF";
            onKey  = e.id.substring(0, pos) + "ON";
            curKey = e.id.substring(0, pos) + "CURRENT";
    
            // Remove active/inactive classes en-masse.
            //
            $('#' + offKey).removeClass('btn-grey');
            $('#' + offKey).removeClass('btn-green');
            $('#' + offKey).removeClass('active');
            $('#' + onKey).removeClass('btn-grey');
            $('#' + onKey).removeClass('btn-green');
            $('#' + onKey).removeClass('active');
            $('#' + curKey).removeClass('btn-grey');
            $('#' + curKey).removeClass('btn-green');
            $('#' + curKey).removeClass('active');
    
            // Flip state and button according to click input. OFF->ON->CURRENT
            //
            if(e.id === offKey)
            {
                $("#" + $(this).attr("id")).prop('value', 'OFF');
                $('#' + offKey).addClass('btn-green');
                $('#' + offKey).addClass('active');
                $('#' + onKey).addClass('btn-grey');
                $('#' + curKey).addClass('btn-grey');
            } else
            if(e.id === onKey)
            {
                $('#' + $(this).attr("id")).prop('value', 'ON');
                $('#' + offKey).addClass('btn-grey');
                $('#' + onKey).addClass('btn-green');
                $('#' + onKey).addClass('active');
                $('#' + curKey).addClass('btn-grey');
            } else
            {
                $('#' + $(this).attr("id")).prop('value', 'CURRENT');
                $('#' + offKey).addClass('btn-grey');
                $('#' + onKey).addClass('btn-grey');
                $('#' + curKey).addClass('btn-green');
                $('#' + curKey).addClass('active');
            }
        });
    });

    // I/O Setup - PORTS - Setup Port Mode to INPUT/OUTPUT.
    //
    $(function()
    {
        //Variable of previously selected
        var selected = 0;
    
        $('#id_divModeSelector').click(function(e) {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // First time function runs?
            //
            if (selected == 0) {
                // Setup here..
                selected = e; //$(this);
            } else
            {
                // Click on same button, just return.
                //
                if(e.id === selected.id) { return; }
    
                // If de-activated, just return.
                //
                if($('#id_ifPortState').attr("value") === "DISABLED") { return; }
    
                // Hide previous button.
                //
                $($('#' + selected.id).attr('data-target')).collapse('hide');
            }
    
            // Cache this event for next time.
            //
            selected = e; //$(this);
    
            // Show the data for the button.
            //
            $($('#' + selected.id).attr('data-target')).collapse('show');
    
            if(selected.id === "id_ifPortIsInput")
            {
                $('#id_ifPortIsOutput').removeClass('btn-green');
                $('#id_ifPortIsOutput').addClass('btn-grey');
                $('#id_ifPortIsOutput').removeClass('active');
                $('#id_ifPortIsInput').removeClass('btn-grey');
                $('#id_ifPortIsInput').addClass('btn-green');
                $('#id_ifPortIsInput').addClass('active');
            }
            if(selected.id === "id_ifPortIsOutput")
            {
                $('#id_ifPortIsInput').removeClass('btn-green');
                $('#id_ifPortIsInput').addClass('btn-grey');
                $('#id_ifPortIsInput').removeClass('active');
                $('#id_ifPortIsOutput').removeClass('btn-grey');
                $('#id_ifPortIsOutput').addClass('btn-green');
                $('#id_ifPortIsOutput').addClass('active');
            }
        });
    });
    
    // I/O Setup - DEVICES - Function to handle click event on a Device Selector button.
    //
    $(function()
    {
        // Handler when a click is made on a port selection button. Send back the port number as a POST.
        //
        $('#id_divDeviceSelect').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // Place required parameters into the POST list.
            //
            var paramlist = [
                           {
                             name: "DEVICE",
                             value: $('#' + e.id).attr("value")
                           }
                         ];
            $.each(paramlist, function(i,param){
                $('<input />').attr('type', 'hidden')
                    .attr('name', param.name)
                    .attr('value', param.value)
                    .appendTo(document.forms['id_formSelectConfig']);
                  });
    
            // Submit the choice to refresh port data.
            //
            document.forms['id_formSelectConfig'].submit();
    
            return true;
          }
        );

    });
    
    
    // I/O Setup - PORTS - Function to handle click event on a Port Selector button.
    //
    $(function()
    {
        // Handler when a click is made on a port selection button. Send back the port number as a POST.
        //
        $('#id_divPortSelect').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // Place required parameters into the POST list.
            //
            var paramlist = [
                           {
                             name: "PORT",
                             value: $('#' + e.id).attr("value")
                           }
                         ];
            $.each(paramlist, function(i,param){
                $('<input />').attr('type', 'hidden')
                    .attr('name', param.name)
                    .attr('value', param.value)
                    .appendTo(document.forms['id_formSelectConfig']);
                  });
    
            // Submit the choice to refresh port data.
            //
            document.forms['id_formSelectConfig'].submit();
    
            return true;
          }
        );
    });

    // I/O Setup - TIMERS - Functions to aid in the Set Timer Screen.
    //
    $(function() {
        var id = "", idx = 0, mode = "", timer = "", dow = "", idfraction = "", size = 0; 
    
        // Timer ENABLED/DISABLED Selector.
        //
        $('.timer-enable').click(function(e) {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            id = e.id.substring(0, 17);
            if(e.id.indexOf("ON") != -1)
            {
              mode  = e.id.substring(17, 19);
              timer = e.id.substring(20);
            } else
            {
              mode  = e.id.substring(17, 20);
              timer = e.id.substring(21);
            }
    
            // Toggle state on each click.
            //
            if($(this).attr("value") === "ENABLED")
            {
                $(this).prop('value', 'DISABLED');
                $(this).removeClass('btn-green');
                $(this).addClass('btn-grey');
    
                // Disable time and DOW selection.
                //
                for(idx=0; idx < 7; idx++)
                {
                    $('#id_ifTimerDOW_' + mode + '_' + timer + '_' + idx).addClass('disabled');
                }
                $('#id_ifTimerTime_' + mode + '_' + timer).prop('disabled', true);
            } else
            {
                $(this).prop('value', 'ENABLED');
                $(this).removeClass('btn-grey');
                $(this).addClass('btn-green');
    
                // Enable time and DOW selection.
                //
                for(idx=0; idx < 7; idx++)
                {
                    $('#id_ifTimerDOW_' + mode + '_' + timer + '_' + idx).removeClass('disabled');
                }
                $('#id_ifTimerTime_' + mode + '_' + timer).prop('disabled', false);
            }
            $(this).html($(this).attr("value"));
        });
    
        // Day Of Week Selector.
        //
        $('.dow-enable').click(function(e) {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            //event.target.id.slice(17)
            var idfraction = e.id.substring(e.id.indexOf("ON") + e.id.indexOf("OFF") + 1);
            if(idfraction.indexOf("ON") != -1)
            {
              size = 2;
            } else
            {
              size = 3;
            }
            mode  = idfraction.substring(0, size);
            idfraction = idfraction.substring(size + 1);
            timer = idfraction.substring(0, idfraction.indexOf("_"));
            idfraction = idfraction.substring(idfraction.indexOf("_")+1);
            dow = idfraction.substring(0);
    
            // Toggle state on each click.
            //
            if($(this).hasClass("btn-green"))
            {
                $(this).prop('value', '0');
                $(this).removeClass('btn-green');
                $(this).removeClass('active');
                $(this).addClass('btn-grey');
            } else
            {
                //$(this).prop('value', 'ENABLED');
                $(this).prop('value', '1');
                $(this).removeClass('btn-grey');
                $(this).addClass('btn-green');
                $(this).addClass('active');
            }
        });
    });

    // I/O Setup - PING - Pinger ENABLED/DISABLED Selector.
    //
    $(function()
    {
        var idx = 0, id = "", posData = "", posIdx = 0, whichPinger = 0;
    
        $('.ping-enable').click(
            function(e)
            {
              e = e || window.event;
              e = e.target || e.srcElement;
    
              id           = e.id.substring(0, 15);
              posData      = e.id.substring(15);
              posIdx       = posData.indexOf('_');
              maxPinger    = parseInt(posData.substring(0, posIdx));
              whichPinger  = parseInt(posData.substring(posIdx+1));
    
              // Toggle state on each click.
              //
              if($(this).attr("value") === "ENABLED")
              {
                  // Disable pingers above the one selected to be disabled.
                  //
                  for(idx = whichPinger; idx <= maxPinger; idx++)
                  {
                      $('.ping-enable-' + idx).prop('disabled', true);
                      if(idx > whichPinger)
                      {
                          $('#' + id + maxPinger + '_' + idx).prop('disabled', true);
                      }
                      $('#' + id + maxPinger + '_' + idx).prop('value', 'DISABLED');
                      $('#' + id + maxPinger + '_' + idx).removeClass('btn-green');
                      $('#' + id + maxPinger + '_' + idx).addClass('btn-grey');
                      $('#' + id + maxPinger + '_' + idx).html('DISABLED');
                  }
              } else
              {
                  $('.ping-enable-' + whichPinger).prop('disabled', false);
                  $('#' + id + maxPinger + '_' + whichPinger).prop('disabled', false);
                  $('#' + id + maxPinger + '_' + whichPinger).prop('value', 'ENABLED');
                  $('#' + id + maxPinger + '_' + whichPinger).removeClass('btn-grey');
                  $('#' + id + maxPinger + '_' + whichPinger).addClass('btn-green');
                  $('#' + id + maxPinger + '_' + whichPinger).html('ENABLED');
                  idx = whichPinger + 1;
                  $('#' + id + maxPinger + '_' + idx).prop('disabled', false);
              }
              $(this).html($(this).attr("value"));
              return false;
           });
    });

    // Set of methods to check input data, during input or during submit.
    //
    var InputValidate =
    {
        CheckMinPort: function ()
        {
            var id='#id_ifDevicePortMin';
            var value=$(id).attr("value");
            var value_maxport=$('#id_ifDevicePortMax').attr("value");
            var value_start=$(id).attr("value_start");
            var value_min=$(id).attr("value_min");
            var value_max=$(id).attr("value_max");

            if(+value < +value_min || +value > +value_max)
            {
                alert('Minimum Port is out of range (Min = ' + value_min + ', Max = '+ value_max + ')');
                $(id).val(value_start);
                return false;
            }
            if(+value > +value_maxport)
            {
                alert('Minimum Port (' + value + ') cannot be greater than Maximum Port (' + value_maxport + ')');
                $(id).val(value_start);
                return false;
            }
            return true;
        },

        CheckMaxPort: function ()
        {
            var id='#id_ifDevicePortMax';
            var value=$(id).attr("value");
            var value_minport=$('#id_ifDevicePortMin').attr("value");
            var value_start=$(id).attr("value_start");
            var value_min=$(id).attr("value_min");
            var value_max=$(id).attr("value_max");

            if(+value < +value_min || +value > +value_max)
            {
                alert('Maximum Port is out of range (Min = ' + value_min + ', Max = '+ value_max + ')');
                $(id).val(value_start);
                return false;
            }
            if(+value < +value_minport)
            {
                alert('Maximum Port (' + value + ') cannot be less than Minimum Port (' + value_minport + ')');
                $(id).val(value_start);
                return false;
            }
            return true;
        },

        CheckBaseAddr: function ()
        {
            var id='#id_ifDeviceBaseAddr';
            var value=$(id).attr("value");
            var value_start=$(id).attr("value_start");
            var value_min=$(id).attr("value_min");
            var value_max=$(id).attr("value_max");

            if(+value < +value_min || +value > +value_max)
            {
                alert('Base Address is out of range (Min = ' + value_min + ', Max = '+ value_max + ')');
                $(id).val(value_start);
                return false;
            }
            return true;
        },

        CheckUARTDevice: function ()
        {
            var id='#id_ifDeviceUart';
            var value=$(id).attr("value");
            var value_start=$(id).attr("value_start");

            if(value === "")
            {
                alert('UART Device cannot be blank.');
                $(id).val(value_start);
                return false;
            }
            return true;
        },
    }

    // Function to handle click event on APPLY/SAVE/CANCEL Keys in the Config Menu's.
    //
    $(function()
    {
        // Multi handler for the APPLY/SAVE/CANCEL buttons on various screens. Send back data
        // according to the screen as configured in the paramlist table.
        //
        $('#id_formConfigSubmit').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;

            var id;
            var component;
            var submit = true;  // Default is to submit the form.

            // Work out which component called method.
            //
            try {
                id=$('.port-config').attr("id").substring(3);
                component="PORT";
            }
            catch(err) {
                try {
                    id=$('.device-config').attr("id").substring(3);
                    component="DEVICE";
                }
                catch(err) {
                    // Bad data, force a refresh.
                    alert("Programming error, exception on submit due to missing class information: " + err.message);
                    return true;
                }
            }

            // Get the full name of the form, ie. formConfig_IO
            // Get the actual form key, ie. IO
            var form=id.substring(id.indexOf("_")+1);

            // Parameters list for all button actions and form variables.
            //
            var paramlist = [
                           {
                              form: "APPLY SAVE CANCEL ALL", recurse: 0, subrecurse: 0,
                              name: "ACTION",
                              value: $('#' + e.id).attr("value"),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE CANCEL IO TIMER PING", recurse: 0, subrecurse: 0,
                              name: "PORT",
                              value: $('#id_divPortSelect').attr("value"),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE CANCEL DEVICE", recurse: 0, subrecurse: 0,
                              name: "DEVICE",
                              value: $('#id_divDeviceSelect').attr("value"),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE IO DEVICE", recurse: 0, subrecurse: 0,
                              name: "ENABLED",
                              value: component === "PORT" ? $('#id_ifPortState').attr("value")   === "ENABLED" ? "ENABLED" : "DISABLED" :
                                                            $('#id_ifDeviceState').attr("value") === "ENABLED" ? "ENABLED" : "DISABLED",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE IO DEVICE", recurse: 0, subrecurse: 0,
                              name: "NAME",
                              value: component === "PORT" ? $('#id_ifPortName').attr("value") : $('#id_ifDeviceName').attr('value'),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE IO DEVICE", recurse: 0, subrecurse: 0,
                              name: "DESCRIPTION",
                              value: component === "PORT" ? $('#id_ifPortDescription').attr("value") : $('#id_ifDeviceDescription').attr('value'),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE IO", recurse: 0, subrecurse: 0,
                              name: "MODE",
                              value: $('#id_ifPortIsInput').hasClass("active") ? "INPUT" : "OUTPUT",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE IO", recurse: 0, subrecurse: 0,
                              name: "OFF_STATE_VALUE",
                              value: $('#id_ifPortIsInput').hasClass("active") ?
                                        ($('#id_ifOffStateSelectorLOW').hasClass("active") ? "LOW" : "HIGH")
                                        :
                                        ($('#id_ifOffStateSelector2LOW').hasClass("active") ? "LOW" : "HIGH"),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE IO", recurse: 0, subrecurse: 0,
                              name: "ON_STATE_VALUE",
                              value: $('#id_ifPortIsInput').hasClass("active") ?
                                        ($('#id_ifOnStateSelectorLOW').hasClass("active") ? "LOW" : "HIGH")
                                        :
                                        ($('#id_ifOnStateSelector2LOW').hasClass("active") ? "LOW" : "HIGH"),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE IO", recurse: 0, subrecurse: 0,
                              name: "POWERUPSTATE",
                              value: $('#id_ifPowerUpSelectorOFF').hasClass("active") ? "OFF" :
                                        $('#id_ifPowerUpSelectorON').hasClass("active") ? "ON" : "CURRENT",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE IO", recurse: 0, subrecurse: 0,
                              name: "POWERDOWNSTATE",
                              value: $('#id_ifPowerDownSelectorOFF').hasClass("active") ? "OFF" :
                                        $('#id_ifPowerDownSelectorON').hasClass("active") ? "ON" : "CURRENT",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE TIMER", recurse: 6, subrecurse: 0,
                              name: "ON_TIME_ENABLE_",
                              value: "id_ifTimerEnable_ON_",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE TIMER", recurse: 6, subrecurse: 7,
                              name: "ON_TIME_",
                              value: "id_ifTimerTime_ON_",
                              subvalue: "id_ifTimerDOW_ON_",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE TIMER", recurse: 6, subrecurse: 0,
                              name: "OFF_TIME_ENABLE_",
                              value: "id_ifTimerEnable_OFF_",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE TIMER", recurse: 6, subrecurse: 7,
                              name: "OFF_TIME_",
                              value: "id_ifTimerTime_OFF_",
                              subvalue: "id_ifTimerDOW_OFF_",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: maxPinger+1, subrecurse: 0,
                              name: "PING_ENABLE_",
                              value: "id_ifPingState_" + maxPinger + "_",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: maxPinger+1, subrecurse: 0,
                              name: "PING_ADDR_",
                              value: "id_ifPingIP_",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: maxPinger+1, subrecurse: 0,
                              name: "PING_TYPE_",
                              value: "id_ifPingType_",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: maxPinger+1, subrecurse: 0,
                              name: "PING_TO_PING_TIME_",
                              value: "id_ifInterPingTime_",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: maxPinger+1, subrecurse: 0,
                              name: "PING_ADDR_WAIT_TIME_",
                              value: "id_ifPingWaitTime_",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: maxPinger+1, subrecurse: 0,
                              name: "PING_FAIL_COUNT_",
                              value: "id_ifFailCount_",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: maxPinger+1, subrecurse: 0,
                              name: "PING_SUCCESS_COUNT_",
                              value: "id_ifSuccessCount_",
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: 0, subrecurse: 0,
                              name: "PING_ACTION_FAIL_TIME",
                              value: $('#id_ifActionFailTime').attr("value"),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: 0, subrecurse: 0,
                              name: "PING_ACTION_SUCCESS_TIME",
                              value: $('#id_ifActionSuccessTime').attr("value"),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: 0, subrecurse: 0,
                              name: "PING_LOGIC_FOR_FAIL",
                              value: $('#id_ifLogicForFail').val(),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: 0, subrecurse: 0,
                              name: "PING_LOGIC_FOR_SUCCESS",
                              value: $('#id_ifLogicForSuccess').val(),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: 0, subrecurse: 0,
                              name: "PING_ACTION_ON_FAIL",
                              value: $('#id_ifActionOnFail').val(),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE PING", recurse: 0, subrecurse: 0,
                              name: "PING_ACTION_ON_SUCCESS",
                              value: $('#id_ifActionOnSuccess').val(),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE DEVICE", recurse: 0, subrecurse: 0,
                              name: "TYPE",
                              value: $('#id_divDeviceType').attr("value"),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE DEVICE", recurse: 0, subrecurse: 0,
                              name: "PORT_MIN",
                              value: $('#id_ifDevicePortMin').attr("value"),
                              subvalue: "",
                              validate: "CheckMinPort"
                           },
                           {
                              form: "APPLY SAVE DEVICE", recurse: 0, subrecurse: 0,
                              name: "PORT_MAX",
                              value: $('#id_ifDevicePortMax').attr("value"),
                              subvalue: "",
                              validate: "CheckMaxPort"
                           },
                           {
                              form: "APPLY SAVE DEVICE", recurse: 0, subrecurse: 0,
                              name: "UART",
                              value: $('#id_ifDeviceUart').attr("value"),
                              subvalue: "",
                              validate: "CheckUARTDevice"
                           },
                           {
                              form: "APPLY SAVE DEVICE", recurse: 0, subrecurse: 0,
                              name: "UART_BAUD",
                              value: $('#id_ifDeviceBaud').attr("value"),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE DEVICE", recurse: 0, subrecurse: 0,
                              name: "UART_DATABITS",
                              value: $('#id_ifDeviceDataBits').attr("value"),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE DEVICE", recurse: 0, subrecurse: 0,
                              name: "UART_PARITY",
                              value: $('#id_ifDeviceParity').attr("value"),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE DEVICE", recurse: 0, subrecurse: 0,
                              name: "UART_STOPBITS",
                              value: $('#id_ifDeviceStopBits').attr("value"),
                              subvalue: "",
                              validate: ""
                           },
                           {
                              form: "APPLY SAVE DEVICE", recurse: 0, subrecurse: 0,
                              name: "BASE_ADDR",
                              value: $('#id_ifDeviceBaseAddr').attr("value"),
                              subvalue: "",
                              validate: "CheckBaseAddr"
                           },
                         ];

            //alert("APP VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);
    
            // Build parameter list and send all parameters back to the server.
            //
            $.each(paramlist, function(i,param)
            {
                // If the params array contains the value (ie. APPLY) in the form field
                //    AND
                //    Params array form field contains ALL OR params array form field contains the form key
                //
                if((param.form.indexOf($('#' + e.id).attr("value")) != -1) &&                  // ie. APPLY, SAVE, CANCEL
                     (param.form.indexOf("ALL") != -1 || param.form.indexOf(form) != -1) )     // ie. IO, TIMER etc
                {
                    //alert("APP COMPONENT=" + component + ", FORM=" + form + ", EventID=" +e.id + ", NAME=" + param.name + ", VALUE=" + param.value);

                    // Is there a validation routine attached to this field, if so call it.
                    //
                    if(param.validate !== "")
                    {
                        if(! window.InputValidate[param.validate]())
                        {
                            submit=false;
                            return false;
                        }
                        //alert('TOPname:' + param.name + ', value:' + param.value);
                    }

                    // No recursive values, just add to document form.
                    //
                    if(param.recurse == 0)
                    {
                        $('<input />').attr('type', 'hidden')
                            .attr('name', param.name)
                            .attr('value', param.value)
                            .appendTo(document.forms['id_formConfigSubmit']);
                        //alert('name:' + param.name + ', value:' + param.value);
                    }
                    else
                    {
                        var idx, idx2, value = "", subvalue = "";
    
                        for(idx = 0; idx < param.recurse; idx++)
                        {
                            value = $('#' + param.value + idx).attr("value");
                            if(param.subrecurse > 0)
                            {
                                subvalue = "";
                                for(idx2 = 0; idx2 < param.subrecurse; idx2++)
                                {
                                    if($('#' + param.subvalue + idx + '_' + idx2).hasClass("btn-green"))
                                    {
                                        if(subvalue === "")
                                        {
                                            subvalue = '' + idx2;
                                        } else
                                        {
                                            subvalue += ',' + idx2;
                                        }
                                    }
                                }
                                value += ' ' + subvalue;
                            }
    
                            $('<input />').attr('type', 'hidden')
                                .attr('name', param.name + idx)
                                .attr('value', value)
                                .appendTo(document.forms['id_formConfigSubmit']);
                        }
                    }
                }
            });
    
            // Submit the choice if flag set to refresh port data.
            //
            if(submit)
            {
                // Submit form to server for processing.
                //
                document.forms['id_formConfigSubmit'].submit();
            } 

            // Clear out the built up submission form for next iteration.
            //
            $('#id_formConfigSubmit').each(function() { this.reset(); });
            return submit;
          }
        );
    });

    // Prevent the main form from submitting data after a click, this is done by returning false.
    //
    $(document.forms['portDataConfig']).submit(
        function()
        {   //listen for submit event
            return false;
        });

    // I/O Setup - DEVICES - Setup Device base information.
    //
    $(function()
    {
        var localKey = "";
        var ntpKey = "";
        var $keyValue = "";

        //Variable of previously selected
        var selected = 0;
    
        $('.device-config').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // Get name of key pressed.
            //
            //$keyValue = $('#' + e.id).attr("value");
    
            //alert("KEYVALUE="+ $keyValue + ", " + "VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);
    
            // Setup key Id values.
            //
            var pos  = e.id.indexOf("ENABLED") + e.id.indexOf("DISABLED") + 1;
            disabledKey = e.id.substring(0, pos) + "DISABLED";
            enabledKey   = e.id.substring(0, pos) + "ENABLED";
    
            // Remove active/inactive classes en-masse.
            //
            $('#' + disabledKey).removeClass('btn-grey');
            $('#' + disabledKey).removeClass('btn-green');
            $('#' + disabledKey).removeClass('active');
            $('#' + enabledKey).removeClass('btn-grey');
            $('#' + enabledKey).removeClass('btn-green');
            $('#' + enabledKey).removeClass('active');
    
            // Flip state and button according to click input. DISABLED->ENABLED
            //
            if(e.id == disabledKey)
            {
                //$('#id_ifProxyIP').prop('disabled', true);
                //$('#if_ifProxyPort').prop('disabled', true);
                //if(e.id.indexOf("Proxy") == -1)
                //{
                //    $('#id_ifServerIP').prop('disabled', true);
                //    $('#id_ifClientDomain').prop('disabled', true);
                //    $('#id_ifClientUserName').prop('disabled', true);
                //    $('#id_ifClientPassword').prop('disabled', true);
                //    $('#id_ifDDNSProxySelector_DISABLED').prop('disabled', true);
                //    $('#id_ifDDNSProxySelector_ENABLED').prop('disabled', true);
                //}
    
                $("#" + $(this).attr("id")).prop('value', 'DISABLED');
                $('#' + disabledKey).addClass('btn-green');
                $('#' + disabledKey).addClass('active');
                $('#' + enabledKey).addClass('btn-grey');
            } else
            {
                //if(e.id.indexOf("Proxy") != -1)
                //{
                //    $('#id_ifProxyIP').prop('disabled', false);
                //    $('#id_ifProxyPort').prop('disabled', false);
                //} else
                //{
                //    $('#id_ifServerIP').prop('disabled', false);
                //    $('#id_ifClientDomain').prop('disabled', false);
                //    $('#id_ifClientUserName').prop('disabled', false);
                //    $('#id_ifClientPassword').prop('disabled', false);
                //    $('#id_ifDDNSProxySelector_DISABLED').prop('disabled', false);
                //    $('#id_ifDDNSProxySelector_ENABLED').prop('disabled', false);
                //    if($('#id_ifDDNSProxySelector').attr('value') == 'ENABLED')
                //    {
                //        $('#id_ifProxyIP').prop('disabled', false);
                //        $('#id_ifProxyPort').prop('disabled', false);
                //    }
                //}
    
                $('#' + $(this).attr("id")).prop('value', 'ENABLED');
                $('#' + disabledKey).addClass('btn-grey');
                $('#' + enabledKey).addClass('btn-green');
                $('#' + enabledKey).addClass('active');
            }
    
            // Dont POST on this event, return FALSE to prevent it.
            //
            return false;
        });

        $('#id_divDeviceType').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;

            // First time function runs?
            //
            if (selected == 0) {
                // Setup here..
                selected = e; //$(this);
            } else
            {
                // Click on same button, just return.
                //
                if(e.id === selected.id) { return; }
    
                // If de-activated, just return.
                //
                if($('#id_ifDeviceState').attr("value") === "DISABLED") { return; }
    
                // Hide previous button.
                //
                $($('#' + selected.id).attr('data-target')).collapse('hide');
            }

            // Cache this event for next time.
            //
            selected = e; //$(this);
    
            // Show the data for the button.
            //
            $($('#' + selected.id).attr('data-target')).collapse('show');

            // Get name of key pressed.
            //
            keyValue = $('#' + e.id).attr("value");
            //alert("DS KEYVALUE="+ $keyValue + ", " + "VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);

            $('div[id^="id_divDeviceType"]').each(
              function ()
              {
                // Setup key Id values.
                //
                id = this.id.substring(17);
                if (id === "") { return true; }

                // Setup active key according to press.
                //
                if(id === keyValue)
                {
                    $('#id_ifDeviceType_' + keyValue).removeClass('btn-grey');
                    $('#id_ifDeviceType_' + keyValue).addClass('btn-green');
                    $('#id_ifDeviceType_' + keyValue).addClass('active');
                    $('#id_divDeviceType').prop('value', keyValue);
                } else
                {
                    $('#id_ifDeviceType_' + id).removeClass('btn-green');
                    $('#id_ifDeviceType_' + id).addClass('btn-grey');
                    $('#id_ifDeviceType_' + id).removeClass('active');
                }
              }
            );
    
//            if(selected.id == "id_ifDeviceType_ATMEGA328P")
//            {
//                $('#id_ifDeviceType_TCA6416A').removeClass('btn-green');
//                $('#id_ifDeviceType_TCA6416A').addClass('btn-grey');
//                $('#id_ifDeviceType_TCA6416A').removeClass('active');
//                $('#id_ifDeviceType_ATMEGA328P').removeClass('btn-grey');
//                $('#id_ifDeviceType_ATMEGA328P').addClass('btn-green');
//                $('#id_ifDeviceType_ATMEGA328P').addClass('active');
//                $('#id_divDeviceType').prop('value', $keyValue);
//            }
//            if(selected.id == "id_ifDeviceType_TCA6416A")
//            {
//                $('#id_ifDeviceType_ATMEGA328P').removeClass('btn-green');
//                $('#id_ifDeviceType_ATMEGA328P').addClass('btn-grey');
//                $('#id_ifDeviceType_ATMEGA328P').removeClass('active');
//                $('#id_ifDeviceType_TCA6416A').removeClass('btn-grey');
//                $('#id_ifDeviceType_TCA6416A').addClass('btn-green');
//                $('#id_ifDeviceType_TCA6416A').addClass('active');
//                $('#id_divDeviceType').prop('value', $keyValue);
//            }
          });
    
//        // Method to validate data, enrich and post.
//        //
//        $('#id_formDeviceConfigSubmit').click(
//          function(e)
//          {
//            e = e || window.event;
//            e = e.target || e.srcElement;
//    
//            // Get name of key pressed.
//            //
//            $keyValue = $('#' + e.id).attr("value");
//    
//            alert("KEYVALUE="+ $keyValue + ", " + "VALUE=" + $(this).attr("value") + ", ATTRID=" + $(this).attr("id") + ", EventID=" +e.id);
//    
//            // Enrich the POST return message.
//            //
//            var params = [
//              {
//                name: "ACTION",
//                value: $keyValue == "CANCEL" ? "CANCEL" : "SET_DEVICE"
//              },
//              {
//                name: "MODE",
//                value: $('#id_ifDDNSSelector').attr("value")
//              },
//              {
//                name: "PROXY_ENABLE",
//                value: $('#id_ifDDNSProxySelector').attr("value")
//              }
//            ];
//            $.each(params, function(i,param)
//                           {
//                               $('<input />').attr('type', 'hidden')
//                                   .attr('name', param.name)
//                                   .attr('value', param.value)
//                                   .appendTo(document.forms['id_formDeviceConfigSubmit']);
//                           });
//    
//            return true;
//        });

        // I/O Setup - DEVICES - DEVICE ENABLED/DISABLED Selector.
        //
        $(function() {
            $('#id_ifDeviceState').click(
                function(e)
                {
                    e = e || window.event;
                    e = e.target || e.srcElement;
        
                    // Toggle state on each click.
                    //
                    if($(this).attr("value") === "ENABLED")
                    {
                        $("#id_ifDeviceState").prop('value', 'DISABLED');
                        $(this).removeClass('btn-green');
                        $(this).addClass('btn-grey');
                        $('#deviceState :input').attr('disabled', true);
                    } else
                    {
                        $("#id_ifDeviceState").prop('value', 'ENABLED');
                        $(this).removeClass('btn-grey');
                        $(this).addClass('btn-green');
                        $('#deviceState :input').attr('disabled', false);
                    }
                    $("#id_ifDeviceState").html($(this).attr("value"));
                });
            });
    });

//});
//------------------------------------ END OF I/O SETUP CODE ------------------------------------------

//-------------------------------------------------------------------------------------------------------
// I/O Control - Code to aid forms in the I/O Control Menu Option.
//-------------------------------------------------------------------------------------------------------
//
//$(function()
//{
    // Function to handle events specific to the I/O Control - Set Outputs Menu.
    //
    $(function()
    {
        var $keyValue = "", portList = "";
        var id = "", mode = "", port = 0, divKey = "", offKey = "",onKey  = "", result = 0;;
    
        // PORT OFF/ON State Selector.
        //
        $(document).on('click', '.output-selector', 
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            // Setup key Id values.
            //
            id = e.id.substring(0, 16);
            if(e.id.indexOf("ON") != -1)
            {
              mode = e.id.substring(17, 19);
              port = e.id.substring(20);
            } else
            {
              mode = e.id.substring(17, 20);
              port = e.id.substring(21);
            }
            divKey = id + '_' + port;
            offKey = id + '_' + "OFF" + '_' + port;
            onKey  = id + '_' + "ON"  + '_' + port;
    
            // Remove active/inactive classes en-masse.
            //
            $('#' + offKey).removeClass('btn-grey');
            $('#' + offKey).removeClass('btn-green');
            $('#' + offKey).removeClass('active');
            $('#' + onKey).removeClass('btn-grey');
            $('#' + onKey).removeClass('btn-green');
            $('#' + onKey).removeClass('active');
    
            // Flip state and button according to click input.
            //
            if($(this).attr("value") === "ON")
            {
                $('#' + divKey).prop('value', 'OFF');
                $('#' + offKey).addClass('btn-green');
                $('#' + offKey).addClass('active');
                $('#' + onKey).addClass('btn-grey');
            } else
            {
                $('#' + divKey).prop('value', 'ON');
                $('#' + offKey).addClass('btn-grey');
                $('#' + onKey).addClass('btn-green');
                $('#' + onKey).addClass('active');
            }
    
            // POST according to checkbox.
            // 
            if($('#id_setRadioAllOnApply').is(":checked")) { return false; }
    
            // Build up the post parameters list.
            //
            //var params = [
            //               {
            //                 name: "ACTION",
            //                 value: "SETPORT"
            //               },
            //               {
            //                 name: "PORT",
            //                 value: port
            //               },
            //               {
            //                  name: "OUTPUT_STATE",
            //                  value: $('#' + divKey).attr('value')
            //               }
            //             ];
            //$.each(params, function(i,param){
            //    $('<input />').attr('type', 'hidden')
            //        .attr('name', param.name)
            //        .attr('value', param.value)
            //        .appendTo(document.forms['id_formOutputState']);
            //});

            // Use AJAX to send the data to the post method without invoking a refresh.
            //
            $.ajax(
            {
                type: 'POST',
                dataType: 'json',
                cache: false,
                data: {
                    ACTION: "SETPORT",
                    PORT: port,
                    OUTPUT_STATE: $('#' + divKey).attr('value')
                },
                url: '/dpwr',
                success:
                    function (msg)
                    {
                        if(msg)
                        {
                            alert(msg);
                        }
                    }
            }); 

            // Done, data sent to server.
            //
            return true;
          }
        );
    
        // Function to handle click event on Set Port Submit/Refresh/Cancel buttons.
        //
        $(document).on('click', '#id_setBtnSetOutApply', 
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            //$keyValue = $('#' + e.id).attr("value");

            if($('#' + e.id).hasClass("disabled"))
            {
                return false;
            }

            portList = "";
            $('div[id^="id_ifOutputState"]').each(function ()
            {
                // Setup key Id values.
                //
                id = this.id.substring(0, 16);
                port = this.id.substring(17);
    
                if(portList !== "") { portList = portList + ";"; }
                portList = portList + port + ':' + $('#' + this.id).attr("value");
            });
    
            // Indicate that the update has occurred.
            //
            $('#id_ifControlMsg').css('color', 'black');
            $('#id_ifControlMsg').html("Update complete.");

            // Use AJAX to send the data to the post method without invoking a refresh.
            //
            $.ajax(
            {
                type: 'POST',
                dataType: 'json',
                cache: false,
                data: {
                    ACTION:    "SETPORTS",
                    PORTLIST:  portList
                },
                url: '/dpwr',
                success:
                    function (msg)
                    {
                        if(msg)
                        {
                            alert(msg);
                        }
                    }
            }); 

            // Returning true forces the submit action.
            //
            return true;
          }
        );

/*        $(document).on('click', '#id_setBtnSetOutRefresh', 
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            //$keyValue = $('#' + e.id).attr("value");

            if($('#' + e.id).hasClass("disabled"))
            {
                return false;
            }

            // Force a reload to refresh.
            //
            window.location.reload();
            return false;
          }
        );
*/

        $(document).on('click', '#id_setBtnSetOutCancel', 
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            //$keyValue = $('#' + e.id).attr("value");

            if($('#' + e.id).hasClass("disabled"))
            {
                return false;
            }

            // Force a reload to cancel all changes.
            //
            window.location.reload();
            return false;
          }
        );
        
        function updateIOControlRadio(SetOrRead, AllOnApply)
        {
            if(SetOrRead == undefined)
            {
                SetOrRead = false;
            }

            if(SetOrRead == false)
            {
                if(AllOnApply == true)
                {
                  $('#id_setBtnSetOutApply').removeClass('disabled');
                  $('#id_setBtnSetOutCancel').removeClass('disabled');
                }
                else if(AllOnApply == false)
                {
                  $('#id_setBtnSetOutApply').addClass('disabled');
                  $('#id_setBtnSetOutCancel').addClass('disabled');
                } else
                {
                    ;
                }
            } else
            {
                ;
            }

             // Use AJAX to send the data to the post method without invoking a refresh.
            //
//            var dataSet;
//            if(SetOrRead == false)
//            {
//                dataSet = {
//                  ACTION:       "IOCONTROL",
//                  ALLONAPPLY:   $('.all-on-apply').is(":checked")
//                };
//            } else
//            {
//                dataSet = {
//                };
//            }
//            $.ajax(
//            {
//                type:     'POST',
//                dataType: 'json',
//                cache:    false,
//                data:     dataSet,
//                url:      '/dpwr',
//                success:
//                    function (msg)
//                    {
//                        if(msg)
//                        {
//                            alert(msg);
//                        }
//                    }
//            }); 

            // Update the cookie to reflect choice.
            //
            $.cookie('AllOnApply',$('.all-on-apply').is(":checked"),{expires:365});
        }

        // When a radio button is pressed in the modal, update the server and local variables.
        //
        $(document).on('change', '.all-on-apply',           function() { updateIOControlRadio(false, true); });
        $(document).on('change', '#id_setRadioOff',         function() { updateIOControlRadio(false, false); });

        // Force only input of numerics in the numeric class.
        //
        var specialKeys = new Array();
        specialKeys.push(8); //Backspace
        $(function()
        {
            $(".numeric").bind("keypress", function(e)
            {
                var keyCode = e.which ? e.which : e.keyCode
                var ret = ((keyCode >= 48 && keyCode <= 57) || specialKeys.indexOf(keyCode) != -1);
                $(".error").css("display", ret ? "none" : "inline");
                return ret;
            });
            $(".numeric").bind("paste", function(e)
            {
                return false;
            });
            $(".numeric").bind("drop", function(e)
            {
                return false;
            });
        });

        $(document).on('change', '.refresh-timeout',
          function()
          {
            // Ensure the time is sane.
            //
            refreshTime = $('#id_setRefreshTimeout').val();
            if(refreshTime == undefined)
			{
			    refreshTime = $('#id_readRefreshTimeout').val();
                if(refreshTime == undefined || refreshTime < 5)
                {
                    refreshTime = 5;
                    $('#id_readRefreshTimeout').val(refreshTime);

                    // Update the cookie to reflect choice.
                    //
                    $.cookie('ReadInputRefreshTime',refreshTime,{expires:365});
				}
			} else
			{
                if(refreshTime < 5)
                {
                    refreshTime = 5;
                    $('#id_setRefreshTimeout').val(refreshTime);

                    // Update the cookie to reflect choice.
                    //
                    $.cookie('SetOutputRefreshTime',refreshTime,{expires:365});
				}
            }
          });

        $(document).on('change', '.notification-timeout',
          function()
          {
            // Ensure the time is sane.
            //
            notificationTime = $('#id_setNotificationTimeout').val();
            if(notificationTime == undefined || notificationTime < 2)
            {
                notificationTime = 2;
                $('#id_setNotificationTimeout').val(notificationTime);
            }

            // Update the cookie to reflect choice.
            //
            $.cookie('NotificationTime',notificationTime,{expires:365});

             // Use AJAX to send the data to the post method without invoking a refresh.
            //
//            $.ajax(
//            {
//                type:                'POST',
//                dataType:            'json',
//                cache:               false,
//                data: {
//                    ACTION:            "IOCONTROL",
//                  NOTIFICATIONTIME:  notificationTime
//                },
//                url:                 '/dpwr',
//                success:
//                    function (msg)
//                    {
//                        if(msg)
//                        {
//                            alert(msg);
//                        }
//                    }
//            }); 
          });

        // Set auto timeout handler to handle Auto Refresh mode.
        //
        window.onload=function()
        {
//            var autorefresh = setTimeout(function(){ autoRefresh(); }, 100);
            var autoclrmsg  = setTimeout(function(){ autoClrMsg(); }, 100);
    
            // Method to force a submit if the Auto Refresh checkbox is ticked.
            //
            function autoRefreshForm()
            {
              if($('.auto-refresh').is(":checked")) 
              {
                  window.location.reload();
              }
            }

            // Method to clear the message area.
            //
            function autoClrMsgDiv()
            {
               $('#id_ifControlMsg').html("");
            }
    
            // Method to be called on a fixed timeout and then reset itself to occur again.
            // Purpose is to call the auto refresh post logic which forces a post submit
            // if the auto refresh checkbox is ticked.
            //
            function autoRefresh()
            {
               clearTimeout(autorefresh);
               timer = $('.refresh-timeout').val() * 1000;
               if(timer == undefined || timer == 0)
               {
                   timer = 10000;
               }
               autorefresh = setTimeout(function(){ autoRefreshForm(); autoRefresh(); }, timer);
            }

            function autoClrMsg()
            {
               clearTimeout(autoclrmsg);
               timer = $('.notification-timeout').val() * 1000;
               if(timer == undefined || timer == 0)
               {
                   timer = 10000;
               }
               autoclrmsg = setTimeout(function(){ autoClrMsgDiv(); autoClrMsg(); }, timer);
            }
        };

        // If the settings button on the set output page is pressed, show modal.
        //
        $(document).on('click', '.btn-set-iocontrol-setting', function(e)
        {
            e.preventDefault();
            $('#id_setIOControlModal').modal('show');
        });

        // If the settings button on the read input page is pressed, show modal.
        //
        $(document).on('click', '.btn-read-iocontrol-setting', function(e)
        {
            e.preventDefault();
            $('#id_readIOControlModal').modal('show');
        });
    });
//});
//------------------------------------ END OF I/O CONTROL CODE ------------------------------------------

// General per page final setup.
//
//var Script = function ()
//{
        $(function()
        {
            // validate required forms when they are submitted.
            //$("#change-email-form").validate();

            // Initialise the Mail Selector input fields according to the initial value.
            //
            if($('#id_ifMailSelector').length != 0)
            {
                if($('#id_ifMailSelector').attr("value") === 'NONE')
                {
                    $('#id_ifMailSelector_NONE').click();
                } else
                if($('#id_ifMailSelector').attr("value") === 'SMTP')
                {
                    $('#id_ifMailSelector_SMTP').click();
                } else
                {
                    $('#id_ifMailSelector_POP3').click();
                }
            }

            // Initialise PORT DISABLE/ENABLE selector.
            //
            if($('#id_ifPortState').length != 0)
            {
                if($('#id_ifPortState').attr("value") === "DISABLED")
                {
                    $('#inoutData :input').attr('disabled', true);
                }
            }

            // Initialise the Time Selector input fields.
            //
            if($('#id_ifTimeSelector').length != 0)
            {
                if($('#id_ifTimeSelector').attr("value") === 'LOCAL')
                {
                    $('#id_ifTimeSelector_LOCAL').click();
                } else
                {
                    $('#id_ifTimeSelector_NTP').click();
                }
            }

            // Initialise the DDNS Selector input fields.
            //
            if($('#id_ifDDNSSelector').length != 0)
            {
                if($('#id_ifDDNSSelector').attr("value") === 'DISABLED')
                {
                    $('#id_ifDDNSSelector_DISABLED').click();
                } else
                {
                    $('#id_ifDDNSSelector_ENABLED').click();

                    if($('#id_ifDDNSProxySelector').attr("value") === 'DISABLED')
                    {
                        $('#id_ifDDNSProxySelector_DISABLED').click();
                    } else
                    {
                        $('#id_ifDDNSProxySelector_ENABLED').click();
                    }
                }
            }

            // Initialise the DDNS Selector input fields.
            //
            if($('#id_ifDDNSSelector').length != 0)
            {
                $('#ddns-client-domain').inputmask("Regex");
            }

            // Initialise the Device Selector.
            //
            if($('#id_divDeviceType').length != 0)
            {
              $('div[id^="id_divDeviceType"]').each(
                function ()
                {
                  // Setup key Id values.
                  //
                  id = this.id.substring(17);
                  if (id === "") { return true; }
  
                  if($('#id_ifDeviceType_' + id).hasClass("active"))
                  {
                      $('#id_ifDeviceType_' + id).click();
                  }
                }
              );
            }

            // If configuring a device and it is inactive or has no config, disable the input form.
            //
            if($('#id_ifDeviceState').attr("value") === "DISABLED")
            {
                $('#deviceState :input').attr('disabled', true);
            }

            // Initialise the Mode Selector.
            //
            if($('#id_divModeSelector').length != 0)
            {
                if($('#id_ifPortIsInput').hasClass("active"))
                {
                    $('#id_ifPortIsInput').click();
                } else
                {
                    $('#id_ifPortIsOutput').click();
                }
            }

            // Initialise the PORT LOCKED/UNLOCKED Selector.
            //
            if($('#id_ifControlMsg').length != 0)
            {
                if( ($('#id_ifControlMsg').attr("value") === "LOCKED") || 
                    ($('#id_ifControlMsg').attr("value") === "INPUT") || 
                    ($('#id_ifControlMsg').attr("value") === "DISABLED") )
                {
                    $('.port-config :input').attr('disabled', true);
                    //$('#id_formConfig :input').attr('disabled', true);
                }
            }

            // Initialise the Ping setup screen.
            //
            if($('#id_formConfig_PING').length != 0)
            {
                // At page load, disable the correct fields. Initially work out the maximum number of Pingers.
                //
                $('button[id^="id_ifPingState"]').each(function ()
                {
                    // Setup key Id values.
                    //
                    id           = this.id.substring(0, 15);
                    posData      = this.id.substring(15);
                    posIdx       = posData.indexOf('_');
                    maxPinger    = parseInt(posData.substring(0, posIdx));
                });
                // Locate the first disabled pinger.
                //
                for(whichPinger = 0; whichPinger <= maxPinger; whichPinger++)
                {
                    if($('#id_ifPingState_' + maxPinger + '_' + whichPinger).attr("value") === 'DISABLED') { break; }
                }
                // Disable all fields for Pingers below the first disabled pinger.
                //
                if(whichPinger < maxPinger)
                {
                    for(idx = whichPinger; idx <= maxPinger; idx++)
                    {
                        $('.ping-enable-' + idx).prop('disabled', true);
                        if(idx > whichPinger)
                        {
                            $('#' + id + maxPinger + '_' + idx).prop('disabled', true);
                            $('#' + id + maxPinger + '_' + idx).prop('value', 'DISABLED');
                            $('#' + id + maxPinger + '_' + idx).removeClass('btn-green');
                            $('#' + id + maxPinger + '_' + idx).addClass('btn-grey');
                            $('#' + id + maxPinger + '_' + idx).html('DISABLED');
                        }
                    }
                }
                // Ensure all fields are setup to use the input mask mechanism.
                //
                for(idx = 0; idx <= maxPinger; idx++)
                {
                    $(".ping-enable-" + idx).inputmask();
                }
            }
        });

            
            //disbaling some functions for Internet Explorer
//            if($.browser.msie)
//            {
//                $('#is-ajax').prop('checked',false);
//                $('#for-is-ajax').hide();
//                $('#toggle-fullscreen').hide();
//                $('.login-box').find('.input-large').removeClass('span10');
//                
//            }
            
            
            
            //establish history variables
//            var
//                History = window.History, // Note: We are using a capital H instead of a lower h
//                State = History.getState(),
//                $log = $('#log');
        
            //bind to State Change
//            History.Adapter.bind(window,'statechange',function(){ // Note: We are using statechange instead of popstate
//                var State = History.getState(); // Note: We are using History.getState() instead of event.state
//                $.ajax({
//                    url:State.url,
//                    success:function(msg){
//                        $('#content').html($(msg).find('#content').html());
//                        $('#loading').remove();
//                        $('#content').fadeIn();
//                        docReady();
//                    }
//                });
//            });

//}


    //rich text editor
//    $('.cleditor').cleditor();
    
    //datepicker
//    $('.datepicker').datepicker();
    
    //notifications
//    $('.noty').click(function(e){
//        e.preventDefault();
//        var options = $.parseJSON($(this).attr('data-noty-options'));
//        noty(options);
//    });


    //uniform - styler for checkbox, radio and file input
//    $("input:checkbox, input:radio, input:file").not('[data-no-uniform="true"],#uniform-is-ajax').uniform();

    //chosen - improves select
//    $('[data-rel="chosen"],[rel="chosen"]').chosen();

    //tabs
//    $('#myTab a:first').tab('show');
//    $('#myTab a').click(function (e) {
//      e.preventDefault();
//      $(this).tab('show');
//    });

    //makes elements soratble, elements that sort need to have id attribute to save the result
//    $('.sortable').sortable({
//        revert:true,
//        cancel:'.btn,.box-content,.nav-header',
//        update:function(event,ui){
//            //line below gives the ids of elements, you can make ajax call here to save it to the database
//            //console.log($(this).sortable('toArray'));
//        }
//    });

    //slider
//    $('.slider').slider({range:true,values:[10,65]});

    //tooltip
//    $('[rel="tooltip"],[data-rel="tooltip"]').tooltip({"placement":"bottom",delay: { show: 400, hide: 200 }});

    //auto grow textarea
//    $('textarea.autogrow').autogrow();

    //popover
//    $('[rel="popover"],[data-rel="popover"]').popover();

    //file manager
//    var elf = $('.file-manager').elfinder({
//        url : 'misc/elfinder-connector/connector.php'  // connector URL (REQUIRED)
//    }).elfinder('instance');

    //iOS / iPhone style toggle switch
//    $('.iphone-toggle').iphoneStyle();

    //star rating
//    $('.raty').raty({
//        score : 4 //default stars
//    });

    //uploadify - multiple uploads
//    $('#file_upload').uploadify({
//        'swf'      : 'misc/uploadify.swf',
//        'uploader' : 'misc/uploadify.php'
//        // Put your options here
//    });

//    //gallery controlls container animation
//    $('ul.gallery li').hover(function(){
//        $('img',this).fadeToggle(1000);
//        $(this).find('.gallery-controls').remove();
//        $(this).append('<div class="well gallery-controls">'+
//                            '<p><a href="#" class="gallery-edit btn"><i class="icon-edit"></i></a> <a href="#" class="gallery-delete btn"><i class="icon-remove"></i></a></p>'+
//                        '</div>');
//        $(this).find('.gallery-controls').stop().animate({'margin-top':'-1'},400,'easeInQuint');
//    },function(){
//        $('img',this).fadeToggle(1000);
//        $(this).find('.gallery-controls').stop().animate({'margin-top':'-30'},200,'easeInQuint',function(){
//                $(this).remove();
//        });
//    });
//

    //gallery image controls example
    //gallery delete
 //   $('.thumbnails').on('click','.gallery-delete',function(e){
 //       e.preventDefault();
 //       //get image id
 //       //alert($(this).parents('.thumbnail').attr('id'));
 //       $(this).parents('.thumbnail').fadeOut();
 //   });
 //   //gallery edit
 //   $('.thumbnails').on('click','.gallery-edit',function(e){
 //       e.preventDefault();
 //       //get image id
 //       //alert($(this).parents('.thumbnail').attr('id'));
 //   });

    //gallery colorbox
//    $('.thumbnail a').colorbox({rel:'thumbnail a', transition:"elastic", maxWidth:"95%", maxHeight:"95%"});

    //gallery fullscreen
//    $('#toggle-fullscreen').button().click(function () {
//        var button = $(this), root = document.documentElement;
//        if (!button.hasClass('active')) {
//            $('#thumbnails').addClass('modal-fullscreen');
//            if (root.webkitRequestFullScreen) {
//                root.webkitRequestFullScreen(
//                    window.Element.ALLOW_KEYBOARD_INPUT
//                );
//            } else if (root.mozRequestFullScreen) {
//                root.mozRequestFullScreen();
//            }
//        } else {
//            $('#thumbnails').removeClass('modal-fullscreen');
//            (document.webkitCancelFullScreen ||
//                document.mozCancelFullScreen ||
//                $.noop).apply(document);
//        }
//    });

    //tour
//    if($('.tour').length && typeof(tour)=='undefined')
//    {
//        var tour = new Tour();
//        tour.addStep({
//            element: ".span10:first", /* html element next to which the step popover should be shown */
//            placement: "top",
//            title: "Custom Tour", /* title of the popover */
//            content: "You can create tour like this. Click Next." /* content of the popover */
//        });
//        tour.addStep({
//            element: ".theme-container",
//            placement: "left",
//            title: "Themes",
//            content: "You change your theme from here."
//        });
//        tour.addStep({
//            element: "ul.main-menu a:first",
//            title: "Dashboard",
//            content: "This is your dashboard from here you will find highlights."
//        });
//        tour.addStep({
//            element: "#for-is-ajax",
//            title: "Ajax",
//            content: "You can change if pages load with Ajax or not."
//        });
//        tour.addStep({
//            element: ".top-nav a:first",
//            placement: "bottom",
//            title: "Visit Site",
//            content: "Visit your front end from here."
//        });
//        
//        tour.restart();
//    }

    //datatable
//    $('.datatable').dataTable({
//            "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span12'i><'span12 center'p>>",
//            "sPaginationType": "bootstrap",
//            "oLanguage": {
//            "sLengthMenu": "_MENU_ records per page"
//            }
//        } );
//    $('.btn-setting').click(function(e){
//        e.preventDefault();
//        $('#myModal').modal('show');
//    });

    //initialize the external events for calender

//    $('#external-events div.external-event').each(function() {
//
//        // it doesn't need to have a start or end
//        var eventObject = {
//            title: $.trim($(this).text()) // use the element's text as the event title
//        };
//        
//        // store the Event Object in the DOM element so we can get to it later
//        $(this).data('eventObject', eventObject);
//        
//        // make the event draggable using jQuery UI
//        $(this).draggable({
//            zIndex: 999,
//            revert: true,      // will cause the event to go back to its
//            revertDuration: 0  //  original position after the drag
//        });
//        
//    });


//    //initialize the calendar
//    $('#calendar').fullCalendar({
//        header: {
//            left: 'prev,next today',
//            center: 'title',
//            right: 'month,agendaWeek,agendaDay'
//        },
//        editable: true,
//        droppable: true, // this allows things to be dropped onto the calendar !!!
//        drop: function(date, allDay) { // this function is called when something is dropped
//        
//            // retrieve the dropped element's stored Event Object
//            var originalEventObject = $(this).data('eventObject');
//            
//            // we need to copy it, so that multiple events don't have a reference to the same object
//            var copiedEventObject = $.extend({}, originalEventObject);
//            
//            // assign it the date that was reported
//            copiedEventObject.start = date;
//            copiedEventObject.allDay = allDay;
//            
//            // render the event on the calendar
//            // the last `true` argument determines if the event "sticks" (http://arshaw.com/fullcalendar/docs/event_rendering/renderEvent/)
//            $('#calendar').fullCalendar('renderEvent', copiedEventObject, true);
//            
//            // is the "remove after drop" checkbox checked?
//            if ($('#drop-remove').is(':checked')) {
//                // if so, remove the element from the "Draggable Events" list
//                $(this).remove();
//            }
//            
//        }
//    });
    
    
//    //chart with points
//    if($("#sincos").length)
//    {
//        var sin = [], cos = [];
//
//        for (var i = 0; i < 14; i += 0.5) {
//            sin.push([i, Math.sin(i)/i]);
//            cos.push([i, Math.cos(i)]);
//        }
//
//        var plot = $.plot($("#sincos"),
//               [ { data: sin, label: "sin(x)/x"}, { data: cos, label: "cos(x)" } ], {
//                   series: {
//                       lines: { show: true  },
//                       points: { show: true }
//                   },
//                   grid: { hoverable: true, clickable: true, backgroundColor: { colors: ["#fff", "#eee"] } },
//                   yaxis: { min: -1.2, max: 1.2 },
//                   colors: ["#539F2E", "#3C67A5"]
//                 });
//
//        function showTooltip(x, y, contents) {
//            $('<div id="tooltip">' + contents + '</div>').css( {
//                position: 'absolute',
//                display: 'none',
//                top: y + 5,
//                left: x + 5,
//                border: '1px solid #fdd',
//                padding: '2px',
//                'background-color': '#dfeffc',
//                opacity: 0.80
//            }).appendTo("body").fadeIn(200);
//        }
//
//        var previousPoint = null;
//        $("#sincos").bind("plothover", function (event, pos, item) {
//            $("#x").text(pos.x.toFixed(2));
//            $("#y").text(pos.y.toFixed(2));
//
//                if (item) {
//                    if (previousPoint != item.dataIndex) {
//                        previousPoint = item.dataIndex;
//
//                        $("#tooltip").remove();
//                        var x = item.datapoint[0].toFixed(2),
//                            y = item.datapoint[1].toFixed(2);
//
//                        showTooltip(item.pageX, item.pageY,
//                                    item.series.label + " of " + x + " = " + y);
//                    }
//                }
//                else {
//                    $("#tooltip").remove();
//                    previousPoint = null;
//                }
//        });
//        
//
//
//        $("#sincos").bind("plotclick", function (event, pos, item) {
//            if (item) {
//                $("#clickdata").text("You clicked point " + item.dataIndex + " in " + item.series.label + ".");
//                plot.highlight(item.series, item.datapoint);
//            }
//        });
//    }
//    
//    //flot chart
//    if($("#flotchart").length)
//    {
//        var d1 = [];
//        for (var i = 0; i < Math.PI * 2; i += 0.25)
//            d1.push([i, Math.sin(i)]);
//        
//        var d2 = [];
//        for (var i = 0; i < Math.PI * 2; i += 0.25)
//            d2.push([i, Math.cos(i)]);
//
//        var d3 = [];
//        for (var i = 0; i < Math.PI * 2; i += 0.1)
//            d3.push([i, Math.tan(i)]);
//        
//        $.plot($("#flotchart"), [
//            { label: "sin(x)",  data: d1},
//            { label: "cos(x)",  data: d2},
//            { label: "tan(x)",  data: d3}
//        ], {
//            series: {
//                lines: { show: true },
//                points: { show: true }
//            },
//            xaxis: {
//                ticks: [0, [Math.PI/2, "\u03c0/2"], [Math.PI, "\u03c0"], [Math.PI * 3/2, "3\u03c0/2"], [Math.PI * 2, "2\u03c0"]]
//            },
//            yaxis: {
//                ticks: 10,
//                min: -2,
//                max: 2
//            },
//            grid: {
//                backgroundColor: { colors: ["#fff", "#eee"] }
//            }
//        });
//    }
    
//    //stack chart
//    if($("#stackchart").length)
//    {
//        var d1 = [];
//        for (var i = 0; i <= 10; i += 1)
//        d1.push([i, parseInt(Math.random() * 30)]);
//
//        var d2 = [];
//        for (var i = 0; i <= 10; i += 1)
//            d2.push([i, parseInt(Math.random() * 30)]);
//
//        var d3 = [];
//        for (var i = 0; i <= 10; i += 1)
//            d3.push([i, parseInt(Math.random() * 30)]);
//
//        var stack = 0, bars = true, lines = false, steps = false;
//
//        function plotWithOptions() {
//            $.plot($("#stackchart"), [ d1, d2, d3 ], {
//                series: {
//                    stack: stack,
//                    lines: { show: lines, fill: true, steps: steps },
//                    bars: { show: bars, barWidth: 0.6 }
//                }
//            });
//        }
//
//        plotWithOptions();
//
//        $(".stackControls input").click(function (e) {
//            e.preventDefault();
//            stack = $(this).val() == "With stacking" ? true : null;
//            plotWithOptions();
//        });
//        $(".graphControls input").click(function (e) {
//            e.preventDefault();
//            bars = $(this).val().indexOf("Bars") != -1;
//            lines = $(this).val().indexOf("Lines") != -1;
//            steps = $(this).val().indexOf("steps") != -1;
//            plotWithOptions();
//        });
//    }
//
//    //pie chart
//    var data = [
//    { label: "Internet Explorer",  data: 12},
//    { label: "Mobile",  data: 27},
//    { label: "Safari",  data: 85},
//    { label: "Opera",  data: 64},
//    { label: "Firefox",  data: 90},
//    { label: "Chrome",  data: 112}
//    ];
//    
//    if($("#piechart").length)
//    {
//        $.plot($("#piechart"), data,
//        {
//            series: {
//                    pie: {
//                            show: true
//                    }
//            },
//            grid: {
//                    hoverable: true,
//                    clickable: true
//            },
//            legend: {
//                show: false
//            }
//        });
//        
//        function pieHover(event, pos, obj)
//        {
//            if (!obj)
//                    return;
//            percent = parseFloat(obj.series.percent).toFixed(2);
//            $("#hover").html('<span style="font-weight: bold; color: '+obj.series.color+'">'+obj.series.label+' ('+percent+'%)</span>');
//        }
//        $("#piechart").bind("plothover", pieHover);
//    }
//    
//    //donut chart
//    if($("#donutchart").length)
//    {
//        $.plot($("#donutchart"), data,
//        {
//                series: {
//                        pie: {
//                                innerRadius: 0.5,
//                                show: true
//                        }
//                },
//                legend: {
//                    show: false
//                }
//        });
//    }


//     // we use an inline data source in the example, usually data would
//    // be fetched from a server
//    var data = [], totalPoints = 300;
//    function getRandomData() {
//        if (data.length > 0)
//            data = data.slice(1);
//
//        // do a random walk
//        while (data.length < totalPoints) {
//            var prev = data.length > 0 ? data[data.length - 1] : 50;
//            var y = prev + Math.random() * 10 - 5;
//            if (y < 0)
//                y = 0;
//            if (y > 100)
//                y = 100;
//            data.push(y);
//        }
//
//        // zip the generated y values with the x values
//        var res = [];
//        for (var i = 0; i < data.length; ++i)
//            res.push([i, data[i]])
//        return res;
//    }
//
//    // setup control widget
//    var updateInterval = 30;
//    $("#updateInterval").val(updateInterval).change(function () {
//        var v = $(this).val();
//        if (v && !isNaN(+v)) {
//            updateInterval = +v;
//            if (updateInterval < 1)
//                updateInterval = 1;
//            if (updateInterval > 2000)
//                updateInterval = 2000;
//            $(this).val("" + updateInterval);
//        }
//    });
//
//    //realtime chart
//    if($("#realtimechart").length)
//    {
//        var options = {
//            series: { shadowSize: 1 }, // drawing is faster without shadows
//            yaxis: { min: 0, max: 100 },
//            xaxis: { show: false }
//        };
//        var plot = $.plot($("#realtimechart"), [ getRandomData() ], options);
//        function update() {
//            plot.setData([ getRandomData() ]);
//            // since the axes don't change, we don't need to call plot.setupGrid()
//            plot.draw();
//            
//            setTimeout(update, updateInterval);
//        }
//
//        update();
//    }
//}

/*
//additional functions for data table
$.fn.dataTableExt.oApi.fnPagingInfo = function ( oSettings )
{
    return {
        "iStart":         oSettings._iDisplayStart,
        "iEnd":           oSettings.fnDisplayEnd(),
        "iLength":        oSettings._iDisplayLength,
        "iTotal":         oSettings.fnRecordsTotal(),
        "iFilteredTotal": oSettings.fnRecordsDisplay(),
        "iPage":          Math.ceil( oSettings._iDisplayStart / oSettings._iDisplayLength ),
        "iTotalPages":    Math.ceil( oSettings.fnRecordsDisplay() / oSettings._iDisplayLength )
    };
}
$.extend( $.fn.dataTableExt.oPagination, {
    "bootstrap": {
        "fnInit": function( oSettings, nPaging, fnDraw ) {
            var oLang = oSettings.oLanguage.oPaginate;
            var fnClickHandler = function ( e ) {
                e.preventDefault();
                if ( oSettings.oApi._fnPageChange(oSettings, e.data.action) ) {
                    fnDraw( oSettings );
                }
            };

            $(nPaging).addClass('pagination').append(
                '<ul>'+
                    '<li class="prev disabled"><a href="#">&larr; '+oLang.sPrevious+'</a></li>'+
                    '<li class="next disabled"><a href="#">'+oLang.sNext+' &rarr; </a></li>'+
                '</ul>'
            );
            var els = $('a', nPaging);
            $(els[0]).bind( 'click.DT', { action: "previous" }, fnClickHandler );
            $(els[1]).bind( 'click.DT', { action: "next" }, fnClickHandler );
        },

        "fnUpdate": function ( oSettings, fnDraw ) {
            var iListLength = 5;
            var oPaging = oSettings.oInstance.fnPagingInfo();
            var an = oSettings.aanFeatures.p;
            var i, j, sClass, iStart, iEnd, iHalf=Math.floor(iListLength/2);

            if ( oPaging.iTotalPages < iListLength) {
                iStart = 1;
                iEnd = oPaging.iTotalPages;
            }
            else if ( oPaging.iPage <= iHalf ) {
                iStart = 1;
                iEnd = iListLength;
            } else if ( oPaging.iPage >= (oPaging.iTotalPages-iHalf) ) {
                iStart = oPaging.iTotalPages - iListLength + 1;
                iEnd = oPaging.iTotalPages;
            } else {
                iStart = oPaging.iPage - iHalf + 1;
                iEnd = iStart + iListLength - 1;
            }

            for ( i=0, iLen=an.length ; i<iLen ; i++ ) {
                // remove the middle elements
                $('li:gt(0)', an[i]).filter(':not(:last)').remove();

                // add the new list items and their event handlers
                for ( j=iStart ; j<=iEnd ; j++ ) {
                    sClass = (j==oPaging.iPage+1) ? 'class="active"' : '';
                    $('<li '+sClass+'><a href="#">'+j+'</a></li>')
                        .insertBefore( $('li:last', an[i])[0] )
                        .bind('click', function (e) {
                            e.preventDefault();
                            oSettings._iDisplayStart = (parseInt($('a', this).text(),10)-1) * oPaging.iLength;
                            fnDraw( oSettings );
                        } );
                }

                // add / remove disabled classes from the static elements
                if ( oPaging.iPage === 0 ) {
                    $('li:first', an[i]).addClass('disabled');
                } else {
                    $('li:first', an[i]).removeClass('disabled');
                }

                if ( oPaging.iPage === oPaging.iTotalPages-1 || oPaging.iTotalPages === 0 ) {
                    $('li:last', an[i]).addClass('disabled');
                } else {
                    $('li:last', an[i]).removeClass('disabled');
                }
            }
        }
    }
});*/



//$(document).ready(function () {
//  var trigger = $('.hamburger'),
//      overlay = $('.overlay'),
//     isClosed = false;
//
//    trigger.click(function () {
//      hamburger_cross();      
//    });
////
//    function hamburger_cross() {
//
//      if (isClosed == true) {          
//        overlay.hide();
//        trigger.removeClass('is-open');
//        trigger.addClass('is-closed');
//        isClosed = false;
//      } else {   
//        overlay.show();
//        trigger.removeClass('is-closed');
//        trigger.addClass('is-open');
//        isClosed = true;
//      }
//  }

//});

// Execute all code which relies on the document being fully loaded.
//
$(document).ready
(
    function()
    {
        //$('.accordion').click(function (e) {
        //    e.preventDefault();
        //    var $ul = $(this).siblings('ul');
        //    var $a = $(this).siblings('a');
        //    var $li = $(this).parent();
        //    if ($ul.is(':visible')) $li.removeClass('active');
        //    else                    $li.addClass('active');
        //        $a.removeClass('icon-plus');
        //        $ul.slideToggle();
        //    });
    
        //    $('.accordion').collapse('hide');

        // Get the stored page to load into the content area and load.
        //
        var url = $.cookie('MainPage')==null ? 'dash.jsp' :$.cookie('MainPage');
        loadContent(url);
        //setActiveMenu(url);
        loadModal("modals.jsp");

        // Other things to do on document ready, seperated for ajax calls
        documentReady();
    }
);
