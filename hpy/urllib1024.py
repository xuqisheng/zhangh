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

# 使用requests库对图片的下载
def xp_craw_photo_requests(url, page):
    r = requests.get(url)
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
            xp_sub_downpic(sub_url,page)
    
def xp_sub_downpic(url,page):
    r = requests.get(url)
    r.encoding = 'utf-8'
    html_str = r.text
    # print(r.text)
    pattern1 = '<div class="tpc_content" id="read_tpc">.+?</div>'
    result1 = re.compile(pattern1,re.S).findall(html_str)[0]
    # print(result1)
    pattern_pic = 'img src=\"(.+?)\"'
    result_picurl = re.compile(pattern_pic).findall(result1)
    # print(result_picurl)
    x = 1
    for downpicurl in result_picurl:
        pic_pattern = '\/([0-9]+.jpg)'
        picname = "d://PicDown/" + re.compile(pic_pattern).findall(downpicurl)[0]
        # print(picname)
        with open(picname,'wb') as f:
            f.write(requests.get(downpicurl).content)
            f.close()
        x += 1      

if __name__ == '__main__':
    # xp1024
    for i in range(1,2):
        # url = "http://w3.afulyu.info/pw/thread.php?fid=16&page="+str(i)
        xp_craw_photo_requests(url,i)
    # xp_sub_downpic("http://w3.afulyu.info/pw/htm_data/16/1801/974234.html",1)

