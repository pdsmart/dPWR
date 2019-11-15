      <section id="main-content">
        <section class="wrapper">
          <section class="panel">
            <div class="panel">
              <header class="panel-heading">
                <strong>Change Password</strong>
              </header>
              <div class="panel-body">
                <form class="form-horizontal" role="form" id="id_formChangePassword" method="post">
                  <div class="form-group">
                    <label  class="col-lg-2 control-label">Current Password</label>
                    <div class="col-lg-6">
                      <input type="password" class="form-control" name="CURRENT_PASSWORD" id="id_ifCurremtPassword" placeholder=" ">
                    </div>
                  </div>
                  <div class="form-group">
                    <label  class="col-lg-2 control-label">New Password</label>
                    <div class="col-lg-6">
                      <input type="password" class="form-control" name="NEW_PASSWORD" id="id_ifNewPassword" placeholder=" ">
                    </div>
                  </div>
                  <div class="form-group">
                    <label  class="col-lg-2 control-label">Re-type New Password</label>
                    <div class="col-lg-6">
                      <input type="password" class="form-control" name="VERIFY_PASSWORD" id="id_ifVerifyPassword" placeholder=" ">
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
                          [DPWR]VAR:$http->{SESSION}->param('setpwd-msg')[/DPWR]
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
