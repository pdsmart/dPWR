<!DOCTYPE html>

<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="NIPS">
    <meta name="keyword" content="Dashboard, Bootstrap, Admin, Template, Theme, Responsive, Fluid, Retina">
    <link rel="shortcut icon" href="img/favicon.png">

    <title>DPWR 1000a</title>

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
          <a href="index.html" class="logo" >DPWR<span>1000a</span></a>
          <!--logo end-->
          <div class="nav notify-row" id="top_menu">
            <!--  notification start -->
            <ul class="nav top-menu">
              <!-- settings start -->
              <!-- settings end -->
              <!-- inbox dropdown start-->
              <!-- inbox dropdown end -->
              <!-- notification dropdown start-->
              <!-- notification dropdown end -->
            </ul>
          </div>
      </header>
      <!--header end-->

      <!--main content start-->
          <section class="wrapper">
            <form class="form-signin" action="/" method="post">
              <h2 class="form-signin-heading">Sign in required</h2>
              <div class="login-wrap">
                  <input type="text" class="form-control" placeholder="User ID" name="LOGIN_USER" autofocus>
                  <input type="password" class="form-control" placeholder="Password" name="LOGIN_PASSWORD">
                  <label class="checkbox">
                      <input type="checkbox" value="remember-me"> Remember me
                      <span class="pull-right">
                          <a data-toggle="modal" href="#myModal"> Forgot Password?</a>
                      </span>
                  </label>
                  <button class="btn btn-lg btn-login btn-block" type="submit">Sign in</button>
                  <div class="row">
                    <div class="col-lg-12">
                      <span style="text-align:center;font-weight:bold;">[DPWR]VAR:$http->{SESSION}->param('login-msg')[/DPWR]</span>
                    </div>
                  </div>
              </div>

                <!-- Modal -->
                <div aria-hidden="true" aria-labelledby="myModalLabel" role="dialog" tabindex="-1" id="myModal" class="modal fade">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                <h4 class="modal-title">Forgot Password ?</h4>
                            </div>
                            <div class="modal-body">
                                <p>Enter user name below, password will be sent to registered email address.</p>
                                <input type="text" name="LOGIN_RESET_USER" placeholder="User ID" autocomplete="off" class="form-control placeholder-no-fix">

                            </div>
                            <div class="modal-footer">
                                <button data-dismiss="modal" class="btn btn-default" type="button">Cancel</button>
                                <button class="btn btn-success" type="button">Submit</button>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- modal -->
            </form>
          </section>
      <!--main content end-->

      <!--footer start-->
      <section class="wrapper">
          <footer class="site-footer">
		    <table width="99%">
			  <tr>
			    <td width="20%" style="text-align:left;font-weight:bold;" class="clock">
				  <ul style="width: 300px;margin:0 auto;padding:0px;list-style:none;text-align: center;">
					<li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" id="Date"></li>
					<li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" >&nbsp;&nbsp;&nbsp</li>
				    <li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" id="hours"></li>
					<li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" id="point">:</li>
					<li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" id="min"></li>
					<li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" id="point">:</li>
					<li style="display:inline;font-color:black;text-align:center;font-family:Arial, Helvetica, sans-serif;text-shadow: 0 0 0px #80c6ff;" id="sec"></li>
                  </ul>
				</td>
			    <td width="58%" style="text-align:center;font-weight:bold;">[DPWR]VAR:$http->{PARAMS}->{TITLE}[/DPWR]</td>
				<td width="20%" style="text-align:center;font-weight:bold;">v[DPWR]VAR:${PROGRAMVERSION}[/DPWR] &copy; Philip Smart, [DPWR]VAR:${PROGRAMDATE}[/DPWR]&nbsp;&nbsp;</td>
			  </tr>
			</table>
          </footer>
      </section>

      <!--footer end-->
  </section>

    <!-- js placed at the end of the document so the pages load faster -->

    <script src="js/jquery.js"></script>
    <script type="text/javascript" src="js/inputmask/jquery.inputmask.js"></script>
    <script type="text/javascript" src="js/inputmask/jquery.inputmask.date.extensions.js"></script>
    <script type="text/javascript" src="js/inputmask/jquery.inputmask.extensions.js"></script>
    <script type="text/javascript" src="js/inputmask/jquery.inputmask.numeric.extensions.js"></script>
    <script type="text/javascript" src="js/inputmask/jquery.inputmask.phone.extensions.js"></script>
    <script type="text/javascript" src="js/inputmask/jquery.inputmask.regex.extensions.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/jquery-ui-1.9.2.custom.min.js"></script>
    <script src="js/jquery-migrate-1.2.1.min.js"></script>
    <script class="include" type="text/javascript" src="js/jquery.dcjqaccordion.2.7.js"></script>
    <script src="js/jquery.scrollTo.min.js"></script>
    <script src="js/jquery.nicescroll.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript" src="assets/advanced-datatable/media/js/jquery.dataTables.js"></script>
    <script type="text/javascript" src="assets/gritter/js/jquery.gritter.js"></script>
    <script type="text/javascript" src="assets/data-tables/DT_bootstrap.js"></script>
    <script src="js/respond.min.js" ></script>
    <script type="text/javascript" src="js/jquery.pulsate.min.js"></script>

    <!--right slidebar-->
    <script src="js/slidebars.min.js"></script>

    <!--dynamic table initialization -->
    <script src="js/dynamic_table_init.js"></script>

    <!--custom switch 
-->
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
<!--
    <script type="text/javascript" src="assets/bootstrap-inputmask/bootstrap-inputmask.min.js"></script>
-->

    <!--script for this page-->
    <script src="js/form-component.js"></script>

    <!--common script for all pages-->
    <script src="js/common-scripts.js"></script>
    <script src="js/gritter.js" type="text/javascript"></script>
    <script src="js/pulstate.js" type="text/javascript"></script>
    <script src="js/advanced-form-components.js"></script>

<!--
    <script src="js/jquery.input-ip-address-control-1.0.min.js"></script>
-->
    <script type="text/javascript" src="js/user.js"></script>
<script>
$(document).ready(function(){
    $(":input").inputmask();
});
</script>
  </body>
</html>
