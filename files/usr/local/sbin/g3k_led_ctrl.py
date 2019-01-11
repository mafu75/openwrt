#!/usr/bin/env python
import time

LEDPATH="/sys/class/leds/"

class netdev_led_controller():
    def __init__(self, netdev, ledgiga, ledlink, ledact):
        self._netdev = netdev
        self._ledlink = LEDPATH + ledlink
        self._ledgiga = LEDPATH + ledgiga
        self._ledact = LEDPATH + ledact
        self._rx_old = 0
        self._tx_old = 0

        f = open(self._ledlink + "/trigger", "w")
        f.write("default-on")
	f.close()

        f = open(self._ledgiga + "/trigger", "w")
        f.write("default-on")
	f.close()

	time.sleep(0.2)

        self._flink = open(self._ledlink + "/brightness", "w")
        self._flink.write("0")

        self._fgiga = open(self._ledgiga + "/brightness", "w")
        self._fgiga.write("0")

        f = open(self._ledact + "/trigger", "w")
        f.write("oneshot")
        f.close()

        self._fact = open(self._ledact + "/shot", "w")
        self._fact.write("1")

        self.ifstate()

    def do_leds(self):
        spd, a = self.ifstate()
#        print("%s: %d %d" % (self._netdev, spd, a))

	# 1000: green
	# 100: green+red
	# 10: red
	# 0: off

        self._flink.seek(0)
        self._fgiga.seek(0)

        if spd == 1000:
            self._flink.write("1")
            self._fgiga.write("0")

        elif spd == 100:
            self._flink.write("1")
            self._fgiga.write("1")

        elif spd == 10:
            self._flink.write("0")
            self._fgiga.write("1")

        else:
            self._flink.write("0")
            self._fgiga.write("0")
            a = 0

        if a:
            self._fact.seek(0)
            self._fact.write("1")

    def ifstate(self):
        operstate = False
        speed = 0
        activity = False

        f = open("/sys/class/net/" + self._netdev + "/operstate", "r")
        s = f.read()
        f.close()

        if s.startswith("up"):
            operstate = True

        if operstate == True:
            f = open("/sys/class/net/" + self._netdev + "/speed", "r")
            s = f.read()
            f.close()
            speed = int(s)

        f = open("/sys/class/net/" + self._netdev + "/statistics/tx_bytes", "r")
        s = f.read()
        f.close()
        tx_bytes = int(s)

        f = open("/sys/class/net/" + self._netdev + "/statistics/rx_bytes", "r")
        s = f.read()
        f.close()
        rx_bytes = int(s)

        if (tx_bytes != self._tx_old) or (rx_bytes != self._rx_old):
            self._tx_old = tx_bytes
            self._rx_old = rx_bytes
            activity = True

        return (speed, activity)

eth0 = netdev_led_controller("eth0",
                             "g3000:red:led14",
                             "g3000:green:led15",
                             "g3000:blue:led16")

eth1 = netdev_led_controller("eth1",
                             "g3000:red:led17",
                             "g3000:green:led18",
                             "g3000:blue:led19")

while 1:
    eth0.do_leds()
    eth1.do_leds()
    time.sleep(0.25)
