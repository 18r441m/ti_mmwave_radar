import socket
import threading

class ADCInterface:
    def __init__(self, adc_ip, command_port, data_port, buffer_size=4096):
        self.adc_ip = adc_ip
        self.command_port = command_port
        self.data_port = data_port
        self.buffer_size = buffer_size
        self.running = False
        self.data_socket = None
        self.command_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    def send_command(self, command):
        print(f"Sending command: {command}")
        self.command_socket.sendto(command.encode(), (self.adc_ip, self.command_port))

    def start_adc(self):
        self.send_command("START")
        self.running = True
        self._start_data_reception()

    def stop_adc(self):
        self.send_command("STOP")
        self.running = False
        self._stop_data_reception()

    def _start_data_reception(self):
        self.data_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.data_socket.bind(("", self.data_port))
        self.data_thread = threading.Thread(target=self._receive_data)
        self.data_thread.start()

    def _stop_data_reception(self):
        if self.data_socket:
            self.data_socket.close()
        if self.data_thread.is_alive():
            self.data_thread.join()

    def _receive_data(self):
        try:
            while self.running:
                data, addr = self.data_socket.recvfrom(self.buffer_size)
                print(f"Received data packet of size {len(data)} bytes from {addr}")
        except OSError:
            print("Data reception stopped.")

    def close(self):
        self.stop_adc()
        self.command_socket.close()


if __name__ == "__main__":
    adc_ip = "192.168.33.30"
    command_port = 5000
    data_port = 4098

    adc = ADCInterface(adc_ip, command_port, data_port)

    adc.start_adc()

    try:
        import time
        time.sleep(10)
    except KeyboardInterrupt:
        pass

    adc.stop_adc()

    adc.close()
