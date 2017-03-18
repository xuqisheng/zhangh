#!/etc/bin/env python
# coding:utf-8
# 腾讯云 文件交互操作
# 设置用户属性, 包括appid, secret_id和secret_key
# 这些属性可以在cos控制台获取(https://console.qcloud.com/cos)
import qcloud_cos
appid = 1253472137                # 替换为用户的appid
secret_id = u'AKIDteFftzcTs8D8rNxnjT0NTQBj5EBy81FG'         # 替换为用户的secret_id
secret_key = u'Jk5HJ9nFXcUAduyqqgMqIZdUBfx3ygBT'         # 替换为用户的secret_key
region_info = "gz" #           # 替换为用户的region，目前可以为 sh/gz/tj，分别对应于上海，广州，天津园区
cos_client = qcloud_cos.CosClient(appid, secret_id, secret_key, region=region_info)

# 设置要操作的bucket
bucket = u'zhangh214'

############################################################################
# 文件操作                                                                 #
############################################################################
# 1. 上传文件(默认不覆盖)
#    将本地的py_demo.py上传到bucket的根分区下,并命名为py_demo.py
#    默认不覆盖, 如果cos上文件存在,则会返回错误
request = qcloud_cos.UploadFileRequest(bucket, u'/py_demo.py', u'py_demo2.py')
upload_file_ret = cos_client.upload_file(request)
print 'upload file ret:', repr(upload_file_ret)

# 2. 上传文件(覆盖文件)
#    将本地的py_demo2.py上传到bucket的根分区下,覆盖已上传的py_demo.py
request = qcloud_cos.UploadFileRequest(bucket, u'/py_demo.py', u'py_demo2.py')
request.set_insert_only(0)  # 设置允许覆盖
upload_file_ret = cos_client.upload_file(request)
print 'overwrite file ret:', repr(upload_file_ret)

# 3. 获取文件属性
request = qcloud_cos.StatFileRequest(bucket, u'/py_demo.py')
stat_file_ret = cos_client.stat_file(request)
print 'stat file ret:', repr(stat_file_ret)

# 4. 更新文件属性
request = qcloud_cos.UpdateFileRequest(bucket, u'/py_demo.py')

request.set_biz_attr(u'这是个demo文件')           # 设置文件biz_attr属性
request.set_authority(u'eWRPrivate')              # 设置文件的权限
request.set_cache_control(u'cache_xxx')           # 设置Cache-Control
request.set_content_type(u'application/text')     # 设置Content-Type
request.set_content_disposition(u'ccccxxx.txt')   # 设置Content-Disposition
request.set_content_language(u'english')          # 设置Content-Language
request.set_x_cos_meta(u'x-cos-meta-xxx', u'xxx') # 设置自定义的x-cos-meta-属性
request.set_x_cos_meta(u'x-cos-meta-yyy', u'yyy') # 设置自定义的x-cos-meta-属性

update_file_ret = cos_client.update_file(request)
print 'update file ret:', repr(update_file_ret)

# 5. 更新后再次获取文件属性
request = qcloud_cos.StatFileRequest(bucket, u'/py_demo.py')
stat_file_ret = cos_client.stat_file(request)
print 'stat file ret:', repr(stat_file_ret)

# 6. 移动文件, 将py_demo.py移动位sample_file_move.txt
request = qcloud_cos.MoveFileRequest(bucket, u'/py_demo.py', u'/sample_file_move.txt')
stat_file_ret = cos_client.move_file(request)
print 'move file ret:', repr(stat_file_ret)

# 7. 删除文件
request = qcloud_cos.DelFileRequest(bucket, u'/py_demo.py')
del_ret = cos_client.del_file(request)
print 'del file ret:', repr(del_ret)

############################################################################
# 目录操作                                                                 #
############################################################################
# 1. 生成目录, 目录名为sample_folder
request = qcloud_cos.CreateFolderRequest(bucket, u'/Python/')
create_folder_ret = cos_client.create_folder(request)
print 'create folder ret:', create_folder_ret

# 2. 更新目录的biz_attr属性
request = qcloud_cos.UpdateFolderRequest(bucket, u'/Python/', u'这是一个测试目录')
update_folder_ret = cos_client.update_folder(request)
print 'update folder ret:', repr(update_folder_ret)

# 3. 获取目录属性
request = qcloud_cos.StatFolderRequest(bucket, u'/sample_folder/')
stat_folder_ret = cos_client.stat_folder(request)
print 'stat folder ret:', repr(stat_folder_ret)

# 4. list目录, 获取目录下的成员
request = qcloud_cos.ListFolderRequest(bucket, u'/sample_folder/')
list_folder_ret = cos_client.list_folder(request)
print 'list folder ret:', repr(list_folder_ret)

# 5. 删除目录
request = qcloud_cos.DelFolderRequest(bucket, u'/sample_folder/')
delete_folder_ret = cos_client.del_folder(request)
print 'delete folder ret:', repr(delete_folder_ret)