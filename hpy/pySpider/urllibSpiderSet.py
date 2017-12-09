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
import http.cookiejar


# 爬取京东图片
def jd_craw_photo(url, page):
    headers = {
        "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Encoding":"utf-8",
        "Accept-Language":"zh-CN,zh;q=0.8",
        "Connection":"keep-alive",
        "User-Agent":"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 UBrowser/6.2.3831.407 Safari/537.36"
        }
    # 设置 cookie
    cjar = http.cookiejar.CookieJar()
    # 通过代理方式
    proxy = urllib.request.ProxyHandler({'http':"120.26.14.14:3128"})
    opener = urllib.request.build_opener(proxy, urllib.request.HTTPHandler, urllib.request.HTTPCookieProcessor(cjar))  
    # opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cjar))
    headers_all = []
    # 通过for循环遍历字典，构造出指定格式的headers信息
    for key,value in headers.items():
        item = (key,value)
        headers_all.append(item)
    opener.addheaders = headers_all
    urllib.request.install_opener(opener)
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

# 爬取QSBK的笑话
def qsbk_craw_joke(url,i):
    headers = ("User-Agent","Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 UBrowser/6.2.3831.407 Safari/537.36")
    opener = urllib.request.build_opener()
    opener.addheaders = [headers]
    html_str = str(opener.open(url).read().decode('utf-8')) 
    contentpat = '<div class="content">(.*?)</div>'
    contentlist = re.compile(contentpat,re.S).findall(html_str)
    for content in contentlist:
        content=content.replace("\n","")
        print(content)   


if __name__ == '__main__':
    # 京东
    for i in range(1,5):
        url = "https://list.jd.com/list.html?cat=9987,653,655&page="+str(i)
        jd_craw_photo(url,i)

    # csdn
    # for link in csdn_craw_link("http://www.sina.com.cn"):
    #     print(link[0])

    # QSBK
    # for i in range(1,2):
    #     qsbk_craw_joke("https://www.qiushibaike.com/8hr/page/"+str(i),i)
