#!/usr/bin/env python
# coding:utf8

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

# pipelines：管道模块，处理spider模块分析好的结构化数据，如保存入库等

class ScrapyspacePipeline(object):
    def process_item(self, item, spider):
        return item
