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
    
        $('.ping-enable').click(function(e) {
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
        $('.output-selector').click(
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
            if($('#id_ifSetAllOnApply').is(":checked")) { return false; }
    
            // Build up the post parameters list.
            //
            var params = [
                           {
                             name: "ACTION",
                             value: "SETPORT"
                           },
                           {
                             name: "PORT",
                             value: port
                           },
                           {
                              name: "OUTPUT_STATE",
                              value: $('#' + divKey).attr('value')
                           }
                         ];
            $.each(params, function(i,param){
                $('<input />').attr('type', 'hidden')
                    .attr('name', param.name)
                    .attr('value', param.value)
                    .appendTo(document.forms['id_formOutputState']);
            });
    
            // Submit the choice via returning true.
            //
            return true;
          }
        );
    
        // Function to handle click event on Set Port Submit/Refresh/Cancel buttons.
        //
        $('#id_formSetPortSubmit').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            $keyValue = $('#' + e.id).attr("value");
    
            // Add in ACTION.
            //
            $('<input />').attr('type', 'hidden')
                .attr('name', 'ACTION')
                .attr('value', $keyValue)
                .appendTo(document.forms['id_formSetPortSubmit']);
    
            // REFRESH and CANCEL dont have any data to add, but APPLY needs all the port values.
            //
            if($keyValue === "APPLY")
            {
                $('div[id^="id_ifOutputState"]').each(function ()
                {
                    // Setup key Id values.
                    //
                    id = this.id.substring(0, 16);
                    port = this.id.substring(17);
    
                    if(portList !== "") { portList = portList + ";"; }
                    portList = portList + port + ':' + $('#' + this.id).attr("value");
                });
    
                $('<input />').attr('type', 'hidden')
                    .attr('name', 'SETPORTS')
                    .attr('value', portList)
                    .appendTo(document.forms['id_formSetPortSubmit']);
            }
    
            // Returning true forces the submit action.
            //
            return true;
          }
        );
    
        // Function to handle click event on Set All On Apply Button
        //
        $('#id_ifSetAllOnApply').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
            result = true;
    
            // Cannot activate if Auto Refresh is already activated.
            //
            if($(this).is(":checked"))
            {
                if($('#id_ifAutoRefresh').is(":checked"))
                {
                    result = false;
                } else
                {
                    $('#id_ifConfigApply').removeClass('disabled');
                    $('#id_ifConfigCancel').removeClass('disabled');
                }
            } else
            {
                $('#id_ifConfigApply').addClass('disabled');
                $('#id_ifConfigCancel').addClass('disabled');
            }
    
            return result;
          }
        );
    
        // Function to handle click event on Auto Refresh Button.
        //
        $('#id_ifAutoRefresh').click(
          function(e)
          {
            e = e || window.event;
            e = e.target || e.srcElement;
    
            if($(this).is(":checked"))
            {
                $('#id_ifConfigRefresh').addClass('disabled');
                if($('#id_ifSetAllOnApply').is(":checked"))
                {
                    $('#id_ifSetAllOnApply').click();
                }
            } else
            {
                $('#id_ifConfigRefresh').removeClass('disabled');
            }
    
            //$('#id_formSetPortSubmit').submit();
            return true;
          }
        );
    
        // Function to handle submit of form data for the Set All on Apply and Auto Refresh
        // Buttons.
        //
        $('#id_formSetPortSubmit').submit(
          function(e)
          {
            // Add the necessary POST command to enable Auto Refresh.
            //
            $('<input />').attr('type', 'hidden')
                .attr('name', 'AUTOREFRESH')
                .attr('value', $('#id_ifAutoRefresh').is(":checked") ? 1 : 0)
                .appendTo(document.forms['id_formSetPortSubmit']);
    
            // Add the necessary POST command to enable Set On Apply. 
            //
            $('<input />').attr('type', 'hidden')
                .attr('name', 'SETONAPPLY')
                .attr('value', $('#id_ifSetAllOnApply').is(":checked") ? 1 : 0)
                .appendTo(document.forms['id_formSetPortSubmit']);
    
            return true;
          }
        );
    
        // Set auto timeout handler to handle Auto Refresh mode.
        //
        window.onload=function()
        {
            var auto = setTimeout(function(){ autoRefresh(); }, 100);
    
            // Method to force a submit if the Auto Refresh checkbox is ticked.
            //
            function autoRefreshForm()
            {
              if($('#id_ifAutoRefresh').is(":checked")) 
              {
                  $('#id_formSetPortSubmit').submit();
              }
              //document.forms["myForm"].submit();
            }
    
            // Method to be called on a fixed timeout and then reset itself to occur again.
            // Purpose is to call the auto refresh post logic which forces a post submit
            // if the auto refresh checkbox is ticked.
            //
            function autoRefresh()
            {
               clearTimeout(auto);
               auto = setTimeout(function(){ autoRefreshForm(); autoRefresh(); }, 10000);
            }
        };
    });
//});
//------------------------------------ END OF I/O CONTROL CODE ------------------------------------------

// General per page final setup.
//
var Script = function ()
{
    $(document).ready
    (
        function()
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

    		setInterval( function()
                         {
                             // Create a newDate() object and extract the seconds of the current time on the visitor's
                             var seconds = new Date().getSeconds();

                             // Add a leading zero to seconds value
                             $("#sec").html(( seconds < 10 ? "0" : "" ) + seconds);
                         },1000
                       );
			
    		setInterval( function()
                         {
                             // Create a newDate() object and extract the minutes of the current time on the visitor's
                             var minutes = new Date().getMinutes();

                             // Add a leading zero to the minutes value
                             $("#min").html(( minutes < 10 ? "0" : "" ) + minutes);
                         },1000
                       );
			
    		setInterval( function()
                         {
                             // Create a newDate() object and extract the hours of the current time on the visitor's
                             var hours = new Date().getHours();
    
                             // Add a leading zero to the hours value
                             $("#hours").html(( hours < 10 ? "0" : "" ) + hours);
                         }, 1000
                       );

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

		}
	);
}();
