#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'fangs'

import os
from threading import Thread
import sys
from Queue import Queue

from bs4 import BeautifulSoup
import requests


concurrent = 200


def doWork():
    while True:
        url, dir_name = q.get()
        download(url, dir_name)
        q.task_done()


def download(url, dir_name):
    print "==========>>>>>>>>>>>>>>>"
    print url

    r = requests.get(url)
    data = r.text
    soup = BeautifulSoup(data)

    i = 1
    for link in soup.find("div", class_="fashion-grid fashion-grid--listing").find_all("div",
                                                                                       class_="fashion-grid-item__image-wrapper"):
        image = link.find("img")["src"]
        image = image.replace("265", "10000")
        image = image.replace("400", "10000")
        base_dir = os.getcwd() + "/" + dir_name + "/"
        if not os.path.isdir(base_dir):
            os.mkdir(base_dir)
        save_dir = base_dir + "%04d" % i + ".jpg"

        print image
        print save_dir

        if not os.path.exists(save_dir):
            r = requests.get(image, stream=True)
            with open(save_dir, 'wb') as fd:
                for chunk in r.iter_content():
                    fd.write(chunk)
        i += 1


if __name__ == "__main__":


    q = Queue(concurrent * 2)
    for i in range(concurrent):
        t = Thread(target=doWork)
        t.daemon = True
        t.start()
    try:

        q.put(("http://www.style.com/fashion-shows/spring-2015-couture/chanel/collection", "chanel-collection"))
        q.put(("http://www.style.com/fashion-shows/spring-2015-couture/chanel/details", "chanel-details"))

        q.put(("http://www.style.com/fashion-shows/spring-2015-couture/elie-saab/collection",
               "elie-saab-collection"))
        q.put(("http://www.style.com/fashion-shows/spring-2015-couture/elie-saab/details", "elie-saab-details"))

        q.put(("http://www.style.com/fashion-shows/spring-2015-couture/giambattista-valli/collection",
               "giambattista-valli-collection"))
        q.put(("http://www.style.com/fashion-shows/spring-2015-couture/giambattista-valli/details",
               "giambattista-valli-details"))

        q.put(("http://www.style.com/fashion-shows/spring-2015-couture/christian-dior/collection",
               "christian-dior-collection"))
        q.put(("http://www.style.com/fashion-shows/spring-2015-couture/christian-dior/details",
               "christian-dior-details"))

        q.put(("http://www.style.com/fashion-shows/spring-2015-couture/schiaparelli/collection",
               "schiaparelli-collection"))
        q.put(("http://www.style.com/fashion-shows/spring-2015-couture/schiaparelli/details",
               "schiaparelli-details"))

        q.put(("http://www.style.com/fashion-shows/spring-2015-couture/maison-martin-margiela/collection",
               "maison-martin-margiela-collection"))
        q.put(("http://www.style.com/fashion-shows/spring-2015-couture/maison-martin-margiela/details",
               "maison-martin-margiela-details"))

        q.join()
    except KeyboardInterrupt:
        sys.exit(1)