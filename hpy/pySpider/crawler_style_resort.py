#!/usr/bin/python
# -*- coding: utf8 -*
"""
抓取style.com图片, 使用到 urllib logging json BeautifulSoup ThreadPool 模块
"""
__author__ = 'fangs'

import urllib2
import urllib
import logging
import os
import time
import socket
import traceback
import sys

from bs4 import BeautifulSoup

from threadpool import ThreadPool


reload(sys)
sys.setdefaultencoding('gbk')

TIME_OUT_SECONDS = 20

# LOCAL_DIR = "C:/style.com/F2014RTW/"
# MAIN_URL = "http://www.style.com/fashionshows/collections/F2014RTW/"

# LOCAL_DIR = "C:/style.com/spring-2015-ready-to-wear/"
# MAIN_URL = "http://www.style.com/fashion-shows/spring-2015-ready-to-wear/"

LOCAL_DIR = "C:/style.com/resort-2015/"
MAIN_URL = "http://www.style.com/fashion-shows/resort-2015/"

SITE_URL = "http://www.style.com"
SLEEP_SECONDS = 0.2
THREAD_POOL_THREADS = 10
THREAD_POOL_POOL_SIZE = 10

# 获取reviews链接
def get_reviews_url(url):
    content = urllib2.urlopen(url, timeout=TIME_OUT_SECONDS).read()

    # soup = BeautifulSoup(content)
    # links = soup.find_all(name= "div", attrs= { "class" : "fashion-grid__item fashion-grid-item" })
    # # logging.debug("reviews url count = %d", len(links))
    # print "reviews url count = %d" % (len(links), )


    l = []
    for line in content.split('\n'):

        if line.lstrip().startswith('<a href="/fashion-shows/'):
            line = line.lstrip().replace('<a href="', '').replace('">', '')

            review_url = SITE_URL + line + "collection/"
            idx = line.rfind('/', 0, len(line) - 1) + 1

            review_name = line[idx: len(line) - 1]
            l.append({'name': review_name, "url": review_url})

    return l


# 获取图片rest链接
def get_rest_url(url):
    content = urllib2.urlopen(url, timeout=TIME_OUT_SECONDS).read()
    soup = BeautifulSoup(content)
    head = soup.find("head").get_text()
    begin = head.index("var fsUrl")
    end = head.index(";", begin)

    link = head[int(begin): int(end)]
    link = link[link.index('\"') + 1: link.index("\"", link.index('\"') + 1)]
    link = SITE_URL + link + "/looks"
    return link


# 获取图片链接
def get_image_url(url):
    content = urllib2.urlopen(url, timeout=TIME_OUT_SECONDS).read()

    soup = BeautifulSoup(content)
    links = soup.find(attrs={"class": "fashion-grid fashion-grid--listing"}).find_all(name="div", attrs={
    "class": "fashion-grid-item__image-wrapper"})
    # logging.debug("reviews url count = %d", len(links))
    print "image url count = %d" % (len(links), )

    urls = []
    for e in links:
        img_url = e.find("img").get("src")
        img_url = img_url.replace('/265/400/', '/1366/2048/')

        urls.append(img_url)
    return urls


# 下载图片
def download_image(url, save_path, filename, sleep_seconds=1):
    try:
        if not os.path.exists(save_path):
            try:
                os.makedirs(save_path)
            except Exception as e:
                if str(e) == '[Error 183] ':
                    print 'mkdir failed : path already exists: %s' % (save_path,)
                    logging.error('mkdir failed : path already exists: %s' % (save_path,))
        dist = os.path.join(save_path, filename)
        if os.path.exists(dist):
            print 'image exists, skipping : %s' % (url,)
            logging.debug('image exists, skipping : %s' % (url,))
        else:

            for i in range(1, 10):
                try:
                    socket.setdefaulttimeout(TIME_OUT_SECONDS)
                    urllib.urlretrieve(url, dist, None)
                    time.sleep(sleep_seconds)
                    print "image downloaded : %s" % (url,)
                    logging.debug("image downloaded : %s" % (url,))
                    break
                except Exception, e:
                    print 'image downloaded error times' + str(i) + ': %s' % (e,)
                    logging.error('image downloaded error times' + str(i) + ': %s' % (e,))
                    time.sleep(10)


    except Exception as err:
        detail = traceback.format_exc()
        logging.error('error: url= %s', url)
        logging.error(err)
        logging.error(detail)


# 下载图片
def download_image2(url, save_path, filename, sleep_seconds=1):
    try:
        if not os.path.exists(save_path):
            os.makedirs(save_path)
        dist = os.path.join(save_path, filename)
        imgData = urllib2.urlopen(url, timeout=TIME_OUT_SECONDS).read()
        output = open(dist, 'wb')
        output.write(imgData)
        output.close()
        time.sleep(sleep_seconds)
        logging.debug("image downloaded : %s" % (url,))
        print "image downloaded : %s" % (url,)
    except Exception as err:
        detail = traceback.format_exc()
        logging.error('error: url= %s', url)
        logging.error(err)
        logging.error(detail)


def test():
    get_image_url("http://www.style.com/fashion-shows/spring-2015-ready-to-wear/a-p-c-/collection/")


if __name__ == '__main__':


    logging.basicConfig(
        format='%(filename)s [%(asctime)s] [%(levelname)s] %(message)s',
        level=logging.DEBUG,
        filename='debug.log',
        filemode='a')
    reviewsUrls = get_reviews_url(MAIN_URL)

    progress = 0
    total = len(reviewsUrls)

    pool = ThreadPool(THREAD_POOL_THREADS, THREAD_POOL_POOL_SIZE)  # 线程池

    for reviewUrl in reviewsUrls:
        reviewName = reviewUrl['name']
        url = reviewUrl['url']
        progress += 1

        restUrl = url

        for i in range(1, 10):
            try:
                imageUrls = get_image_url(restUrl)
                break
            except Exception, e:
                print 'get restUrl error times' + str(i) + ': %s' % (e,)
                logging.error('get restUrl error times' + str(i) + ': %s' % (e,))
                time.sleep(10)

        if imageUrls is None or len(imageUrls) == 0:
            print 'get imageUrls error %s' % restUrl
            logging.error('get imageUrls error %s' % restUrl)
            continue

        # logging.debug("progress: %d of %d, %s , %d images", progress, total, reviewName, len(urls))  # 进度

        count = 0
        for imageUrl in imageUrls:
            # download_image(imageUrl, LOCAL_DIR + reviewName,
            # imageUrl[imageUrl.rfind("/") + 1:] + ".jpg")
            pool.add_task(download_image, imageUrl, LOCAL_DIR + reviewName,
                          imageUrl[imageUrl.rfind("/") + 1:], SLEEP_SECONDS)  # 多线程下载图片
            count += 1
            # logging.debug("task added: %d", count)
            # logging.debug("finished : %s", reviewName)
            # print "finished : %s" % ( reviewName)
            #logging.info("finished : %s" % ( reviewName))
    pool.destroy()