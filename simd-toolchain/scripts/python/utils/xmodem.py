import os, sys
import serial
import time

class XModemError(Exception):
    def __init__(self, msg):
        self.desc = msg
    def __str__(self):
        return str(self.desc)

class XModem(object):
    X_ACK = 0x06
    X_NAK = 0x15
    X_SOH = 0x01
    X_EOT = 0x04
    X_SUB = 0x1A
    def __init__(self, port, baudrate, timeout=1):
        self.port = serial.Serial(port=port, baudrate=baudrate, timeout=timeout)
        self.timelimit = timeout*5

    def send_data(self, data):
        '''Send a bytearray data via serial port'''
        chunks = [data[i:i+128] for i in range(0, len(data), 128)]
        packet_num = 1
        packets = []
        for ch in chunks:
            packet = bytearray(3)
            packet[0] = XModem.X_SOH
            packet[1] = packet_num
            packet[2] = 255 - packet_num
            packet += ch
            if len(ch) < 128: packet += '\x1A'*(128 - len(ch))
            chsum = sum(packet[3:]) & 0xFF
            packet.append(chsum)
            packet_num = (packet_num + 1) & 0xFF
            packets.append(packet)
        # Start actual transfer
        if self.port.closed: self.port.open()
        start = time.time()
        while True:
            c = bytearray(self.port.read(1))
            if c and c[0] == XModem.X_NAK: break
            end = time.time()
            if (end - start) > self.timelimit:
                raise XModemError('Send timeout (%.2fs).'%self.timelimit)
        self.port.flushInput()
        for p in packets:
            start = time.time()
            while True:
                self.port.write(p)
                c = bytearray(self.port.read(1))
                if c and c[0] == XModem.X_ACK: break
                time.sleep(0.05)
                end = time.time()
                if (end - start) > self.timelimit:
                    raise XModemError('Send timeout (%.2fs).'%self.timelimit)
        while True:
            self.port.write('\x04')
            c = bytearray(self.port.read(1))
            if c and c[0] == XModem.X_ACK: break
            time.sleep(0.05)

    def receive_data(self):
        '''Receive a bytearray data via serial port'''
        if self.port.closed: self.port.open()
        self.port.write('\x15')
        time.sleep(0.05)
        start = time.time()
        while True:
            c = bytearray(self.port.read(1))
            if c and c[0] == XModem.X_SOH: break
            end = time.time()
            if (end - start) > self.timelimit:
                raise XModemError('Receive timeout (%.2fs).'%self.timelimit)
        pnum = 1
        rcv_data = bytearray()
        while not c or c[0] != XModem.X_EOT:
            if c and c[0] == XModem.X_SOH:
                rd = bytearray(self.port.read(131))
                if not rd or len(rd) < 131:
                    self.port.write('\x15')
                    self.port.flushInput()
                    continue
                p, np = rd[0], rd[1]
                if p != pnum or np != (255-pnum):
                    self.port.write('\x15')
                    self.port.flushInput()
                    continue
                packet = rd[2:-1]
                if (sum(packet) & 0xFF) != rd[-1]:
                    self.port.write('\x15')
                    self.port.flushInput()
                    continue
                self.port.write('\x06') # ACK
                pnum += 1
                rcv_data += packet
            # if c and c[0] == X_SOH:
            c = bytearray(self.port.read(1))
        # while not c or c[0] != XModem.X_EOT:
        self.port.write('\x06') # ACK
        return rcv_data.rstrip('\x1A')
