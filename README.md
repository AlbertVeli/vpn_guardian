Small shell script to restart openvpn if tunnel stops working. On my system the tunnel goes down a couple of times per week so this comes in handy.

The symptoms I have when the tunnel stops working is that I can't ping the outside world. So the scripts tries to ping out every minute and if it fails (four times) then it brings the tunnel down, tries to ping without tunnel, and when the ping goes through it brings the tunnel up again and goes back to the initial state.

This has only been tested on GNU/Linux, but should work with some minor modifications on other unix-like systems too.

**INSTALL**

Run make and sudo make install to copy daemonize and vpnguardian.sh to /usr/local/bin. Then put the following in a startup script:

    PREFIX=/usr/local/bin
    $PREFIX/daemonize $PREFIX/vpnguardian.sh

Look at the example startup script 03-vpnguardian.start.

If you need to modify paths or command to start/stop the VPN tunnel, look in vpnguardian.sh. Everything you might want to change is in there.

**LICENSE**

    ~~=) All Rights Reversed - No Rights Reserved (=~~

Sweetmorn, the 64th day of The Aftermath in the YOLD 3180

ILEV Trebla
