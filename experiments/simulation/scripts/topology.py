#!/usr/bin/env python

'This scripts configures and launches the Mininet Wi-Fi topology'

import sys, random, time, ipaddress, SimpleHTTPServer

from mininet.node import Controller, OVSKernelSwitch, IVSSwitch, UserSwitch
from mininet.log import setLogLevel, info
from mininet.link import Link, TCLink

from mn_wifi.net import Mininet_wifi
from mn_wifi.cli import CLI

dashc    = '/home/magnuskl/dashc/dashc.exe'
manifest = '/livestream/out.mpd'
logs     = '/tmp/'


def topology(args):
    net = Mininet_wifi(
        controller=Controller,
        link=TCLink,
        switch=OVSKernelSwitch)
    stations = []
    batch_n = 3
    batch_size = 10
    pause = 300.0 # 5 minutes

    info('*** Creating nodes\n')
    ip_network = ipaddress.ip_network(u'10.0.0.0/8')
    hosts = ip_network.hosts()
    ap1 = net.addAccessPoint(
        'ap1',
        ssid='ap1',
        mode='n',
        channel='1',
        failMode='standalone',
        position='0.0, 0.0, 0.0')
    srv1 = net.addHost('srv1', ip=str(next(hosts)))
    
    for i in range(1, batch_n * batch_size + 1):
        x, y, z = random.uniform(-20.0, 20.0), random.uniform(-20.0, 20.0), 0.0
        station = net.addStation(
            'sta' + str(i),
            ip=str(next(hosts)),
            position=str(x) + ', ' + str(y) + ', ' + str(z))
        stations.append(station)
    
    info('*** Configuring propagation model\n')
    net.setPropagationModel(model='logDistance', exp=4.5)

    info('*** Configuring Wi-Fi nodes\n')
    net.configureWifiNodes()

    info('*** Creating links\n')
    net.addLink(ap1, srv1)
    
    info('*** Plotting graph\n')
    net.plotGraph(min_x=-100, max_x=100, min_y=-100, max_y=100)

    info('*** Starting network\n')
    net.build()
    ap1.start([])

    info('*** Starting web server\n')
    srv1.cmd('/usr/local/nginx/sbin/nginx')
    time.sleep(5.0)

    info('*** Starting dashc on all stations\n')
    with open('/tmp/dashc/start.log', 'w') as out:
        out.write('Id,Time\n')
    with open('/tmp/dashc/finish.log', 'w') as out:
        out.write('Id,Time\n')

    for i in range(0, batch_n):
        for j in range(0, batch_size):
            idx = i * batch_size + j
            cmd = 'echo ' + str(idx + 1) + ',' + '$(date +%s%3N)' + ' >> ' + \
                  logs + 'start.log && ' + dashc + ' play http://' +         \
                  str(srv1.IP()) + manifest + ' > ' + logs + 'sta' +         \
                  str(idx + 1) + '.log && ' + 'echo ' + str(idx + 1) + ',' + \
                  '$(date +%s%3N)' + ' >> ' + logs + 'finish.log &'
            stations[idx].cmdPrint(cmd)
        time.sleep(pause) 

    info('*** Starting CLI\n')
    CLI(net)

    info('*** Stopping network\n')
    net.stop()


if __name__ == '__main__':
    setLogLevel('info')
    topology(sys.argv)
