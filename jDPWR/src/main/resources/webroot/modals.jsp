<!-- c:set var="set_output_settings_modal" value="true"/ -->
<!-- c:set var="set_output_settings_modal" value="false"/ -->
<!-- c:if test="${read_input_settings_modal != null && read_input_settings_modal == 'true'}" -->

        <!-- Modal for set output settings on IO Control Menu -->
        <div tabindex="-1" class="modal fade" id="id_setIOControlModal" style="display: none;" data-keyboard="false" data-backdrop="static" data-width="620">
          <div class="modal-header">
            <button class="close" aria-hidden="true" type="button" data-dismiss="modal">x</button>
            <h3>Settings</h3>
          </div>
          <div class="modal-body" align="center">
            <div class="box span7">
              <div class="box-header well" data-original-title>
                <h2> Mode</h2>
              </div>
              <div>
                <table>
                  <tbody>
                    <tr>
                      <td align="center" width="33%">
                        <label class="radio">
                          <input type="radio"
                                 name="settings"
                                 id="id_setRadioAllOnApply"
                                 class="all-on-apply"
                                 <c:if test="${sessionScope.AllOnApply == 'true'}">checked</c:if>/> Changes On Apply
                        </label>
                      </td>
                      <td align="right" width="33%">
                        <label class="radio">
                          <input type="radio"
                                 name="settings"
                                 id="id_setRadioOff"
                                 <c:if test="${sessionScope.AllOnApply == 'false'}">checked</c:if>/> Disable
                        </label>
                      </td>
                      <td align="left" width="33%">
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
            <div class="box span7">
              <div class="box-header well" data-original-title>
                <h2> Timeouts</h2>
              </div>
              <div>
                <table width="100%">
                  <tr>
                    <td class="refresh-timeout">Refresh Time: <input type="text" id="id_setRefreshTimeout" value="${sessionScope.RefreshTime}" class="numeric"/>&nbsp;(sec)</td>
                    <td width="10%">&nbsp;</td>
                    <td class="notification-timeout">Notification Time: <input type="text" id="id_setNotificationTimeout" value="${sessionScope.NotificationTime}" class="numeric"/>&nbsp;(sec)</td>
                  </tr>
                </table>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <a href="#" class="btn" data-dismiss="modal">Close</a>
          </div>
        </div>
        <!-- End of Modal for set output settings on IO Control Menu -->

        <!-- Modal for read input settings on IO Control Menu -->
        <div tabindex="-1" class="modal fade" id="id_readIOControlModal" style="display: none;" data-keyboard="false" data-backdrop="static" data-width="460">
          <div class="modal-header">
            <!--<button type="button" class="close" data-dismiss="modal">×</button>-->
            <h3>Settings</h3>
          </div>
          <div align="center" class="modal-body">
<!--
            <div class="box span5">
              <div class="box-header well" data-original-title>
                <h2> Mode</h2>
              </div>
              <table>
                <tbody>
                  <tr>
                    <td align="right" width="33%">
                      <label class="radio">
                        <input type="radio"
                               name="settings"
                               id="id_readRadioOff"
                               <c:if test="${sessionScope.AllOnApply == 'false'}">checked</c:if>
                        > Disable
                      </label>
                    </td>
                    <td align="left" width="33%">
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
-->
            <div class="box span5">
              <div class="box-header well" data-original-title>
                <h2> Timeouts</h2>
              </div>
              <table>
                <tr>
                  <td class="pull-left refresh-timeout">Refresh Time: <input type="text" id="id_readRefreshTimeout" value="${sessionScope.RefreshTime}" class="numeric"/>&nbsp;(sec)</td>
                  <td width="10%">&nbsp;</td>
                  <td class="pull-right">&nbsp;</td>
                </tr>
              </table>
            </div>
          </div>
          <div class="modal-footer">
            <a href="#" class="btn" data-dismiss="modal">Close</a>
          </div>
        </div>
        <!-- Modal for read input settings on IO Control Menu -->

        <!-- Modal for setup devices Menu -->
        <div tabindex="-1" class="modal fade" id="id_setupDevicesModal" style="display: none;" data-keyboard="false" data-backdrop="static" data-width="620">
          <div class="modal-header">
            <button class="close" aria-hidden="true" type="button" data-dismiss="modal">x</button>
            <h3>Settings</h3>
          </div>
          <div class="modal-body" align="center">
            <div class="box span7">
              <div class="box-header well" data-original-title>
                <h2> Mode</h2>
              </div>
              <div>
                <table>
                  <tbody>
                    <tr>
                      <td align="right" width="33%">
                        <label class="radio">
                          <input type="radio"
                                 name="settings"
                                 id="id_setRadioOff"
                                 <c:if test="${sessionScope.AllOnApply == 'false'}">checked</c:if>/> Disable
                        </label>
                      </td>
                      <td align="left" width="33%">
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <a href="#" class="btn" data-dismiss="modal">Close</a>
          </div>
        </div>
        <!-- End of Modal for set output settings on IO Control Menu -->

        <!--
        <div class="modal hide fade" id="myModal">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">×</button>
                <h3>Settings</h3>
            </div>
            <div class="modal-body">
              <table>
                <thead>
                  <tr></tr>
                </thead>
                <tbody>
                  <tr>
                    <td align="right" width="33%">&nbsp;
        <div class="btn-group" data-toggle="buttons">
                      <input type="checkbox" class="m-bot15"
                             <c:if test="${sessionScope.AutoRefresh == 'true'}">checked</c:if>
                             id="id_ifAutoRefresh" > Auto Refresh
                      </input>
                    </td>
                    <td align="left" width="33%">&nbsp;
                      <input type="checkbox" class="m-bot15"
                             <c:if test="${sessionScope.SetOnApply == 'true'}">checked</c:if>
                             id="id_ifSetAllOnApply" > Changes On Apply
                      </input>
                    </td>
                    </div>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="modal-footer">
                <a href="#" class="btn" data-dismiss="modal">Close</a>
                <a href="#" class="btn btn-primary">Save changes</a>
            </div>
        </div>
        -->
