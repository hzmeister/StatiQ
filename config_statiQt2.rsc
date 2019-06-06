:delay 10
/interface bridge
add name=bridge
:delay 5
/interface list
add name=WAN
add name=LAN
/ip pool
add name=lan-pool ranges=192.168.1.50-192.168.1.99
/ip dhcp-server
add address-pool=lan-pool disabled=no interface=bridge lease-time=1d name=\
    lan-dhcp
/queue tree
add max-limit=20M name=parent-download parent=global
add max-limit=1800k name=parent-upload parent=global
add name=heavy-download parent=parent-download
add name=lan-download parent=parent-download
add name=lan-upload parent=parent-upload
add name=heavy-upload parent=parent-upload
/queue type
add kind=pcq name=pcq-download pcq-classifier=dst-address,dst-port
add kind=pcq name=pcq-upload pcq-classifier=src-address,src-port
/queue tree
add name=ack-up packet-mark=ack-up-pk parent=parent-upload priority=1 queue=\
    pcq-upload-default
add name=lan-up packet-mark=lan-up-pk parent=lan-upload queue=\
    pcq-upload-default
add name=heavy-down packet-mark=heavy-down-pk parent=heavy-download queue=\
    pcq-download-default
add name=heavy-up packet-mark=heavy-up-pk parent=heavy-upload queue=\
    pcq-upload-default
add name=lan-down packet-mark=lan-down-pk parent=lan-download queue=\
    pcq-download-default
/interface bridge port
add bridge=bridge interface=ether2
add bridge=bridge interface=ether3
add bridge=bridge interface=ether4
add bridge=bridge interface=ether5
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add interface=bridge list=LAN
add interface=ether1 list=WAN
/ip address
add address=192.168.1.1/24 interface=bridge network=192.168.1.0
/ip cloud
set ddns-enabled=yes update-time=no
/ip dhcp-client
add dhcp-options=hostname,clientid disabled=no interface=ether1 use-peer-dns=\
    no use-peer-ntp=no
/ip dhcp-server network
add address=192.168.1.0/24 gateway=192.168.1.1
/ip dns
set allow-remote-requests=yes servers=185.228.169.10,185.228.168.10
/ip firewall filter
add action=accept chain=input comment="defconf: accept established,related" \
    connection-state=established,related
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=drop chain=input comment="defconf: drop all not coming from LAN" \
    in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" \
    ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" \
    ipsec-policy=out,ipsec
add action=accept chain=forward comment="defconf: accept established,related" \
    connection-state=established,related
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf:  drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN
/ip firewall mangle
add action=mark-packet chain=forward comment=ack-up new-packet-mark=ack-up-pk \
    out-interface-list=WAN packet-mark=no-mark packet-size=0-123 passthrough=\
    no protocol=tcp tcp-flags=ack
add action=mark-packet chain=forward comment=heavy-down connection-bytes=\
    5000000-0 connection-rate=500k-100M in-interface-list=WAN \
    new-packet-mark=heavy-down-pk packet-mark=no-mark passthrough=yes
add action=mark-packet chain=forward comment=lan-down in-interface-list=WAN \
    new-packet-mark=lan-down-pk packet-mark=no-mark passthrough=yes
add action=mark-packet chain=forward comment=heavy-up connection-bytes=\
    700000-0 connection-rate=300k-100M new-packet-mark=heavy-up-pk \
    out-interface-list=WAN packet-mark=no-mark passthrough=yes
add action=mark-packet chain=forward comment=lan-up new-packet-mark=lan-up-pk \
    out-interface-list=WAN packet-mark=no-mark passthrough=yes
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" \
    ipsec-policy=out,none out-interface-list=WAN
add action=redirect chain=dstnat comment=dns dst-port=53 in-interface=bridge \
    protocol=udp to-ports=53
add action=redirect chain=dstnat dst-port=53 in-interface=bridge protocol=tcp \
    to-ports=53
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/system clock
set time-zone-name=America/New_York
/system ntp client
set enabled=yes primary-ntp=216.239.35.0 secondary-ntp=216.239.35.4
/system script
add dont-require-permissions=no name=statiQ-script owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    for i from=99 to 50 do={ \r\
    \n /ip firewall mangle\r\
    \nadd action=mark-packet chain=forward dst-address=\"192.168.1.\$i/32\" ne\
    w-packet-mark=(\"heavy-down-192.168.1.\".(\$i)) packet-mark=heavy-down-pk \
    passthrough=no;\r\
    \n}\r\
    \n:for i from=99 to 50 do={ \r\
    \n /ip firewall mangle\r\
    \nadd action=mark-packet chain=forward dst-address=\"192.168.1.\$i/32\" ne\
    w-packet-mark=(\"lan-down-192.168.1.\".(\$i)) packet-mark=lan-down-pk pass\
    through=no;\r\
    \n}\r\
    \n:for i from=99 to 50 do={ \r\
    \n /ip firewall mangle\r\
    \nadd action=mark-packet chain=forward new-packet-mark=(\"heavy-up-192.168\
    .1.\".(\$i)) packet-mark=heavy-up-pk passthrough=no src-address=\"192.168.\
    1.\$i/32\";\r\
    \n}\r\
    \n:for i from=99 to 50 do={ \r\
    \n /ip firewall mangle\r\
    \nadd action=mark-packet chain=forward new-packet-mark=(\"lan-up-192.168.1\
    .\".(\$i)) packet-mark=lan-up-pk passthrough=no src-address=\"192.168.1.\$\
    i/32\";\r\
    \n}\r\
    \n:for i from=99 to 50 do={ \r\
    \n /queue tree\r\
    \nadd name=(\"heavy-down-192.168.1.\".(\$i)) packet-mark=(\"heavy-down-192\
    .168.1.\".(\$i)) parent=heavy-download queue=pcq-download;\r\
    \nadd name=(\"lan-down-192.168.1.\".(\$i)) packet-mark=(\"lan-down-192.168\
    .1.\".(\$i)) parent=lan-download priority=7 queue=pcq-download;\r\
    \nadd name=(\"heavy-up-192.168.1.\".(\$i)) packet-mark=(\"heavy-up-192.168\
    .1.\".(\$i)) parent=heavy-upload queue=pcq-upload;\r\
    \nadd name=(\"lan-up-192.168.1.\".(\$i)) packet-mark=(\"lan-up-192.168.1.\
    \".(\$i)) parent=lan-upload priority=7 queue=pcq-upload;\r\
    \n}"
/tool bandwidth-server
set enabled=no
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
