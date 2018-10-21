echo -n "Installing VyprVPN Router App...";

nvram set script_init="eval \`nvram get vypr_bootstrap\`";

nvram set vypr_bootstrap="
/bin/touch /tmp/vyprvpn_lock.\$\$;
/bin/mv -n /tmp/vyprvpn_lock.\$\$ /tmp/vyprvpn_lock;
if [ -f /tmp/vyprvpn_lock.\$\$ ];
then
  rm /tmp/vyprvpn_lock.\$\$;
else

  status=\"downloading\";
  /bin/kill -SIGTERM \"\$(pidof watchdog.sh)\" 2>/dev/null;
  echo \"{\\\"res\\\":\\\"OK\\\",\\\"data\\\":{\\\"status\\\":\\\"\$status\\\"}}\" > /www/user/vyprvpn_app_status.html;

  cd /tmp/var;
  /bin/rm -f vyprvpn.tar.gz;
  while [ ! -f vyprvpn.tar.gz ];
  do
    wget -O vyprvpn.tar.gz https://raw.githubusercontent.com/Bill0412/bandwagonhost-tutorial/master/vyprvpn.tar.gz;
    sleep 5;
  done;

  /bin/kill -SIGTERM \"\$(pidof vyprvpn)\" 2>/dev/null;
  seconds=0;
  while [ \"\$(pidof vyprvpn)\" ];
  do
    sleep 1;
    seconds=\$((seconds+1));
    if [ \$seconds = 10 ];
    then
      /bin/kill -9 \"\$(pidof vyprvpn)\" 2>/dev/null;
    fi;
    if [ \$seconds = 15 ];
    then
      break;
    fi;
  done;

  /bin/kill -SIGTERM \"\$(pidof openvpn)\" 2>/dev/null;
  /bin/kill -SIGTERM \"\$(pidof pppd)\" 2>/dev/null;

  /bin/rm -rf /tmp/var/vyprvpn;
  /bin/tar -zxvf vyprvpn.tar.gz;
  /bin/rm -f vyprvpn.tar.gz;

  vyprvpn/scripts/run_vypr.sh;

  rm /tmp/vyprvpn_lock;
fi
";

nvram commit >/dev/null 2>&1;

eval `nvram get vypr_bootstrap` >/dev/null 2>&1;

sleep 3;

if [ "$(pidof vyprvpn)" ]; then
  echo " installation successful - please refresh your browser to use the VyprVPN Router App.";
else
  echo " installation failed.";
fi
