<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset"utf-8">
    <title>DPWR 1000a</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Digital Power Controller">
    <meta name="author" content="Philip Smart">

    <!-- Bootstrap core CSS -->
    <link href="css/bootstrap-3.3.6/bootstrap.min.css" rel="stylesheet">
    <link href="css/bootstrap-3.3.6/bootstrap-theme.min.css" rel="stylesheet">

    <!-- Bootstrap additions -->
    <link href="css/bootstrap/modal-2.2.5.css" rel="stylesheet">

    <!-- DataTables and Editor -->
    <link href="css/DataTables-1.10.12/jquery.dataTables.css" rel="stylesheet" />
    <link href="css/DataTables-1.10.12/buttons.dataTables.css" rel="stylesheet" />
    <link href="css/DataTables-1.10.12/select.dataTables.css" rel="stylesheet" />
    <link href="css/Editor-1.5.6/editor.dataTables.css" rel="stylesheet" />

    <link href="css/Selectize-0.12.2/selectize.bootstrap3.css" rel="stylesheet" />
    <link href="css/editor.selectize.css" rel="stylesheet" />
<!--    <link href="css/Chosen-1.6.2/chosen.css" rel="stylesheet" /> -->

    <!--external css-->
    <link href="css/font-awesome.css" rel="stylesheet" />
    <link href='css/opa-icons.css' rel='stylesheet'>

    <!-- The HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <!-- The fav icon -->
    <link rel="shortcut icon" href="img/power-switch.ico">

    <!-- Set default style placeholder, this will be overriden by javascript using a cookie. -->
    <link id="bs-css" rel="stylesheet">

    <!-- Animation library -->
    <link rel="stylesheet" type="text/css" href="css/animate.min.css" />    

    <!-- App specific customisation -->
    <link rel="stylesheet" type="text/css" href="css/user.css" />    
</head>

