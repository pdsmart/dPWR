      <section id="main-content">
        <section class="wrapper">
          <section class="panel">
            <div class="panel">
              <header class="panel-heading">
                <strong>Setup DDNS</strong>
              </header>
              <div class="panel-body">
                <form class="cmxform form-horizontal" id="id_formChangeDDNS" method="post">
                  <div class="form-group">
                    <label class="col-lg-2 control-label">DDNS Enable</label>
                    <div class="col-lg-6">
                      <td style="text-align:center;">
                        <div class="btn-group btn-toggle ddns-selector" id="id_ifDDNSSelector"
                             value="[DPWR]VAR:$http->{PARAMS}->{DDNS_ENABLE}[/DPWR]"> 
                          <button class="btn btn-round btn-green btn-xs active" 
                                  id="id_ifDDNSSelector_DISABLED">
                                  DISABLED
                          </button>
                          <button class="btn btn-round btn-grey btn-xs" 
                                  id="id_ifDDNSSelector_ENABLED">
                                  ENABLED
                          </button>
                        </div>
                      </td>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">DDNS Server Host/IP</label>
                    <div class="col-lg-4">
                      <!--data-inputmask="'alias': 'ip'"-->
                      <input class="form-control " 
                             id="id_ifServerIP" name="SERVER_IP"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{DDNS_SERVER_IP}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Client Domain</label>
                    <div class="col-lg-4">
                      <input class="form-control " 
                             data-inputmask-regex="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$"
                             data-inputmask="'Regex'"
                             id="id_ifClientDomain" name="CLIENT_DOMAIN"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{DDNS_CLIENT_DOMAIN}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Client User Name</label>
                    <div class="col-lg-3">
                      <input class="form-control " id="id_ifClientUserName" name="CLIENT_USERNAME"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{DDNS_CLIENT_USERNAME}[/DPWR]"/>
                    </div>
                    <label class="col-lg-2 control-label">Client Password</label>
                    <div class="col-lg-2">
                      <input class="form-control " id="id_ifClientPassword" name="CLIENT_PASSWORD"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{DDNS_CLIENT_PASSWORD}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Proxy Enable</label>
                    <div class="col-lg-6">
                      <td style="text-align:center;">
                        <div class="btn-group btn-toggle ddns-selector" id="id_ifDDNSProxySelector"
                             value="[DPWR]VAR:$http->{PARAMS}->{DDNS_PROXY_ENABLE}[/DPWR]"> 
                          <button class="btn btn-round btn-green btn-xs active" 
                                  id="id_ifDDNSProxySelector_DISABLED">
                                  DISABLED
                          </button>
                          <button class="btn btn-round btn-grey btn-xs" 
                                  id="id_ifDDNSProxySelector_ENABLED">
                                  ENABLED
                          </button>
                        </div>
                      </td>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Proxy IP</label>
                    <div class="col-lg-3">
                      <input class="form-control " id="id_ifProxyIP" name="PROXY_IP"
                             data-inputmask="'alias': 'ip'"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{DDNS_PROXY_IP}[/DPWR]"/>
                    </div>
                    <label class="col-lg-2 control-label">Proxy Port</label>
                    <div class="col-lg-1">
                      <input class="form-control " data-inputmask="'mask': '99999'"
                             id="id_ifProxyPort" name="PROXY_PORT"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{DDNS_PROXY_PORT}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="row">
                    <div class="col-lg-8">
                      <div class="col-lg-3">
                        <button type="submit" class="btn btn-info" value="SAVE"   id="id_ifChangeDDNS_SAVE">Save</button>
                        <button type="submit" class="btn btn-red"  value="CANCEL" id="id_ifChangeDDNS_CANCEL">Cancel</button>
                      </div>
                      <div class="col-lg-8">
                        <span style="text-align:center;font-weight:bold;colour:red">
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
