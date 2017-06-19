# -*- coding: utf-8 -*-
import scrapy
import json
import time

cookies_set = {
            'JSESSIONID': '25FBBBFD3FB8682420A0A9E63E421CF3',
            '_gat': '1',
            'user_trace_token': '20170116144823-c695f8ea-dbb7-11e6-8c79-5254005c3644',
            'PRE_UTM': '',
            'PRE_HOST': '',
            'PRE_SITE': '',
            'PRE_LAND': 'https%3A%2F%2Fwww.lagou.com%2F',
            'LGUID': '20170116144823-c695fb8b-dbb7-11e6-8c79-5254005c3644',
            'index_location_city': '%E5%85%A8%E5%9B%BD',
            'SEARCH_ID': '8a01260e42b54ee6bf878e3ae40adf3a',
            '_ga': 'GA1.2.468593365.1484549304',
            'Hm_lvt_4233e74dff0ae5bd0a3d81c6ccf756e6': '1484549304',
            'Hm_lpvt_4233e74dff0ae5bd0a3d81c6ccf756e6': '1484549311',
            'LGSID': '20170116144823-c695f9e1-dbb7-11e6-8c79-5254005c3644',
            'LGRID': '20170116144840-d0b61353-dbb7-11e6-8c79-5254005c3644',
            'TG-TRACK-CODE': 'search_code',
          }

headers_set = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36',
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'Accept': 'application/json, text/javascript, */*; q=0.01',
            'X-Requested-With': 'XMLHttpRequest',

          }


class LagouSpider(scrapy.Spider):
    name = "lagou"

    def start_requests(self):
      url = 'https://www.lagou.com/jobs/positionAjax.json?px=default&needAddtionalResult=false'
      for i in range(1,22):
        time.sleep(1)
        # yield 的作用就是把一个函数变成一个 generator，带有 yield 的函数不再是一个普通函数，Python 解释器会将其视为一个 generator
        yield scrapy.Request(
          url=url, 
          callback=self.parse, 
          method="POST", 
          body=("first=false&kd=%E7%88%AC%E8%99%AB&pn=" + str(i)), 
          meta={ 'dont_obey_robotstxt': True },
          cookies=cookies_set,
          headers=headers_set)

    def parse(self, response):
      print('response.url')
      print(response.url)
      result = json.loads(response.text)['content']['positionResult']['result']

      for row in result:
        result = {
          'position_name': row['positionName'],
          'company_full_name': row['companyFullName'],
          'salary': row['salary'],
          'create_time': row['createTime'],
          'position_advantage': row['positionAdvantage'],
          'position_id': row['positionId'],
          'company_id': row['companyId'],
        }

        job_url = 'https://www.lagou.com/jobs/%s.html' % row['positionId']
        print(job_url)
        time.sleep(1)
        job_request = scrapy.Request(url=job_url, callback=self.parse_job)
        job_request.meta['result'] = result
        yield job_request

    def parse_job(self, response):
      time.sleep(1)
      print('response.url')
      print(response.url)
      data = response.css('.work_addr a::text, .work_addr::text').extract()
      location = ''.join([x.strip() for x in data ]).replace(u'查看地图','')
      result = response.meta['result']
      result['location'] = location

      time.sleep(1)
      company_url = 'https://www.lagou.com/gongsi/%s.html' % result['company_id']
      print(company_url)
      company_request = scrapy.Request(url=company_url, callback=self.parse_company)
      company_request.meta['result'] = result
      yield company_request

    def parse_company(self, response):
      print('response.url')
      print(response.url)
      data = response.css('.company_intro_text .company_content p::text').extract()
      data = "\n".join([x.strip() for x in data ])
      result = response.meta['result']
      result['company_info'] = data
      yield result

      

