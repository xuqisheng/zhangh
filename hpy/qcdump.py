#!/etc/bin/env python
# coding:utf-8

import os
from qcloud_cos import CosClient
from qcloud_cos import UploadFileRequest
from qcloud_cos import DelFileRequest
from qcloudcfg import *
'''
def dumpfiles(dirpwd,filenames):
    cos_client = CosClient(appid, secret_id, secret_key, region_info)
    cos_path = unicode('/' + filenames)
    local_path = unicode(dirpwd + '\\' + filenames)
    request = UploadFileRequest(bucket, cos_path, local_path)
    upload_file_ret = cos_client.upload_file(request)
    return upload_file_ret

if __name__ == '__main__':
    dumpfiles('D:\Python27\zhangh\hpy','Route_IP.py')
    print 'D:\Python27\zhangh\hpy\Route_IP.py'
'''

class Qcdump(object):
    def __init__(self,dumpfile):
        self._dumpfile   = dumpfile
        self._cos_client = CosClient(appid, secret_id, secret_key, region_info)

        # 取得文件的路径
        self._filepath = os.path.dirname(self._dumpfile)

        # 判断是否包含路径
        if self._filepath:
            self._filename = self._dumpfile[len(os.path.dirname(self._dumpfile)) + 1:]
        else:
            self._filename = self._dumpfile[len(os.path.dirname(self._dumpfile)):]
    # 上传文件
    def qc_upload_file(self):
        path_cos    = unicode('/' + self._filename)
        path_local  = unicode(self._dumpfile)
        request     = UploadFileRequest(bucket, path_cos,path_local)
        upload_file_ret = self._cos_client.upload_file(request)

        return repr(upload_file_ret)
    # 移动文件
    def qc_move_file(self):
        pass
    # 删除文件
    def qc_del_file(self):
        path_cos = unicode('/' + self._filename)
        request  = DelFileRequest(bucket,path_cos)
        del_ret  = self._cos_client.del_file(request)

        return repr(del_ret)
    # 创建目录
    def qc_create_folder(self):
        pass
    # list目录内容
    def qc_list_folder(self):
        pass
    # 删除目录
    def qc_del_folder(self):
        pass

if __name__ == '__main__':
    test = Qcdump('probeip')
    test.qc_del_file()