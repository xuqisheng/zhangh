#!/usr/bin/env python
# coding:utf-8

"""
@version:
@author :zhangh
@file   :bs4Demo.py
@time   :2017/5/7 21:13
@remark :
"""
import re

from bs4 import BeautifulSoup

html ="""
<div class="overview"><div class="img" id="topImg">
<div class="imgContainer">
<img class="new-default-icon maxWidth" src="http://s1.ljcdn.com/feroot/pc/asset/img/blank.gif?_v=20170504205919" alt=""><span></span></div><div class="thumbnail" id="thumbnail2"><div class="pre"><</div><ul class="smallpic"><li data-src="http://image1.ljcdn.com/330100-inspection/72d71bcf-df0e-42d5-bc98-696e21a065c0.JPG.710x400.jpg" data-size="1420x800" data-desc="厅A" data-pic="http://image1.ljcdn.com/330100-inspection/72d71bcf-df0e-42d5-bc98-696e21a065c0.JPG.1420x800.jpg">
<img src="http://image1.ljcdn.com/330100-inspection/72d71bcf-df0e-42d5-bc98-696e21a065c0.JPG.120x80.jpg" alt=""></li><li data-src="http://image1.ljcdn.com/330100-inspection/b92b446f-7bbb-4ffe-a8d6-ddadc7600e68.JPG.710x400.jpg" data-size="1420x800" data-desc="厅B" data-pic="http://image1.ljcdn.com/330100-inspection/b92b446f-7bbb-4ffe-a8d6-ddadc7600e68.JPG.1420x800.jpg">
<img src="http://image1.ljcdn.com/330100-inspection/b92b446f-7bbb-4ffe-a8d6-ddadc7600e68.JPG.120x80.jpg" alt=""></li><li data-src="http://image1.ljcdn.com/330100-inspection/42594bec-8b9c-4385-b736-b2733fb8dfc8.JPG.710x400.jpg" data-size="1420x800" data-desc="厅C" data-pic="http://image1.ljcdn.com/330100-inspection/42594bec-8b9c-4385-b736-b2733fb8dfc8.JPG.1420x800.jpg">
<img src="http://image1.ljcdn.com/330100-inspection/42594bec-8b9c-4385-b736-b2733fb8dfc8.JPG.120x80.jpg" alt=""></li><li data-src="http://image1.ljcdn.com/x-se//hdic-frame/fbe8ab24-3612-4178-9d6a-62a58c7847fd.jpg.533x400.jpg" data-size="1066x800" data-desc="户型图" data-pic="http://image1.ljcdn.com/x-se//hdic-frame/fbe8ab24-3612-4178-9d6a-62a58c7847fd.jpg.1066x800.jpg">
<img src="http://image1.ljcdn.com/x-se//hdic-frame/fbe8ab24-3612-4178-9d6a-62a58c7847fd.jpg.120x80.jpg" alt=""></li><li data-src="http://image1.ljcdn.com/330100-inspection/8fdfc405-b726-417d-adea-065953dcb4f9.JPG.710x400.jpg" data-size="1420x800" data-desc="卧室A" data-pic="http://image1.ljcdn.com/330100-inspection/8fdfc405-b726-417d-adea-065953dcb4f9.JPG.1420x800.jpg">
<img src="http://image1.ljcdn.com/330100-inspection/8fdfc405-b726-417d-adea-065953dcb4f9.JPG.120x80.jpg" alt=""></li><li data-src="http://image1.ljcdn.com/330100-inspection/27fe965a-b47a-491c-959a-234f1cfff91b.JPG.710x400.jpg" data-size="1420x800" data-desc="卧室B" data-pic="http://image1.ljcdn.com/330100-inspection/27fe965a-b47a-491c-959a-234f1cfff91b.JPG.1420x800.jpg">
<img src="http://image1.ljcdn.com/330100-inspection/27fe965a-b47a-491c-959a-234f1cfff91b.JPG.120x80.jpg" alt=""></li><li data-src="http://image1.ljcdn.com/330100-inspection/69d4d50c-9bfa-45d7-8414-749802c179be.JPG.710x400.jpg" data-size="1420x800" data-desc="卧室C" data-pic="http://image1.ljcdn.com/330100-inspection/69d4d50c-9bfa-45d7-8414-749802c179be.JPG.1420x800.jpg">
<img src="http://image1.ljcdn.com/330100-inspection/69d4d50c-9bfa-45d7-8414-749802c179be.JPG.120x80.jpg" alt=""></li><li data-src="http://image1.ljcdn.com/330100-inspection/4c0943aa-c60c-48b9-88ba-2c257f5da2a7.JPG.710x400.jpg" data-size="1420x800" data-desc="厨房" data-pic="http://image1.ljcdn.com/330100-inspection/4c0943aa-c60c-48b9-88ba-2c257f5da2a7.JPG.1420x800.jpg">
<img src="http://image1.ljcdn.com/330100-inspection/4c0943aa-c60c-48b9-88ba-2c257f5da2a7.JPG.120x80.jpg" alt=""></li><li data-src="http://image1.ljcdn.com/330100-inspection/e569aa61-9111-45e7-a084-9744f677bd91.JPG.710x400.jpg" data-size="1420x800" data-desc="卫生间A" data-pic="http://image1.ljcdn.com/330100-inspection/e569aa61-9111-45e7-a084-9744f677bd91.JPG.1420x800.jpg">
<img src="http://image1.ljcdn.com/330100-inspection/e569aa61-9111-45e7-a084-9744f677bd91.JPG.120x80.jpg" alt=""></li><li data-src="http://image1.ljcdn.com/330100-inspection/059b3854-80e0-4b23-883f-5a4634c2f293.JPG.710x400.jpg" data-size="1420x800" data-desc="卫生间B" data-pic="http://image1.ljcdn.com/330100-inspection/059b3854-80e0-4b23-883f-5a4634c2f293.JPG.1420x800.jpg">
<img src="http://image1.ljcdn.com/330100-inspection/059b3854-80e0-4b23-883f-5a4634c2f293.JPG.120x80.jpg" alt=""></li></ul><div class="next">></div></div></div><div class="content"><span class="sharethis"><i></i>分享此房源</span><div class="compareBtn LOGCLICK" log-mod="103101199174" data-bl="right_top" data-log_evtid="10231">
<span class="compareIcon"></span><span class="compareText">加入对比</span></div><div class="price ">
<span class="total">350</span><span class="unit"><span>万</span></span><div class="text"><div class="unitPrice">
<span class="unitPriceValue">28040<i>元/平米</i></span></div><div class="tax"><span class="taxtext" title="首付105万 税费">
<span>首付105万 </span><span>税费</span><span><span id="PanelTax">13.8</span>万(仅供参考) </span></span>
<span class="detail" id="lookdetail">详情</span></div></div><div class="removeIcon"></div></div>
<div class="houseInfo"><div class="room"><div class="mainInfo">3室3厅</div>
<div class="subInfo">高楼层/共18层</div></div><div class="type">
<div class="mainInfo" title="南 北">南 北</div><div class="subInfo">精装</div></div>
<div class="area"><div class="mainInfo">124.82平米</div><div class="subInfo">2008年建/板楼</div></div></div>
<div class="aroundInfo"><div class="communityName"><i></i><span class="label">小区名称</span>
<a href="/xiaoqu/1811044013284/" target="_blank" class="info">小河佳苑</a><a href="#around" class="map">地图</a></div>
<div class="areaName"><i></i><span class="label">所在区域</span><span class="info"><a href="/ershoufang/gongshu/" target="_blank">拱墅</a>&nbsp;<a href="/ershoufang/hemu/" target="_blank">和睦</a>&nbsp;</span>
<a href="" class="supplement" title="" style="color:#394043;"></a></div><div class="visitTime"><i></i><span class="label">看房时间</span><span class="info">提前预约随时可看</span></div><div class="houseRecord"><span class="label">链家编号</span>
<span class="info">103101199174<span class="jubao"><a href="javascript:;" class="report">举报</a><a href="//www.lianjia.com/zhuanti/pfgz" target="blank" class="detail"></a></span></span></div></div>
<div class="brokerInfo clear" log-mod="ershoufang_detail_diamond-first"><a class="fl LOGVIEW LOGCLICK" data-log_id="20001" data-bl="agent" data-el="1000000020159827" target="_blank" href="http://dianpu.lianjia.com/1000000020159827">
<img src="http://image1.ljcdn.com/usercenter/images/uc_ehr_avatar/0aa91cc5-e9dd-4efd-b037-9730c4fc21d4.jpg.60x80.jpg" alt=""></a><div class="brokerInfoText fr"><div class="brokerName"><a target="_blank" data-log_id="20001" data-bl="agent" data-el="1000000020159827" href="http://dianpu.lianjia.com/1000000020159827" class="name LOGCLICK">施鑫明</a>
<a class="lianjiaim-createtalkAll new-talk LOGCLICK" data-log_id="20001" data-bl="agentim" data-el="1000000020159827" style="display: none;" title="在线咨询" data-role="lianjiaim-createtalk" data-ucid="1000000020159827"><span class="im-icon"></span>沟通</a><span class="tag first" >评分:4.9/<a href="http://dianpu.lianjia.com/1000000020159827/?w=pingjia">82人评价</a></span></div>
<div class="evaluate">本房信息由我更新维护，有变化最快得知</div><div class="phone" >4008897287<span>转</span>1809</div></div></div></div></div>

<div class="tab-wrap">
  <div class="wrap">
    <div class="panel-tab">
      <ul class="clear">
        <li>
          <a href="#introduction" class="on">房源信息介绍</a>
        </li>
                  <li>
            <a href="#layout">户型分间</a>
          </li>
                        <li>
          <a href="#calculator" id="taxm">税费贷款</a>
        </li>
        <li>
          <a href="#record">看房记录</a>
        </li>
        <li>
          <a href="#resblockCardContainer">小区简介</a>
        </li>
        <li>
          <a href="#dealPrice">小区成交</a>
        </li>
        <li>
          <a href="#around" class="LOGCLICK" data-log_evtid='10242'  data-bl="supporting">周边配套</a>
        </li>
      </ul>
    </div>
  </div>
</div>

<div class="m-content">
    <div class="box-l">
        <!-- 基本信息 -->
        <div class="newwrap baseinform" id="introduction">
          <div class="" style="width:700px;">
            <h2><div class="title">基本信息</div></h2>
            <div class="introContent">
              <div class="base">
                <div class="name">基本属性</div>
                <div class="content">
                  <ul>
                                        <li><span class="label">房屋户型</span>3室3厅1厨2卫</li>
                    <li><span class="label">所在楼层</span>高楼层 (共18层)</li>
                    <li><span class="label">建筑面积</span>124.82㎡</li>
                                          <li><span class="label">户型结构</span>暂无数据</li>
                                        <li><span class="label">套内面积</span>96㎡</li>
                                          <li><span class="label">建筑类型</span>板楼</li>
                                        <li><span class="label">房屋朝向</span>南 北</li>
                    <li><span class="label">建筑结构</span>钢混结构</li>
                    <li><span class="label">装修情况</span>精装</li>
                                            <li><span class="label">梯户比例</span>两梯四户</li>
                                                                                        <li><span class="label">配备电梯</span>有</li>
                                          <li><span class="label">产权年限</span>未知</li>
                                                            </ul>
                </div>
              </div>
              <div class="transaction">
                <div class="name">交易属性</div>
                <div class="content">
                  <ul>
                    <li><span class="label">挂牌时间</span>2017-04-12</li>
                    <li><span class="label">交易权属</span>已购公房</li>
                    <li><span class="label">上次交易</span>2009-02-02</li>
                    <li><span class="label">房屋用途</span>普通住宅</li>
                    <li><span class="label">房屋年限</span>满两年</li>
                    <li><span class="label">产权所属</span>共有</li>
                    <!--<li><span class="label">是否唯一</span>不唯一</li>-->
                    <li><span class="label">抵押信息</span><span style="display:inline-block;width:64%;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;vertical-align:middle;" title="有抵押 业主自还">有抵押 业主自还</span></li>
                    <li><span class="label">房本备件</span>已上传房本照片</li>
                                      </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
        
<div class="newwrap baseinform">
  <h2><div class="title" style="margin-top:50px;">房源特色</div></h2>
  <div class="introContent showbasemore">
                <div class="tags clear">
      <div class="name">房源标签</div>
      <div class="content">
                                        <a class="tag five" href="http://hz.lianjia.com/ershoufang/hemu/tf1/">房本满两年</a>
                                                        <a class="tag is_see_free" href="http://hz.lianjia.com/ershoufang/hemu/tt4/">随时看房</a>
                                      </div>
    </div>
                                              <div class="baseattribute clear">
          <div class="name">核心卖点</div>
          <div class="content">
            南北通透 精装跃层 带约15方露台 带约6方储藏室 可变四房2厅 
          </div>
        </div>
                      <div class="baseattribute clear">
          <div class="name">户型介绍</div>
          <div class="content">
            楼下两个房间 一房朝南 一房朝西，客厅朝南，餐厅.厨房.卫生间朝北。楼上一房朝南主卧带卫生间，厅朝北直对露台，可变书房，露台约15方，可走出，露台只有自己一户可以用，露台边上还有一个约6平米的储藏室。
          </div>
        </div>
                      <div class="baseattribute clear">
          <div class="name">交通出行</div>
          <div class="content">
            北大桥 （15路; 67路; 70路; 90路; 93路; 153路; 188路; 204路; 227路; 348路; b支1路; k155路） 825米 【公交】 小河佳苑 （1路; 61路; 79路; 516路） 206米 和睦新村 （15路; 67路; 76路; 90路; 153路; 188路; 192路; 204路;
          </div>
        </div>
                      <div class="baseattribute clear">
          <div class="name">周边配套</div>
          <div class="content">
            大型物美超市，蓝钻综合体，D32综合体，台湾美食街，; 菜场：和睦农贸市场，小河农贸市场; 银行：工商银行，杭州银行，杭州联合银行，建设银行ATM； 景区：小河直街历史街区，运河广场。
          </div>
        </div>
                      <div class="baseattribute clear">
          <div class="name">小区介绍</div>
          <div class="content">
            小区概况建造年代在两公里内小区里都是属于比较新的，是2008年左右的房子，95%都是免增值税的， 按揭贷款的话公积金、贷款都可以操作，小区位置位于莫干山路和赵伍路交叉口，属于和睦商圈交通 便利，配套成熟，公交直达西湖，黄龙商圈
          </div>
        </div>
                    <div class="viewmore">展开更多信息</div>
      <div class="disclaimer">注：土地使用起止年限详见业主土地证明材料或查询相关政府部门的登记文件。</div>
              </div>
</div>
"""
info = {}

