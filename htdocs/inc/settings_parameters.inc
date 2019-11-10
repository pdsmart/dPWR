      <section id="main-content">
        <section class="wrapper">
          <section class="panel">
            <div class="panel">
              <header class="panel-heading">
                <strong>Parameters</strong>
              </header>
              <div class="panel-body">
                <form class="form-horizontal" role="form" id="id_formParameters" method="post">
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Title</label>
                    <div class="col-lg-4">
                      <input class="form-control " id="id_ifTitle" name="TITLE"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{TITLE}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Log File</label>
                    <div class="col-lg-4">
                      <input class="form-control " id="id_ifLogFile" name="LOGFILE"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{LOGFILE}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">HTTP Server Host (IP)</label>
                    <div class="col-lg-4">
                      <input class="form-control " id="id_ifHttpServerHost" name="HTTP_SERVER_HOST"
                             data-inputmask="'alias': 'ip'"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{HTTP_SERVER_HOST}[/DPWR]"/>
                    </div>
                    <label class="col-lg-2 control-label">HTTP Server Port</label>
                    <div class="col-lg-1">
                      <input class="form-control " data-inputmask="'mask': '99999'"
                             id="id_ifHttpServerPort" name="HTTP_SERVER_PORT"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{HTTP_SERVER_PORT}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">HTTP Document Path</label>
                    <div class="col-lg-4">
                      <input class="form-control " id="id_ifHttpDocPath" name="HTTP_DOC_PATH"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{HTTP_DOC_PATH}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">HTTP Log File</label>
                    <div class="col-lg-4">
                      <input class="form-control " id="id_ifHttpLogFile" name="HTTP_LOGFILE"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{HTTP_LOGFILE}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label  class="col-lg-2 control-label">HTTP Password</label>
                    <div class="col-lg-4">
                      <input type="password" class="form-control" name="HTTP_PASSWORD" id="id_ifHttpPassword"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{HTTP_PASSWORD}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">HTTP Max Retries</label>
                    <div class="col-lg-1">
                      <input class="form-control " data-inputmask="'mask': '99999'"
                             id="id_ifHttpMaxRetries" name="HTTP_MAX_RETRIES"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{HTTP_MAX_RETRIES}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">HTTP Session Timeout</label>
                    <div class="col-lg-1">
                      <input class="form-control " data-inputmask="'mask': '99999'"
                             id="id_ifHttpSessionTimeout" name="HTTP_SESSION_TIMEOUT"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{HTTP_SESSION_TIMEOUT}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="row">
                    <div class="col-lg-8">
                      <div class="col-lg-3">
                        <button type="submit" class="btn btn-info" value="SAVE"   id="id_ifChangePassword_SAVE">Save</button>
                        <button type="submit" class="btn btn-red"  value="CANCEL" id="id_ifChangePassword_CANCEL">Cancel</button>
                      </div>
                      <div class="col-lg-8">
                        <span style="text-align:center;font-weight:bold;color:red">
                          [DPWR]VAR:$http->{SESSION}->param('session-msg')[/DPWR]
                        </span>
                      </div>
                    </div>
				  </div>
                </form>
              </div>
            </div>
          </section>
        </section>
      </section>
