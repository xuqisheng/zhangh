#!/etc/bin/env python
# coding:utf-8

'''
操作腾讯云存储
'''

import os
import threading, configparser
'''
from qcloud_cos import CosClient
from qcloud_cos import UploadFileRequest
from qcloud_cos import DelFileRequest
from qcloud_cos import CreateFolderRequest
from qcloud_cos import DelFolderRequest
from qcloud_cos import ListFolderRequest


class Qcdump(object):
    def __init__(self,dumpfile):
        self._dumpfile   = dumpfile

        # 获取config配置文件基本信息
        config = configparser.ConfigParser()
        config.read('pycfg/qcloudcfg.ini')
        appid = config.get('qcloud', 'appid')
        secret_id = config.get('qcloud', 'secret_id')
        secret_key = config.get('qcloud', 'secret_key')
        region_info = config.get('qcloud', 'region_info')
        bucket = config.get('qcloud', 'bucket')

        self._cos_client = CosClient(appid, secret_id, secret_key, region_info)

        # 判断是否为文件
        if os.path.isfile(self._dumpfile):
            # 获取文件大小
            self._file_size = os.path.getsize(self._dumpfile)
            fileSize = round(os.path.getsize('E:\Software\Git_2.12_64.exe') / (1024 * 1024.00), 2)
            # 取得文件的路径
            self._filepath = os.path.dirname(self._dumpfile)
            # 判断是否包含路径
            if self._filepath:
                self._filename = self._dumpfile[len(os.path.dirname(self._dumpfile)) + 1:]
            else:
                self._filename = self._dumpfile[len(os.path.dirname(self._dumpfile)):]
        else:
            self._filename = self._dumpfile


    # 定义上传进度条
    def processBar(self,file_size,file_speed):
        pass


    def threadUpload(self):
        pass

    # 定义返回值信息
    def message_ret(self,cos_code,cos_message,cos_action):
        if cos_code == 0:
            print 'Congratulation,' + cos_action + ' Successful operation'
        elif cos_code == -1:
            print 'The input parameter errors, such as the input of the local file path does not exist'
        elif cos_code == -2:
            print 'Network error,such as 404'
        elif cos_code == -3:
            print 'Connection cos when an exception occurs, such as connection timeout'
        elif cos_code == -71:
            print 'Operating frequency too fast, trigger a cosine attack'
        else:
            print cos_message

    # 上传文件
    def qc_upload_file(self):
        path_cos    = unicode('/' + self._filename)
        path_local  = unicode(self._dumpfile)
        request     = UploadFileRequest(bucket, path_cos,path_local)
        upload_ret  = self._cos_client.upload_file(request)

        self.message_ret(upload_ret['code'],upload_ret['message'],'upload_file')

    # 移动文件
    def qc_move_file(self):
        pass
    # 删除文件
    def qc_del_file(self):
        path_cos = unicode('/' + self._filename)
        request  = DelFileRequest(bucket,path_cos)
        del_ret  = self._cos_client.del_file(request)

        self.message_ret(del_ret['code'],del_ret['message'],'del_file')

    # 创建目录
    def qc_create_folder(self):
        path_cos = unicode('/' + self._filename + '/')
        request = CreateFolderRequest(bucket, path_cos)
        create_folder_ret = self._cos_client.create_folder(request)

        self.message_ret(create_folder_ret['code'],create_folder_ret['message'],'create_folder')

    # list目录内容
    def qc_list_folder(self):
        path_cos = unicode('/' + self._filename + '/')
        request = ListFolderRequest(bucket, path_cos)
        list_folder_ret = self._cos_client.list_folder(request)

        for f in list_folder_ret['data']['infos']:
            print u'文件：','<-->',f['name'],u'  大小：','<-->',f['filesize'],'Bit'

        self.message_ret(list_folder_ret['code'],list_folder_ret['message'],'list_folder')

    # 删除目录
    def qc_del_folder(self):
        path_cos = unicode('/' + self._filename + '/')
        request = DelFolderRequest(bucket, path_cos)
        delete_folder_ret = self._cos_client.del_folder(request)

        self.message_ret(delete_folder_ret['code'],delete_folder_ret['message'],'delete_folder')

if __name__ == '__main__':
    test = Qcdump('E:\\bandicam2017.avi')
    # test.qc_upload_file()
    # test.qc_del_file()
    # test.qc_create_folder()
    # test.qc_del_folder()
    # test.qc_list_folder()

'''