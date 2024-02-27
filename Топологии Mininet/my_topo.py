from mininet.topo import Topo
from mininet.net import Mininet
from mininet.cli import CLI
from mininet.link import TCLink

class CustomTopology(Topo):
    def build(self):
        #Входной узел
        left_switch = self.addSwitch('s1')
        #Выходной узел
        right_switch = self.addSwitch('s2')

        self.addLink(left_switch, right_switch)

        
        for i in range(1, 11):
            host = self.addHost(f'h{i}')
            self.addLink(host, left_switch)
            self.addLink(host, right_switch)

if __name__ == '__main__':
    topo = CustomTopology()
    net = Mininet(topo=topo, link=TCLink)
    
    net.start()
    CLI(net)
    net.stop()