sub_soup = BeautifulSoup(html,'html.parser')
sub_overview = sub_soup.select(".overview .content .price span")
# print sub_overview
info['房屋总价'] = ''.join(list(re.compile('<span class="total">(.*?)</span>').findall(str(sub_overview))))
# info['平方均价'] = ''.join(list(re.compile('<span class="unitPriceValue">(.*?)<i>').findall(str(sub_overview))))
#
# sub_around = sub_soup.select(".overview .content .aroundInfo .communityName a")
# # print sub_around
# info['小区名称'] = ''.join(list(re.compile('<a class="info".*?>(.*?)</a>').findall(str(sub_around))))
# info['所在区域'] = ''.join(list(re.compile('<a href=.*?target="_blank">(.*?)</a>').findall(str(sub_around))))
#
# sub_intro = sub_soup.select(".introContent .content li")
# # print sub_intro
# for sub_label in sub_intro:
#     # 使用正则，取得dict的key
#     re_key = ''.join(list(re.compile('<span class="label">(.*?)</span>').findall(str(sub_label))))
#     # 使用正则，取得dict的value
#     re_value = ''.join(list(re.compile('<span class="label">.*?</span>(.*?)</li>').findall(str(sub_label))))
#     info[re_key] = re_value

aaa = sub_soup.select(".baseinform div")
info['测试']=''.join(list(re.compile('<div class="" style="width:700px;">.*?<h2><div class="title">(.*?)</div></h2>.*?<div class="introContent">').findall(str(aaa))))
print aaa

print info
