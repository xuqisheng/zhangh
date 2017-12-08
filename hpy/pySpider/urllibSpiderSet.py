#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@time   :2017/12/7
@remark : urllib编写的简单爬虫示例集合
"""

import re
import urllib.request


# 爬取京东图片
def jd_craw_photo(url, page):
    headers = ("User-Agent","Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 UBrowser/6.2.3831.407 Safari/537.36")
    opener = urllib.request.build_opener()
    opener.addheaders = [headers]
    html_str = str(opener.open(url).read())
    pattern_plist = '<div id="plist".+? <div class="page clearfix">'
    result_plist = re.compile(pattern_plist).findall(html_str)[0]
    pattern_jpg = '<img width="220" height="220" data-img="1" src="//(.+?\.jpg)"'
    imagelist = re.compile(pattern_jpg).findall(result_plist)
    x = 1
    for imageurl in imagelist:
        imagename = "d://myweb/"+str(page)+str(x)+".jpg"
        imageurl = "http://"+imageurl
        try:
            urllib.request.urlretrieve(imageurl,filename=imagename)
        except urllib.error.URLError as e:
            if hasattr(e,"code"):
                x += 1
            if hasattr(e,"reason"):
                x += 1
        x += 1

# 爬取CSDN的blog主页所有链接
def csdn_craw_link(url):
    headers = ("User-Agent","Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 UBrowser/6.2.3831.407 Safari/537.36")
    opener = urllib.request.build_opener()
    opener.addheaders = [headers]
    html_str = str(opener.open(url).read())
    pat = '(https?://[^/s";]+\.(\w|/)*)'
    link = re.compile(pat).findall(html_str)
    #去除重复元素
    link = list(set(link))
    return link

if __name__ == '__main__':
    # 京东
    # for i in range(1,10):
    #     url = "https://list.jd.com/list.html?cat=9987,653,655&page="+str(i)
    #     jd_craw_photo(url,i)

    # csdn
    for link in csdn_craw_link("http://www.sina.com.cn"):
        print(link[0])
