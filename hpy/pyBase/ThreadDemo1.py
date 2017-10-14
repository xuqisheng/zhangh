# coding=utf8
import paramiko, datetime, os, threading

runing = True


class run_cmd(threading.Thread):
    def __init__(self, hostname=None, password=None, username=None, port=None, echo_cmd=None):
        threading.Thread.__init__(self)
        self.hostname = hostname
        self.password = password
        self.username = username
        self.port = port
        self.echo_cmd = echo_cmd
        self.thread_stop = False

    def run(self):
        paramiko.util.log_to_file('paramiko.log')
        s = paramiko.SSHClient()
        s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        s.connect(hostname=self.hostname, username=self.username, password=self.password)
        stdin, stdout, stderr = s.exec_command(self.echo_cmd)
        print(stdout.read())
        s.close()

    def stop(self):
        self.thread_stop = True


class upload_thread(threading.Thread):
    def __init__(self, hostname=None, password=None, username=None, port=None, local_dir=None, remote_dir=None):
        threading.Thread.__init__(self)
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
        self.local_dir = local_dir
        self.remote_dir = remote_dir
        self.thread_stop = False

    def run(self):
        try:
            t = paramiko.Transport((self.hostname, self.port))
            t.connect(username=self.username, password=self.password)
            sftp = paramiko.SFTPClient.from_transport(t)
            print('upload file start %s ' % datetime.datetime.now())
            for root, dirs, files in os.walk(self.local_dir):
                for filespath in files:
                    local_file = os.path.join(root, filespath)
                    a = local_file.replace(self.local_dir, remote_dir)
                    remote_file = os.path.join(self.remote_dir, a)
                    try:
                        sftp.put(local_file, remote_file)
                    except Exception, e:
                        sftp.mkdir(os.path.split(remote_file)[0])
                        sftp.put(local_file, remote_file)
                    print("upload %s to remote %s" % (local_file, remote_file))
                for name in dirs:
                    local_path = os.path.join(root, name)
                    a = local_path.replace(self.local_dir, remote_dir)
                    remote_path = os.path.join(self.remote_dir, a)
            try:
                sftp.mkdir(remote_path)
                print("mkdir path %s" % remote_path)
            except Exception, e:
                print(e)
            print('upload file success %s ' % datetime.datetime.now())
            t.close()

        except Exception, e:
            print(e)

def stop(self):
    self.thread_stop = True


class get_thread(threading.Thread):
    def __init__(self, hostname=None, password=None, username=None, port=None, local_dir=None, remote_dir=None):
        threading.Thread.__init__(self)
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
        self.local_dir = local_dir
        self.remote_dir = remote_dir
        self.thread_stop = False

    def run(self):
        try:
            t = paramiko.Transport((self.hostname, self.port))
            t.connect(username=self.username, password=self.password)
            sftp = paramiko.SFTPClient.from_transport(t)
            print('get file start %s ' % datetime.datetime.now())
            for root, dirs, files in os.walk(self.remote_dir):
                for name in dirs:
                    remote_path = os.path.join(root, name)
                    a = remote_path.replace(self.remote_dir, local_dir)
                    local_path = os.path.join(self.local_dir, a)
                    try:
                        sftp.mkdir(local_path)
                        print("mkdir path %s" % local_path)
                    except Exception, e:
                        print(e)
                for filespath in files:
                    remote_file = os.path.join(root, filespath)
                    a = remote_file.replace(self.remote_dir, self.local_dir)
                    local_file = os.path.join(self.local_dir, a)
                    try:
                        sftp.get(remote_file, local_file)
                    except Exception, e:
                        sftp.mkdir(os.path.split(local_file)[0])
                        sftp.get(remote_file, local_file)
                    print("get %s to remote %s" % (remote_file, local_file))
            print('get file success %s ' % datetime.datetime.now())
            t.close()
        except Exception, e:
            print (e)

    def stop(self):
        self.thread_stop = True


while runing:
    print("1 执行cmd命令")
    print("2 上传文件")
    print("3 下载文件")
    print("* quit")
    ten = int(input('Enter a number:'))
    if type(ten) is not int:
        break
    else:
        if ten == 1:
            while runing:
                print("1 手动输入命令")
                print("*(任意输入) 返回上级目录")
                cmd_number = int(input('Enter a number(命令):'))
                if cmd_number == 1:
                    username = 'root'
                    password = 'redhat'
                    port = 22
                    echo_cmd = input('Enter echo cmd:')
                    ip = input('enter hostname:')
                    host = ip.split(' ')
                    for hostname in host:
                        cmd_thread = run_cmd(hostname, password, username, port, echo_cmd)
                        print(hostname)
                        cmd_thread.start()
                        cmd_thread.stop()
                        if (cmd_thread.isAlive()):
                            cmd_thread.join()
                else:
                    break
        elif ten == 2:
            while runing:
                print("1 上传文件")
                print("*(任意输入) 返回上级目录")
                file_put = int(input('Enter a number(上传文件):'))
                if file_put == 1:
                    local_dir = input('enter 源路径 :')
                    remote_dir = input('enter 目录路径:')
                    host = []
                    ip = input('enter hostname:')
                    host = ip.split(' ')
                    username = 'root'
                    password = 'redhat'
                    port = 22
                    for hostname in host:
                        print(hostname)
            uploadthread = upload_thread(hostname, password, username, port, local_dir, remote_dir)
            uploadthread.start()
            uploadthread.stop()

            if (uploadthread.isAlive()):
                uploadthread.join()

            else:
                break
        elif ten == 3:
            while runing:
                print("1 下载文件")
                print("*(任意输入) 返回上级目录")
                file_get = int(input('Enter a number(下载文件):'))
                if file_get == 1:
                    username = 'root'
                    password = 'redhat'
                    port = 22
                    remote_dir = input('enter 服务器的路径 :')
                    local_dir = input('enter 本地的路径:')
                    hostname = input('enter请输入其中一台服务器地址即可:')
                    getthread = get_thread(hostname, password, username, port, local_dir, remote_dir)
                    getthread.start()
                    getthread.stop()
                    if (getthread.isAlive()):
                        getthread.join()
                else:
                    break
        else:
            break