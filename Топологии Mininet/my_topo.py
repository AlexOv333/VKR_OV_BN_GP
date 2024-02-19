from mininet.net import Mininet
from mininet.node import CPULimitedHost, RemoteController
from mininet.topo import Topo
from mininet.link import TCLink

class MyTopology(Topo):
    def build(self):
        h1 = self.addHost('h1')
        h2 = self.addHost('h2')

        b1 = self.addSwitch('b1')
        b2 = self.addSwitch('b2')

        self.addLink(h1, b1)
        self.addLink(h2, b2)

        for i in range(1, 11):
            s = self.addSwitch('s%d' % i)
            self.addLink(b1, s)
            self.addLink(b2, s)
            

topo = MyTopology()

net = Mininet(topo=topo, host=CPULimitedHost, link=TCLink, controller=RemoteController, autoSetMacs=True)
controller = net.addController('c0', controller=RemoteController, ip='127.0.0.1', port=6653)

net.start()
net.pingAll()
net.interact()