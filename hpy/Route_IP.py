import socket
import threading

routers = []
lock = threading.Lock()

def search_routers():
    routers = []
    local_ips = socket.gethostbyname_ex(socket.gethostname())[2]  # get local IP
    all_threads = []
    for ip in local_ips:
        for i in range(1, 255):
            array = ip.split('.')
            array[3] = str(i)
            new_ip = '.'.join(array)
            t = threading.Thread(target=check_ip, args=(new_ip,))
            t.start()
            all_threads.append(t)
    for t in all_threads:
        t.join()


def check_ip(new_ip):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(1)
    result = s.connect_ex((new_ip, 80))
    s.close()
    if result == 0:
        lock.acquire()
        print new_ip.ljust(15), ' port 80 is open'
        routers.append((new_ip, 80))
        lock.release()


print 'Searching for routers, please wait...'
search_routers()