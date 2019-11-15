      <section id="main-content">
        <section class="wrapper">
          <section class="panel">
            <div class="panel">
              <header class="panel-heading">
                <strong>Setup Time</strong>
              </header>
              <div class="panel-body">
                <form class="cmxform form-horizontal" id="id_formChangeTime" method="post">
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Select Time Source</label>
                    <div class="col-lg-6">
                      <td style="text-align:center;">
                        <div class="btn-group btn-toggle time-selector" id="id_ifTimeSelector"
                             value="[DPWR]VAR:$http->{PARAMS}->{TIME_LOCAL_OR_NTP}[/DPWR]"> 
                          <button class="btn btn-round btn-green btn-xs active" 
                                  id="id_ifTimeSelector_LOCAL">
                                  LOCAL
                          </button>
                          <button class="btn btn-round btn-grey btn-xs" 
                                  id="id_ifTimeSelector_NTP">
                                  NTP
                          </button>
                        </div>
                      </td>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Date</label>
                    <div class="col-lg-2">
                      <input class="form-control " data-inputmask="'alias': 'date'"
                             id="id_ifLocalDate" name="DATE"
                             value="[DPWR]VAR:DATE[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Time</label>
                    <div class="col-lg-2">
                      <input class="form-control " data-inputmask="'alias': 'hh:mm:ss'"
                             id="id_ifLocalTime" name="TIME"
                             value="[DPWR]VAR:TIME[/DPWR]"/>
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="col-lg-2 control-label">Time Zone</label>
                    <div class="col-lg-4">
                      <select class="form-control " id="id_ifTimeZone" name="NTP_TIMEZONE_OFFSET"
                             value="[DPWR]VAR:$http->{PARAMS}->{TIME_NTP_TIMEZONE_OFFSET}[/DPWR]"/>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 1[/DPWR] data-timeZoneId="1" data-gmtAdjustment="GMT-12:00" data-useDaylightTime="0" value="-12">(GMT-12:00) International Date Line West</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 2[/DPWR] data-timeZoneId="2" data-gmtAdjustment="GMT-11:00" data-useDaylightTime="0" value="-11">(GMT-11:00) Midway Island, Samoa</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 3[/DPWR] data-timeZoneId="3" data-gmtAdjustment="GMT-10:00" data-useDaylightTime="0" value="-10">(GMT-10:00) Hawaii</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 4[/DPWR] data-timeZoneId="4" data-gmtAdjustment="GMT-09:00" data-useDaylightTime="1" value="-9">(GMT-09:00) Alaska</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 5[/DPWR] data-timeZoneId="5" data-gmtAdjustment="GMT-08:00" data-useDaylightTime="1" value="-8">(GMT-08:00) Pacific Time (US & Canada)</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 6[/DPWR] data-timeZoneId="6" data-gmtAdjustment="GMT-08:00" data-useDaylightTime="1" value="-8">(GMT-08:00) Tijuana, Baja California</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 7[/DPWR] data-timeZoneId="7" data-gmtAdjustment="GMT-07:00" data-useDaylightTime="0" value="-7">(GMT-07:00) Arizona</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 8[/DPWR] data-timeZoneId="8" data-gmtAdjustment="GMT-07:00" data-useDaylightTime="1" value="-7">(GMT-07:00) Chihuahua, La Paz, Mazatlan</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 9[/DPWR] data-timeZoneId="9" data-gmtAdjustment="GMT-07:00" data-useDaylightTime="1" value="-7">(GMT-07:00) Mountain Time (US & Canada)</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 10[/DPWR] data-timeZoneId="10" data-gmtAdjustment="GMT-06:00" data-useDaylightTime="0" value="-6">(GMT-06:00) Central America</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 11[/DPWR] data-timeZoneId="11" data-gmtAdjustment="GMT-06:00" data-useDaylightTime="1" value="-6">(GMT-06:00) Central Time (US & Canada)</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 12[/DPWR] data-timeZoneId="12" data-gmtAdjustment="GMT-06:00" data-useDaylightTime="1" value="-6">(GMT-06:00) Guadalajara, Mexico City, Monterrey</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 13[/DPWR] data-timeZoneId="13" data-gmtAdjustment="GMT-06:00" data-useDaylightTime="0" value="-6">(GMT-06:00) Saskatchewan</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 14[/DPWR] data-timeZoneId="14" data-gmtAdjustment="GMT-05:00" data-useDaylightTime="0" value="-5">(GMT-05:00) Bogota, Lima, Quito, Rio Branco</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 15[/DPWR] data-timeZoneId="15" data-gmtAdjustment="GMT-05:00" data-useDaylightTime="1" value="-5">(GMT-05:00) Eastern Time (US & Canada)</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 16[/DPWR] data-timeZoneId="16" data-gmtAdjustment="GMT-05:00" data-useDaylightTime="1" value="-5">(GMT-05:00) Indiana (East)</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 17[/DPWR] data-timeZoneId="17" data-gmtAdjustment="GMT-04:00" data-useDaylightTime="1" value="-4">(GMT-04:00) Atlantic Time (Canada)</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 18[/DPWR] data-timeZoneId="18" data-gmtAdjustment="GMT-04:00" data-useDaylightTime="0" value="-4">(GMT-04:00) Caracas, La Paz</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 19[/DPWR] data-timeZoneId="19" data-gmtAdjustment="GMT-04:00" data-useDaylightTime="0" value="-4">(GMT-04:00) Manaus</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 20[/DPWR] data-timeZoneId="20" data-gmtAdjustment="GMT-04:00" data-useDaylightTime="1" value="-4">(GMT-04:00) Santiago</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 21[/DPWR] data-timeZoneId="21" data-gmtAdjustment="GMT-03:30" data-useDaylightTime="1" value="-3.5">(GMT-03:30) Newfoundland</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 22[/DPWR] data-timeZoneId="22" data-gmtAdjustment="GMT-03:00" data-useDaylightTime="1" value="-3">(GMT-03:00) Brasilia</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 23[/DPWR] data-timeZoneId="23" data-gmtAdjustment="GMT-03:00" data-useDaylightTime="0" value="-3">(GMT-03:00) Buenos Aires, Georgetown</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 24[/DPWR] data-timeZoneId="24" data-gmtAdjustment="GMT-03:00" data-useDaylightTime="1" value="-3">(GMT-03:00) Greenland</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 25[/DPWR] data-timeZoneId="25" data-gmtAdjustment="GMT-03:00" data-useDaylightTime="1" value="-3">(GMT-03:00) Montevideo</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 26[/DPWR] data-timeZoneId="26" data-gmtAdjustment="GMT-02:00" data-useDaylightTime="1" value="-2">(GMT-02:00) Mid-Atlantic</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 27[/DPWR] data-timeZoneId="27" data-gmtAdjustment="GMT-01:00" data-useDaylightTime="0" value="-1">(GMT-01:00) Cape Verde Is.</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 28[/DPWR] data-timeZoneId="28" data-gmtAdjustment="GMT-01:00" data-useDaylightTime="1" value="-1">(GMT-01:00) Azores</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 29[/DPWR] data-timeZoneId="29" data-gmtAdjustment="GMT+00:00" data-useDaylightTime="0" value="0">(GMT+00:00) Casablanca, Monrovia, Reykjavik</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 30[/DPWR] data-timeZoneId="30" data-gmtAdjustment="GMT+00:00" data-useDaylightTime="1" value="0">(GMT+00:00) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 31[/DPWR] data-timeZoneId="31" data-gmtAdjustment="GMT+01:00" data-useDaylightTime="1" value="1">(GMT+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 32[/DPWR] data-timeZoneId="32" data-gmtAdjustment="GMT+01:00" data-useDaylightTime="1" value="1">(GMT+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 33[/DPWR] data-timeZoneId="33" data-gmtAdjustment="GMT+01:00" data-useDaylightTime="1" value="1">(GMT+01:00) Brussels, Copenhagen, Madrid, Paris</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 34[/DPWR] data-timeZoneId="34" data-gmtAdjustment="GMT+01:00" data-useDaylightTime="1" value="1">(GMT+01:00) Sarajevo, Skopje, Warsaw, Zagreb</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 35[/DPWR] data-timeZoneId="35" data-gmtAdjustment="GMT+01:00" data-useDaylightTime="1" value="1">(GMT+01:00) West Central Africa</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 36[/DPWR] data-timeZoneId="36" data-gmtAdjustment="GMT+02:00" data-useDaylightTime="1" value="2">(GMT+02:00) Amman</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 37[/DPWR] data-timeZoneId="37" data-gmtAdjustment="GMT+02:00" data-useDaylightTime="1" value="2">(GMT+02:00) Athens, Bucharest, Istanbul</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 38[/DPWR] data-timeZoneId="38" data-gmtAdjustment="GMT+02:00" data-useDaylightTime="1" value="2">(GMT+02:00) Beirut</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 39[/DPWR] data-timeZoneId="39" data-gmtAdjustment="GMT+02:00" data-useDaylightTime="1" value="2">(GMT+02:00) Cairo</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 40[/DPWR] data-timeZoneId="40" data-gmtAdjustment="GMT+02:00" data-useDaylightTime="0" value="2">(GMT+02:00) Harare, Pretoria</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 41[/DPWR] data-timeZoneId="41" data-gmtAdjustment="GMT+02:00" data-useDaylightTime="1" value="2">(GMT+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 42[/DPWR] data-timeZoneId="42" data-gmtAdjustment="GMT+02:00" data-useDaylightTime="1" value="2">(GMT+02:00) Jerusalem</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 43[/DPWR] data-timeZoneId="43" data-gmtAdjustment="GMT+02:00" data-useDaylightTime="1" value="2">(GMT+02:00) Minsk</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 44[/DPWR] data-timeZoneId="44" data-gmtAdjustment="GMT+02:00" data-useDaylightTime="1" value="2">(GMT+02:00) Windhoek</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 45[/DPWR] data-timeZoneId="45" data-gmtAdjustment="GMT+03:00" data-useDaylightTime="0" value="3">(GMT+03:00) Kuwait, Riyadh, Baghdad</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 46[/DPWR] data-timeZoneId="46" data-gmtAdjustment="GMT+03:00" data-useDaylightTime="1" value="3">(GMT+03:00) Moscow, St. Petersburg, Volgograd</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 47[/DPWR] data-timeZoneId="47" data-gmtAdjustment="GMT+03:00" data-useDaylightTime="0" value="3">(GMT+03:00) Nairobi</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 48[/DPWR] data-timeZoneId="48" data-gmtAdjustment="GMT+03:00" data-useDaylightTime="0" value="3">(GMT+03:00) Tbilisi</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 49[/DPWR] data-timeZoneId="49" data-gmtAdjustment="GMT+03:30" data-useDaylightTime="1" value="3.5">(GMT+03:30) Tehran</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 50[/DPWR] data-timeZoneId="50" data-gmtAdjustment="GMT+04:00" data-useDaylightTime="0" value="4">(GMT+04:00) Abu Dhabi, Muscat</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 51[/DPWR] data-timeZoneId="51" data-gmtAdjustment="GMT+04:00" data-useDaylightTime="1" value="4">(GMT+04:00) Baku</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 52[/DPWR] data-timeZoneId="52" data-gmtAdjustment="GMT+04:00" data-useDaylightTime="1" value="4">(GMT+04:00) Yerevan</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 53[/DPWR] data-timeZoneId="53" data-gmtAdjustment="GMT+04:30" data-useDaylightTime="0" value="4.5">(GMT+04:30) Kabul</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 54[/DPWR] data-timeZoneId="54" data-gmtAdjustment="GMT+05:00" data-useDaylightTime="1" value="5">(GMT+05:00) Yekaterinburg</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 55[/DPWR] data-timeZoneId="55" data-gmtAdjustment="GMT+05:00" data-useDaylightTime="0" value="5">(GMT+05:00) Islamabad, Karachi, Tashkent</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 56[/DPWR] data-timeZoneId="56" data-gmtAdjustment="GMT+05:30" data-useDaylightTime="0" value="5.5">(GMT+05:30) Sri Jayawardenapura</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 57[/DPWR] data-timeZoneId="57" data-gmtAdjustment="GMT+05:30" data-useDaylightTime="0" value="5.5">(GMT+05:30) Chennai, Kolkata, Mumbai, New Delhi</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 58[/DPWR] data-timeZoneId="58" data-gmtAdjustment="GMT+05:45" data-useDaylightTime="0" value="5.75">(GMT+05:45) Kathmandu</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 59[/DPWR] data-timeZoneId="59" data-gmtAdjustment="GMT+06:00" data-useDaylightTime="1" value="6">(GMT+06:00) Almaty, Novosibirsk</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 60[/DPWR] data-timeZoneId="60" data-gmtAdjustment="GMT+06:00" data-useDaylightTime="0" value="6">(GMT+06:00) Astana, Dhaka</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 61[/DPWR] data-timeZoneId="61" data-gmtAdjustment="GMT+06:30" data-useDaylightTime="0" value="6.5">(GMT+06:30) Yangon (Rangoon)</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 62[/DPWR] data-timeZoneId="62" data-gmtAdjustment="GMT+07:00" data-useDaylightTime="0" value="7">(GMT+07:00) Bangkok, Hanoi, Jakarta</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 63[/DPWR] data-timeZoneId="63" data-gmtAdjustment="GMT+07:00" data-useDaylightTime="1" value="7">(GMT+07:00) Krasnoyarsk</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 64[/DPWR] data-timeZoneId="64" data-gmtAdjustment="GMT+08:00" data-useDaylightTime="0" value="8">(GMT+08:00) Beijing, Chongqing, Hong Kong, Urumqi</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 65[/DPWR] data-timeZoneId="65" data-gmtAdjustment="GMT+08:00" data-useDaylightTime="0" value="8">(GMT+08:00) Kuala Lumpur, Singapore</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 66[/DPWR] data-timeZoneId="66" data-gmtAdjustment="GMT+08:00" data-useDaylightTime="0" value="8">(GMT+08:00) Irkutsk, Ulaan Bataar</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 67[/DPWR] data-timeZoneId="67" data-gmtAdjustment="GMT+08:00" data-useDaylightTime="0" value="8">(GMT+08:00) Perth</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 68[/DPWR] data-timeZoneId="68" data-gmtAdjustment="GMT+08:00" data-useDaylightTime="0" value="8">(GMT+08:00) Taipei</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 69[/DPWR] data-timeZoneId="69" data-gmtAdjustment="GMT+09:00" data-useDaylightTime="0" value="9">(GMT+09:00) Osaka, Sapporo, Tokyo</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 70[/DPWR] data-timeZoneId="70" data-gmtAdjustment="GMT+09:00" data-useDaylightTime="0" value="9">(GMT+09:00) Seoul</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 71[/DPWR] data-timeZoneId="71" data-gmtAdjustment="GMT+09:00" data-useDaylightTime="1" value="9">(GMT+09:00) Yakutsk</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 72[/DPWR] data-timeZoneId="72" data-gmtAdjustment="GMT+09:30" data-useDaylightTime="0" value="9.5">(GMT+09:30) Adelaide</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 73[/DPWR] data-timeZoneId="73" data-gmtAdjustment="GMT+09:30" data-useDaylightTime="0" value="9.5">(GMT+09:30) Darwin</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 74[/DPWR] data-timeZoneId="74" data-gmtAdjustment="GMT+10:00" data-useDaylightTime="0" value="10">(GMT+10:00) Brisbane</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 75[/DPWR] data-timeZoneId="75" data-gmtAdjustment="GMT+10:00" data-useDaylightTime="1" value="10">(GMT+10:00) Canberra, Melbourne, Sydney</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 76[/DPWR] data-timeZoneId="76" data-gmtAdjustment="GMT+10:00" data-useDaylightTime="1" value="10">(GMT+10:00) Hobart</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 77[/DPWR] data-timeZoneId="77" data-gmtAdjustment="GMT+10:00" data-useDaylightTime="0" value="10">(GMT+10:00) Guam, Port Moresby</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 78[/DPWR] data-timeZoneId="78" data-gmtAdjustment="GMT+10:00" data-useDaylightTime="1" value="10">(GMT+10:00) Vladivostok</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 79[/DPWR] data-timeZoneId="79" data-gmtAdjustment="GMT+11:00" data-useDaylightTime="1" value="11">(GMT+11:00) Magadan, Solomon Is., New Caledonia</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 80[/DPWR] data-timeZoneId="80" data-gmtAdjustment="GMT+12:00" data-useDaylightTime="1" value="12">(GMT+12:00) Auckland, Wellington</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 81[/DPWR] data-timeZoneId="81" data-gmtAdjustment="GMT+12:00" data-useDaylightTime="0" value="12">(GMT+12:00) Fiji, Kamchatka, Marshall Is.</option>
                        <option [DPWR]VAR:"selected" if $http->{PARAMS}->{TIME_NTP_TIMEZONE_ID} == 82[/DPWR] data-timeZoneId="82" data-gmtAdjustment="GMT+13:00" data-useDaylightTime="0" value="13">(GMT+13:00) Nuku'alofa</option>
                      </select>
                    </div>
                  </div>
                  <div class="form-group">
                    <label for="cemail" class="col-lg-2 control-label">NTP Server Host/IP</label>
                    <div class="col-lg-4">
                      <!--data-inputmask="'alias': 'ip'"-->
                      <input class="form-control " 
                             id="id_ifNtpServerIP" name="NTP_SERVER_IP"
                             placeholder=" " value="[DPWR]VAR:$http->{PARAMS}->{TIME_NTP_SERVER_IP}[/DPWR]"/>
                    </div>
                  </div>
                  <div class="row">
                    <div class="col-lg-8">
                      <div class="col-lg-3">
                        <button type="submit" class="btn btn-info" value="SAVE"   id="id_ifChangeTime_SAVE">Save</button>
                        <button type="submit" class="btn btn-red"  value="CANCEL" id="id_ifChangeTime_CANCEL">Cancel</button>
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
