      <section id="main-content">
        <section class="wrapper">
          <section class="panel">
            <div class="panel">
              <header class="panel-heading">
                <strong>Setup Email</strong>
              </header>
              <div class="panel-body">
                <form class="cmxform form-horizontal" id="id_formChangeEmail" method="post">
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Select Mail Service</label>
                    <div class="col-lg-6">
                      <td style="text-align:center;">
                        <div class="btn-group btn-toggle mail-selector" id="id_ifMailSelector"
                             value="[DPWR]VAR:$http->{PARAMS}->{EMAIL_SMTP_OR_POP3}[/DPWR]"> 
                          <button class="btn btn-round btn-green btn-xs active" 
                                  id="id_ifMailSelector_NONE">
                                  NONE
                          </button>
                          <button class="btn btn-round btn-grey btn-xs" 
                                  id="id_ifMailSelector_SMTP">
                                  SMTP
                          </button>
                          <button class="btn btn-round btn-grey btn-xs" 
                                  id="id_ifMailSelector_POP3">
                                  POP3
                          </button>
                        </div>
                      </td>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Mail Server Host</label>
                    <div class="col-lg-3">
                      <input class="form-control " id="id_ifMailServer" name="SMTP_SERVER_IP"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{EMAIL_SMTP_SERVER_IP}[/DPWR]"/>
                    </div>
                    <label class="col-lg-2 control-label">Mail Server Port</label>
                    <div class="col-lg-1">
                      <input class="form-control " data-inputmask="'mask': '99999'"
                             id="id_ifMailServerPort" name="SMTP_SERVER_PORT"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{EMAIL_SMTP_SERVER_PORT}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">POP3 Server Host</label>
                    <div class="col-lg-3">
                      <input class="form-control " id="id_ifPop3Server" name="POP3_SERVER_IP"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{EMAIL_POP3_SERVER_IP}[/DPWR]"/>
                    </div>
                    <label class="col-lg-2 control-label">POP3 Server Port</label>
                    <div class="col-lg-1">
                      <input class="form-control " data-inputmask="'mask': '99999'"
                             id="id_ifPop3ServerPort" name="POP3_SERVER_PORT" placeholder=""
                             value="[DPWR]VAR:$http->{PARAMS}->{EMAIL_POP3_SERVER_PORT}[/DPWR]">
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">User Name</label>
                    <div class="col-lg-3">
                      <input class="form-control " id="id_ifUserName" name="USERNAME"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{EMAIL_USERNAME}[/DPWR]"/>
                    </div>
                    <label class="col-lg-1 control-label">Password</label>
                    <div class="col-lg-2">
                      <input class="form-control " id="id_ifPassword" name="PASSWORD"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{EMAIL_PASSWORD}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label for="cemail" class="col-lg-2 control-label">Email Sender</label>
                    <div class="col-lg-6">
                      <input class="form-control " 
                             data-inputmask="'alias': 'email'"
                             id="id_ifSender" type="email" name="SENDER"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{EMAIL_SENDER}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label  class="col-lg-2 control-label">Email Recipient 1</label>
                    <div class="col-lg-6">
                      <input class="form-control " 
                             data-inputmask="'alias': 'email'"
                             id="id_ifRecipient1" type="email" name="RECIPIENT1"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{EMAIL_RECIPIENT1}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label  class="col-lg-2 control-label">Email Recipient 2</label>
                    <div class="col-lg-6">
                      <input class="form-control " 
                             data-inputmask="'alias': 'email'"
                             id="id_ifRecipient2" type="email" name="RECIPIENT2"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{EMAIL_RECIPIENT2}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label  class="col-lg-2 control-label">Email Recipient 3</label>
                    <div class="col-lg-6">
                      <input class="form-control " 
                             data-inputmask="'alias': 'email'"
                             id="id_ifRecipient3" type="email" name="RECIPIENT3"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{EMAIL_RECIPIENT3}[/DPWR]"/>
                    </div>
                  </div> 
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Mail Subject</label>
                    <div class="col-lg-6">
                      <input type="text" class="form-control"
                             id="id_ifSubject" name="SUBJECT"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{EMAIL_SUBJECT}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="control-label col-lg-2">Mail Body</label>
                    <div class="col-md-9">
                      <textarea class="wysihtml5 form-control" rows="5" disabled=''
                                id="id_ifMailBody" placeholder=" " name="MAILBODY"
                               >[DPWR]VAR:$http->{PARAMS}->{EMAIL_MAILBODY}[/DPWR]</textarea>
                    </div>
                  </div>
                  <div class="row">
                    <div class="col-lg-8">
                      <div class="col-lg-3">
                        <button type="submit" class="btn btn-info" value="SAVE"   id="id_ifChangeEmail_SAVE">Save</button>
                        <button type="submit" class="btn btn-red"  value="CANCEL" id="id_ifChangeEmail_CANCEL">Cancel</button>
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
