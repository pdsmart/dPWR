<!DOCTYPE html>

<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="NIPS">
    <meta name="keyword" content="Dashboard, Bootstrap, Admin, Template, Theme, Responsive, Fluid, Retina">
    <link rel="shortcut icon" href="img/favicon.png">

    <title>[DPWR]VAR:${SERVER_NAME}[/DPWR] [DPWR]VAR:${SERVER_MODEL}[/DPWR]</title>

    <!-- Bootstrap core CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/bootstrap-reset.css" rel="stylesheet">

    <!--external css-->
    <link href="assets/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <link rel="stylesheet" type="text/css" href="assets/gritter/css/jquery.gritter.css" />

    <!--dynamic table-->
    <link href="assets/advanced-datatable/media/css/demo_page.css" rel="stylesheet" />
    <link href="assets/advanced-datatable/media/css/demo_table.css" rel="stylesheet" />
    <link rel="stylesheet" href="assets/data-tables/DT_bootstrap.css" />

    <link rel="stylesheet" type="text/css" href="assets/bootstrap-datepicker/css/datepicker.css" />
    <link rel="stylesheet" type="text/css" href="assets/bootstrap-timepicker/compiled/timepicker.css" />
    <link rel="stylesheet" type="text/css" href="assets/bootstrap-colorpicker/css/colorpicker.css" />
    <link rel="stylesheet" type="text/css" href="assets/bootstrap-daterangepicker/daterangepicker.css" />
    <link rel="stylesheet" type="text/css" href="assets/bootstrap-datetimepicker/css/datetimepicker.css" />
    <link rel="stylesheet" type="text/css" href="assets/jquery-multi-select/css/multi-select.css" />

    <!--right slidebar-->
    <link href="css/slidebars.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="css/style.css" rel="stylesheet">
    <link href="css/style-responsive.css" rel="stylesheet" />

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 tooltipss and media queries -->
    <!--[if lt IE 9]>
      <script src="js/html5shiv.js"></script>
      <script src="js/respond.min.js"></script>
    <![endif]-->

    <link rel="stylesheet" type="text/css" href="css/user.css" />
  </head>

  <body>
    <section id="container" class="">
      <!--header start-->
      <header class="header white-bg">
          <div class="sidebar-toggle-box">
              <div data-original-title="Toggle Navigation" data-placement="right" class="fa fa-bars tooltips"></div>
          </div>
          <!--logo start-->
          <a href="index.html" class="logo" >[DPWR]VAR:${SERVER_NAME}[/DPWR] <span>[DPWR]VAR:${SERVER_MODEL}[/DPWR]</span></a>
          <!--logo end-->
          <div class="nav notify-row" id="top_menu">
            <!--  notification start -->
            <ul class="nav top-menu">
            </ul>
          </div>
          <div class="top-nav ">
              <ul class="nav pull-right top-menu">
                  <li>
                      <input type="text" class="form-control search" placeholder="Search">
                  </li>
              </ul>
          </div>
      </header>
      <!--header end-->

      <!--sidebar start-->
      <aside>
          <div id="sidebar"  class="nav-collapse ">
              <!-- sidebar menu start-->
              <ul class="sidebar-menu" id="nav-accordion">
                  <!-- DASHBOARD -->
                  <li>
                      <a [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ALL:PRIMARY:DASHBOARD[/DPWR] href="/">
                          <i class="fa fa-dashboard"></i>
                          <span>Dashboard</span>
                      </a>
                  </li>

                  <!-- CONTROL -->
                  <li class="sub-menu">
                      <a [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ALL:PRIMARY:CONTROL[/DPWR] href="javascript:;">
                          <i class="fa fa-sitemap"></i>
                          <span>I/O Control</span>
                      </a>
                      <ul class="sub">
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_USER:SUB:CONTROL:SETOUTPUTS[/DPWR]><a href="getpage?control_set_outputs">Set Outputs</a></li>
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ALL:SUB:CONTROL:READINPUTS[/DPWR]><a href="getpage?control_read_inputs">Read Inputs</a></li>
                      </ul>
                  </li>

                  <!-- CONFIG -->
                  <li class="sub-menu">
                      <a [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ADMIN:PRIMARY:CONFIG[/DPWR] href="javascript:;">
                          <i class="fa fa-wrench"></i>
                          <span>I/O Setup</span>
                      </a>
                      <ul class="sub">
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ROOT:SUB:CONFIG:CONFIGDEVICES[/DPWR]>  <a href="getpage?config_devices">Devices</a></li>
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ADMIN:SUB:CONFIG:CONFIGPORTS[/DPWR]>    <a href="getpage?config_ports">Ports</a></li>
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ADMIN:SUB:CONFIG:CONFIGTIMERS[/DPWR]>   <a href="getpage?config_timers">Timers</a></li>
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ADMIN:SUB:CONFIG:CONFIGPING[/DPWR]>     <a href="getpage?config_ping">Ping</a></li>
                      </ul>
                  </li>

                  <!-- STATUS -->
                  <li class="sub-menu">
                      <a [DPWR]ACTIVEMENU:$ACCESS_LEVEL_USER:PRIMARY:STATUS[/DPWR] href="javascript:;">
                          <i class="fa fa-question-circle"></i>
                          <span>Status</span>
                      </a>
                      <ul class="sub">
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ADMIN:SUB:STATUS:VARIABLES[/DPWR]> <a href="getpage?variables">I/O Parameters</a></li>
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_USER:SUB:STATUS:ACTIVEPORTS[/DPWR]><a href="getpage?active_ports">Active I/O Ports</a></li>
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ADMIN:SUB:STATUS:ALLPORTS[/DPWR]>  <a href="getpage?all_ports">All I/O Ports</a></li>
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ROOT:SUB:STATUS:DEVICELOG[/DPWR]>  <a href="getpage?devicelog">Device Log</a></li>
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ROOT:SUB:STATUS:WEBSERVER[/DPWR]>  <a href="getpage?webserver">Web Server</a></li>
                      </ul>
                  </li>

                  <!-- SETTINGS -->
                  <li class="sub-menu">
                      <a [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ALL:PRIMARY:SETTINGS[/DPWR] href="javascript:;">
                          <i class="fa fa-cogs"></i>
                          <span>Settings</span>
                      </a>
                      <ul class="sub">
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ADMIN:SUB:SETTINGS:DDNS[/DPWR]>          <a href="getpage?set_ddns">DDNS</a></li>
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ALL:SUB:SETTINGS:EMAIL[/DPWR]>           <a href="getpage?set_email">E-Mail</a></li>
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ALL:SUB:SETTINGS:PASSWORD[/DPWR]>        <a href="getpage?change_password">Password</a></li>
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ADMIN:SUB:SETTINGS:TIME[/DPWR]>          <a href="getpage?change_time">Time</a></li>
                          <li [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ADMIN:SUB:SETTINGS:PARAMETERS[/DPWR]>    <a href="getpage?parameters">Parameters</a></li>
                      </ul>
                  </li>

                  <!-- LOGOUT -->
                  <li>
                      <a [DPWR]ACTIVEMENU:$ACCESS_LEVEL_ALL:PRIMARY:LOGOUT[/DPWR] href="getpage?logout">
                          <i class="fa fa-sign-out"></i>
                          <span>Logout
                              <font face="verdana" color="yellow">&nbsp([DPWR]VAR:$http->{SESSION}->param('USER')[/DPWR])</font>
                          </span>
                      </a>
                      <input type="hidden" value="[DPWR]VAR:$http->{SESSION}->param('~logged-in')[/DPWR]" id='id_ifHiddenLoggedIn'>
                      <input type="hidden" value="[DPWR]VAR:$http->{PARAMS}->{HTTP_SESSION_TIMEOUT}[/DPWR]" id='id_ifHiddenHttpSessionTimeout'>
                      <input type="hidden" value="[DPWR]VAR:$http->{SESSION}->param('forward-url')[/DPWR]" id='id_ifHiddenForwardUrl'>
                      <input type="hidden" value="[DPWR]VAR:$http->{SESSION}->param('forward-time')[/DPWR]" id='id_ifHiddenForwardTime'>
                  </li>
              </ul>
              </ul>
              <!-- sidebar menu end-->
          </div>
      </aside>
      <!--sidebar end-->

      <!--main content start-->
      [DPWR]INCLUDEFILE[/DPWR]
      <!--main content end-->

      <!--footer start-->
      <footer class="site-footer">
		    <table width="99%">
			  <tr>
				<td width="8%"><a href="#" class="go-top"><i class="fa fa-angle-up"></i></a></td>
			    <td width="19%" sty;e="text-align:right;font-weight:bold;" class="clock">
				  <ul style="width: 400px;margin:0 auto;padding:0px;list-style:none;text-align: center;">
					<li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" id="Date"></li>
				    <li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;">&nbsp;&nbsp;&nbsp;</li>
				    <li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" id="hours"></li>
					<li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" id="point">:</li>
					<li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" id="min"></li>
					<li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" id="point">:</li>
					<li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" id="sec"></li>
                  </ul>
				</td>
			    <td width="20%" style="text-align:right;font-weight:bold;">[DPWR]VAR:$http->{PARAMS}->{TITLE}[/DPWR]</td>
				<td width="40%" style="text-align:right;font-weight:bold;">v[DPWR]VAR:${PROGRAMVERSION}[/DPWR] &copy; Philip Smart, [DPWR]VAR:${PROGRAMDATE}[/DPWR]</td>
				<td width="2%"><a href="#" class="go-top"><i class="fa fa-angle-up"></i></a></td>
			  </tr>
			</table>
      </footer>

      <!--footer end-->
    </section>

    <!-- js placed at the end of the document so the pages load faster -->

    <script src="js/jquery.js"></script>
    <script type="text/javascript" src="js/jquery.inputmask.bundle.js"></script>

    <script src="js/bootstrap.min.js"></script>
    <script src="js/jquery-ui-1.9.2.custom.min.js"></script>
    <script src="js/jquery-migrate-1.2.1.min.js"></script>
    <script class="include" type="text/javascript" src="js/jquery.dcjqaccordion.2.7.js"></script>
    <script src="js/jquery.scrollTo.min.js"></script>
    <script src="js/jquery.nicescroll.js" type="text/javascript"></script>
    <script type="text/javascript" src="js/jquery.validate.min.js"></script>
    <script type="text/javascript" language="javascript" src="assets/advanced-datatable/media/js/jquery.dataTables.js"></script>
    <script type="text/javascript" src="assets/gritter/js/jquery.gritter.js"></script>
    <script type="text/javascript" src="assets/data-tables/DT_bootstrap.js"></script>
    <script src="js/respond.min.js" ></script>
    <script type="text/javascript" src="js/jquery.pulsate.min.js"></script>

    <!--right slidebar-->
    <script src="js/slidebars.min.js"></script>

    <!--dynamic table initialization -->
    <script src="js/dynamic_table_init.js"></script>

    <!--custom switch -->
    <script src="js/bootstrap-switch.js"></script>

    <!--custom tagsinput-->
    <script src="js/jquery.tagsinput.js"></script>

    <!--custom checkbox & radio-->
    <script type="text/javascript" src="js/ga.js"></script>
    <script type="text/javascript" src="assets/fuelux/js/spinner.min.js"></script>
    <script type="text/javascript" src="assets/bootstrap-datepicker/js/bootstrap-datepicker.js"></script>
    <script type="text/javascript" src="assets/bootstrap-daterangepicker/date.js"></script>
    <script type="text/javascript" src="assets/bootstrap-daterangepicker/daterangepicker.js"></script>
    <script type="text/javascript" src="assets/bootstrap-datepicker/js/bootstrap-datepicker.js"></script>
    <script type="text/javascript" src="assets/bootstrap-datetimepicker/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript" src="assets/bootstrap-daterangepicker/moment.min.js"></script>
    <script type="text/javascript" src="assets/bootstrap-colorpicker/js/bootstrap-colorpicker.js"></script>
    <script type="text/javascript" src="assets/bootstrap-timepicker/js/bootstrap-timepicker.js"></script>
    <script type="text/javascript" src="assets/jquery-multi-select/js/jquery.multi-select.js"></script>
    <script type="text/javascript" src="assets/ckeditor/ckeditor.js"></script>

    <!--common script for all pages-->
    <script src="js/common-scripts.js"></script>
    <script src="js/gritter.js" type="text/javascript"></script>
    <script src="js/pulstate.js" type="text/javascript"></script>

    <script type="text/javascript" src="js/user.js"></script>
<script>
$(document).ready(function(){
    $(":input").inputmask();
});
</script>
  </body>
</html>