<body>
    <!-- topbar starts -->
    <div class="navbar">
        <div class="navbar-inner">
            <div class="container-fluid">
              <div class="row-fluid">
                <a href="#" data-toggle="offcanvas"><i class="pull-left fa fa-navicon fa-2x"></i></a>
                  <span style="font-size:24px">&nbsp;DPWR 1000a</span>
                </a>
              </div>
            </div>
        </div>
    </div>
    <!-- topbar ends -->

    <noscript>
      <div class="alert alert-block span10">
        <h4 class="alert-heading">Warning!</h4>
        <p>You need to have <a href="http://en.wikipedia.org/wiki/JavaScript" target="_blank">JavaScript</a> enabled to use this site.</p>
      </div>
    </noscript>

    <div class="container-fluid">

      <!-- left menu starts -->
      <nav class="nav span-menu active" id="leftmenu">
        <div class="navmenu-inner nav-tabs nav nav-collapse">
          <span style="font-size:14px;text-align:center;margin-bottom: 5px;" class="well nav-header">Main Menu</span>

          <li class="divider"></li>

          <li>
            <a class="ajaxload accordion-menu nav-header" data-url="dashboard.jsp"><i class="accordion-icon fa fa-home"></i><span class="hidden-tablet menu-indent">Dashboard</span></a>
          </li>

          <!-- I/O Control Sub-Menu -->
          <li>
            <a class="tree-toggle nav-header"><i class="accordion-icon fa fa-sitemap"></i><span class="hidden-tablet menu-indent">I/O Control</span></a>
            <ul class="nav nav-list tree main-menu">
              <li><a data-url="setoutputs.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-plug"></i><span>Set Outputs</span></a></li>
              <li><a data-url="readinputs.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-exchange"></i><span>Read Inputs</span></a></li>
              <li><a data-url="combined.jsp" class="ajaxload accordion-menu-indent"><i   class="accordion-icon fa fa-random"></i><span>Combined</span></a></li>
            </ul>
          </li>

          <!-- I/O Setup Sub-Menu -->
          <li>
            <a class="tree-toggle nav-header"><i class="accordion-icon fa fa-gears"></i><span class="hidden-tablet menu-indent">I/O Setup</span></a>
            <ul class="nav nav-list tree main-menu">
              <li><a data-url="setup-devices.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-laptop"></i><span>Devices</span></a></li>
              <li><a data-url="setup-ports.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-bolt"></i><span>Ports</span></a></li>
              <li><a data-url="setup-timers.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-clock-o"></i><span>Timers</span></a></li>
              <li><a data-url="setup-ping.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-exchange"></i><span>Ping</span></a></li>
            </ul>
          </li>
 
          <!-- Status Sub-Menu -->
          <li>
            <a class="tree-toggle nav-header"><i class="accordion-icon fa fa-question-circle"></i><span class="hidden-tablet menu-indent">Status</span></a>
            <ul class="nav nav-list tree main-menu">
              <li><a data-url="dash.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-plug"></i><span>I/O Parameters</span></a></li>
              <li><a data-url="dash.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-plug"></i><span>Active I/O Ports</span></a></li>
              <li><a data-url="dash.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-plug"></i><span>All I/O Ports</span></a></li>
              <li><a data-url="dash.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-plug"></i><span>Device Log</span></a></li>
              <li><a data-url="dash.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-plug"></i><span>Web Server Log</span></a></li>
            </ul>
          </li>

          <!-- Settings Sub-Menu -->
          <li>
            <a class="tree-toggle nav-header"><i class="accordion-icon fa fa-cogs"></i><span class="hidden-tablet menu-indent">Settings</span></a>
            <ul class="nav nav-list tree main-menu">
              <li><a data-url="dash.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-plug"></i><span>DDNS</span></a></li>
              <li><a data-url="dash.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-plug"></i><span>E-Mail</span></a></li>
              <li><a data-url="dash.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-plug"></i><span>Users</span></a></li>
              <li><a data-url="dash.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-plug"></i><span>Time</span></a></li>
              <li><a data-url="dash.jsp" class="ajaxload accordion-menu-indent"><i class="accordion-icon fa fa-plug"></i><span>Parameters</span></a></li>
              <li>
                <a class="tree-toggle nav-header"><i class="sub-accordion-icon fa fa-picture-o"></i><span class="hidden-tablet sub-menu-indent">Theme</span></a>
                <ul class="nav nav-list tree main-menu btn-group" data-toggle="buttons">
                  <li class="theme <c:if test="${sessionScope.CurrentTheme == 'classic'}">active</c:if>">
                    <span class="active accordion-menu-indent">Classic</span><i class="accordion-icon"></i>
                    <span class="themeselect" data-value="classic">
                      <c:choose>
                        <c:when test="${sessionScope.CurrentTheme != null && sessionScope.CurrentTheme == 'classic'}">
                          <i class="fa fa-check-square-o"></i>
                        </c:when>
                        <c:otherwise>
                          <i class="fa fa-square-o"></i>
                        </c:otherwise>
                      </c:choose>
                    </span>
                  </li>
                  <li class="theme <c:if test="${sessionScope.CurrentTheme == 'cerulean'}">active</c:if>">
                    <span class="accordion-menu-indent">Cerulean</span><i class="accordion-icon"></i>
                    <span class="themeselect" data-value="cerulean">
                      <c:choose>
                        <c:when test="${sessionScope.CurrentTheme != null && sessionScope.CurrentTheme == 'cerulean'}">
                          <i class="fa fa-check-square-o"></i>
                        </c:when>
                        <c:otherwise>
                          <i class="fa fa-square-o"></i>
                        </c:otherwise>
                      </c:choose>
                    </span>
                  </li>
                  <li class="theme <c:if test="${sessionScope.CurrentTheme == 'cyborg'}">active</c:if>">
                    <span class="accordion-menu-indent">Cyborg</span><i class="accordion-icon"></i>
                    <span class="themeselect" data-value="cyborg">
                      <c:choose>
                        <c:when test="${sessionScope.CurrentTheme != null && sessionScope.CurrentTheme == 'cyborg'}">
                          <i class="fa fa-check-square-o"></i>
                        </c:when>
                        <c:otherwise>
                          <i class="fa fa-square-o"></i>
                        </c:otherwise>
                      </c:choose>
                    </span>
                  </li>
                  <li class="theme <c:if test="${sessionScope.CurrentTheme == 'journal'}">active</c:if>">
                    <span class="accordion-menu-indent">Journal</span><i class="accordion-icon"></i>
                    <span class="themeselect" data-value="journal">
                      <c:choose>
                        <c:when test="${sessionScope.CurrentTheme != null && sessionScope.CurrentTheme == 'journal'}">
                          <i class="fa fa-check-square-o"></i>
                        </c:when>
                        <c:otherwise>
                          <i class="fa fa-square-o"></i>
                        </c:otherwise>
                      </c:choose>
                    </span>
                  </li>
                  <li class="theme <c:if test="${sessionScope.CurrentTheme == 'redy'}">active</c:if>">
                    <span class="accordion-menu-indent">Redy</span><i class="accordion-icon"></i>
                    <span class="themeselect" data-value="redy">
                      <c:choose>
                        <c:when test="${sessionScope.CurrentTheme != null && sessionScope.CurrentTheme == 'redy'}">
                          <i class="fa fa-check-square-o"></i>
                        </c:when>
                        <c:otherwise>
                          <i class="fa fa-square-o"></i>
                        </c:otherwise>
                      </c:choose>
                    </span>
                  </li>
                  <li class="theme <c:if test="${sessionScope.CurrentTheme == 'simplex'}">active</c:if>">
                    <span class="accordion-menu-indent">Simplex</span><i class="accordion-icon"></i>
                    <span class="themeselect" data-value="simplex">
                      <c:choose>
                        <c:when test="${sessionScope.CurrentTheme != null && sessionScope.CurrentTheme == 'simplex'}">
                          <i class="fa fa-check-square-o"></i>
                        </c:when>
                        <c:otherwise>
                          <i class="fa fa-square-o"></i>
                        </c:otherwise>
                      </c:choose>
                    </span>
                  </li>
                  <li class="theme <c:if test="${sessionScope.CurrentTheme == 'slate'}">active</c:if>">
                    <span class="accordion-menu-indent">Slate</span><i class="accordion-icon"></i>
                    <span class="themeselect" data-value="slate">
                      <c:choose>
                        <c:when test="${sessionScope.CurrentTheme != null && sessionScope.CurrentTheme == 'slate'}">
                          <i class="fa fa-check-square-o"></i>
                        </c:when>
                        <c:otherwise>
                          <i class="fa fa-square-o"></i>
                        </c:otherwise>
                      </c:choose>
                    </span>
                  </li>
                  <li class="theme <c:if test="${sessionScope.CurrentTheme == 'spacelab'}">active</c:if>">
                    <span class="accordion-menu-indent">Spacelab</span><i class="accordion-icon"></i>
                    <span class="themeselect" data-value="spacelab">
                      <c:choose>
                        <c:when test="${sessionScope.CurrentTheme != null && sessionScope.CurrentTheme == 'spacelab'}">
                          <i class="fa fa-check-square-o"></i>
                        </c:when>
                        <c:otherwise>
                          <i class="fa fa-square-o"></i>
                        </c:otherwise>
                      </c:choose>
                    </span>
                  </li>
                  <li class="theme <c:if test="${sessionScope.CurrentTheme == 'united'}">active</c:if>">
                    <span class="accordion-menu-indent">United</span><i class="accordion-icon"></i>
                    <span class="themeselect" data-value="united">
                      <c:choose>
                        <c:when test="${sessionScope.CurrentTheme != null && sessionScope.CurrentTheme == 'united'}">
                          <i class="fa fa-check-square-o"></i>
                        </c:when>
                        <c:otherwise>
                          <i class="fa fa-square-o"></i>
                        </c:otherwise>
                      </c:choose>
                    </span>
                  </li>
                </ul>
              </li>
            </ul>
          </li>
        </div>
        <li>
          <span style="font-size:10px;text-align:center;margin-bottom: 5px;" class="nav-header">&copy; 2018-19 
            <a href="http://www.net2et-ips.com" target="_blank">Philip Smart</a>
          </span>
        </li>
      </nav>

      <!-- Create the main content viewing area, this area is loaded by ajax calls. -->
      <div id="wrapper" class="row-fluid toggled">
        <div id="content" class="page-content-wrapper">

          <!-- Create the information bar, presenting breadcrumb and date time -->
          <div class="breadcrumb" style="padding: 5px 5px 25px 10px;">
            <div id="breadcrumb" style="width: 60%; float: left">
              <li>
                <!-- <a href="/">Home</a> <span class="divider">/</span> -->
              </li>
            </div>
            <div id="clock" style="width: 40%; float: right">
              <ul style="margin: auto;text-align: right;">
                <li class="clockdate" id="Date"></li>
                <li>&nbsp;&nbsp;&nbsp;</li>
                <li class="clocktime"  id="hours"></li>
                <li class="clockpoint" id="point">:</li>
                <li class="clocktime"  id="min"></li>
                <li class="clockpoint" id="point">:</li>
                <li class="clocktime"  id="sec"></li>
              </ul>
            </div>
          </div>
          <!-- End of information bar -->

        <!-- content div closed in including file -->
      <!-- row-fluid closed in including file -->
    <!-- container-fluid closed in including file -->
