#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@time   :2018/1/20
@remark : bt1024爬一下
"""

import re
import urllib.request
import http.cookiejar
import requests
import threading

# 找出当前页中所有的子url并调用函数进行图片下载
def xp_craw_photo_requests(url, page):
    for i in range(1,page + 1):
        mainurl = url + str(i)
        r = requests.get(mainurl)
        r.encoding='utf-8'
        html_str = r.text
        # print(html_str)
        pattern_plist = '<tr align="center" class="tr3 t_one">.+? target="_blank">'
        # 加入re.S 否则无匹配结果
        result_plist = re.compile(pattern_plist,re.S).findall(html_str)
        # print(result_plist)
        href_str = 'href=\"(.+?)\"'
        href_result = re.compile(href_str).findall("".join(result_plist))
        html_str = "html"
        for href_url in href_result:
            if href_url.find(html_str) >= 0 :
                sub_url = "http://w3.afulyu.info/pw/" + href_url
                # print(sub_url)   
                xp_sub_downpic(sub_url)

# 过滤下载    
def xp_sub_downpic(url):
    r = requests.get(url)
    r.encoding = 'utf-8'
    html_str = r.text
    # print(r.text)
    pattern1 = '<div class="tpc_content" id="read_tpc">.+?</div>'
    result1 = re.compile(pattern1,re.S).findall(html_str)[0]
    # print(result1)
    pattern_dorcel = "Marc Dorcel"
    if re.compile(pattern_dorcel).findall(result1):
        pattern_pic = 'a href=\"(.+?)\".+?target="_blank"'
        result_picurl = re.compile(pattern_pic).findall(result1) 
        if len(result_picurl) >=2:
            result_picurl.pop(0)
        print(result_picurl)  
        # for downpicurl in result_picurl:
        #     pic_pattern = '\/([0-9a-zA-Z]+.html)'
        #     try:
        #         picname = "d://" + re.compile(pic_pattern).findall(downpicurl)[0]
        #         with open(picname,'wb') as f:
        #             f.write(requests.get(downpicurl).content)
        #             f.close()  
        #     except Exception as e:
        #         print(str(e))
        #         continue    

threads = []
t1 = threading.Thread(target=xp_craw_photo_requests,args=("http://w3.afulyu.info/pw/thread.php?fid=7&page=",30))
threads.append(t1)

if __name__ == '__main__':
    for t in threads:
        t.setDaemon(True)
        t.start()
    t.join()

    print("Torrent Download is Finished!!!")