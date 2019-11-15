            <div class="row-fluid sortable">        
                <div class="box span12">
                    <div class="box-header well" data-original-title>
                        <h2><i class="fa fa-exchange"></i> Read Port Input State</h2>
                        <div class="box-icon">
                            <a href="#" class="btn btn-read-iocontrol-setting btn-round"><i class="icon-cog"></i></a>
                            <a href="#" class="btn btn-minimize btn-round"><i class="icon-chevron-up"></i></a>
                            <a href="#" class="btn btn-close btn-round"><i class="icon-remove"></i></a>
                        </div>
                    </div>
                    <div class="box-content">
                      <table class="display compact readinputtable" cellspacing="0">

                        <thead>
                        <c:forEach var="idx" begin="0" end="1">
                          <c:if test="${idx == 0}">
                          <tr>
                          </c:if>
                            <th class="table-title-left"   width="4%">PORT</th>
                            <th class="table-title-left"   width="10%">NAME</th>
                            <th class="table-title-left"   width="25%">DESCRIPTION</th>
                            <th class="table-title-center" width="10%">OFF/ON</th>
                            <c:if test="${idx == 1}">
                          </tr>
                          </c:if>
                        </c:forEach>
                        </thead>   

                        <tbody>
                        <c:set var="toggle" value="0"/>
                        <c:forEach items="${io.portList}" var="port" varStatus="idx">
                          <c:if test="${port.mode eq 'INPUT'}">
                            <c:if test="${toggle == 0}">
                          <tr>
                            </c:if>
                            <td class="table-center" align="center">${idx.index}</td>
                            <td class="table-center">${port.name}</td>
                            <td class="table-center">${port.description}</td>
                            <td class="table-center">
                            <c:choose>
                              <c:when test="${port.state eq 'OFF'}">
                              <div class="btn-group btn-toggle on-off-switch" id="id_ifInputState_${idx.index}" value="OFF"> 
                                <button class="btn btn-round btn-green btn-xs <c:if test="${port.state eq 'OFF'}">active</c:if>" id="id_ifInputState_OFF_${idx.index}">OFF</button>
                                <button class="btn btn-round btn-grey btn-xs  <c:if test="${port.state eq 'ON'}">active</c:if>" id="id_ifInputState_ON_${idx.index}">ON</button>
                              </div>
                              </c:when>
                              <c:otherwise>
                              <div class="btn-group btn-toggle on-off-switch" id="id_ifInputState_${idx.index}" value="ON"> 
                                <button class="btn btn-round btn-grey btn-xs  <c:if test="${port.state eq 'OFF'}">active</c:if>" id="id_ifInputState_OFF_${idx.index}">OFF</button>
                                <button class="btn btn-round btn-green btn-xs <c:if test="${port.state eq 'ON'}">active</c:if>" id="id_ifInputState_ON_${idx.index}">ON</button>
                              </div>
                              </c:otherwise>
                            </c:choose>
                            </td>
                              <c:if test="${toggle == 1}">
                          </tr>
                            </c:if>
                            <c:set var="toggle" value="${toggle + 1}"/>
                            <c:if test="${toggle == 2}">
                              <c:set var="toggle" value="0"/>
                            </c:if>
                          </c:if>
                        </c:forEach>
                        <c:if test="${toggle == 2}">
                          </tr>
                        </c:if>
                        </tbody>
                      </table>            
                      <table>
                        <thead>
                          <tr></tr>
                        </thead>
                        <tbody>
                          <tr>
                            <td align="center" width="33%">
                              <div class="row" id="id_ifControlMsg" value="UNLOCKED" style="color:${sessionScope.NotificationColour}">${sessionScope.Notification}</div>
                            </td>
                            <td width="33%">&nbsp;
                            </td>
                            <td width="33%">&nbsp;
                            </td>
                          </tr>
                            <tr>
                            <td align="center" width="33%">
                            </td>
                            <td align="right" width="33%">&nbsp;
                            </td>
                            <td align="left" width="33%">&nbsp;
                            </td>
                            </tr>
                        </tbody>
                      </table>
                    </div>
                </div><!--span-->
            </div><!--row-->
