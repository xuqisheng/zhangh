
if exists(select * from sysobjects where name = "cmb_item")
	drop table cmb_item;
create table cmb_item
(
 item 			varchar(40) 						not null ,
 descript 		varchar(60) 						null ,
 descript1 		varchar(60) 						null,
 sequence 		int 									null,
 helpable 		char(1) 			default 'F' 	null ,
 help 			varchar(255) 						null,
 sm				char(1) 			default 'S' 	null, --帮助单选S,多选M
 descript_sql 	varchar(255) 						null,
 halt 			char(1) default 'F' 				null, --停用
);
exec sp_primarykey cmb_item, item ;
create unique index index1 on cmb_item(item);


--insert into cmb_item (item,descript,descript1,sequence) values ('no','档案号',10 )
insert into cmb_item (item,descript,descript1,sequence) values ('sta','状态' ,'Status',30)
insert into cmb_item (item,descript,descript1,sequence) values ('name','本名','Name', 20)
insert into cmb_item (item,descript,descript1,sequence) values ('lname','姓' ,'Family Name',40)
insert into cmb_item (item,descript,descript1,sequence) values ('fname','名' ,'First Name',50)
insert into cmb_item (item,descript,descript1,sequence) values ('name2','姓名2','Name2',60 )
insert into cmb_item (item,descript,descript1,sequence) values ('sno','编号' ,'NO',70)
insert into cmb_item (item,descript,descript1,sequence) values ('vip','Vip','Vip' ,80)
	update cmb_item set helpable = 'T',sm = 'S',help='VIP帮助;(select code,descript from basecode where cat="vip" order by sequence,code);code:代码;descript:描述=40',descript_sql ='select descript from basecode where cat="vip" and code = "###"'  where item = 'vip';

insert into cmb_item (item,descript,descript1,sequence) values ('sex','性别','Gender' ,90)
	update cmb_item set helpable = 'T',sm = 'S',help='性别帮助;(select code,descript from basecode where cat="sex" order by sequence,code);code:代码;descript:描述=40',descript_sql ='select descript from basecode where cat="sex" and code = "###"'  where item = 'sex';
insert into cmb_item (item,descript,descript1,sequence) values ('birth','生日' ,'Birthday',100)
insert into cmb_item (item,descript,descript1,sequence) values ('lang','语种' ,'Language',110)
	update cmb_item set helpable = 'T',sm = 'S',help='语种帮助;(select code,descript from basecode where cat="language" order by sequence,code);code:代码;descript:描述=40',descript_sql ='select descript from basecode where cat="language" and code = "###"'  where item = 'lang';

insert into cmb_item (item,descript,descript1,sequence) values ('title','称谓','Title' ,120)
insert into cmb_item (item,descript,descript1,sequence) values ('city','籍贯' ,'Recidence',130)
	update cmb_item set helpable = 'T',sm = 'S',help='籍贯帮助;(select code,descript from cntcode order by code);code:代码;descript:描述',descript_sql ='select descript from cntcode where code="###"'  where item = 'city';


insert into cmb_item (item,descript,descript1,sequence) values ('salutation','称呼' ,'Salutation',140)
insert into cmb_item (item,descript,descript1,sequence) values ('cusno','单位号' ,'Comp.NO',150)
insert into cmb_item (item,descript,descript1,sequence) values ('unit','单位' ,'Company',160)
insert into cmb_item (item,descript,descript1,sequence) values ('cno','职业' ,'Occupation',170)
insert into cmb_item (item,descript,descript1,sequence) values ('saleid','销售员','saler',180 )
	update cmb_item set helpable = 'T',sm = 'S',help='销售员帮助;(select code,descript,descript1 from saleid order by code);code:代码;descript:姓名;descript1:英文名'  where item = 'saleid';
insert into cmb_item (item,descript,descript1,sequence) values ('master','主帐号','Master.NO' ,190)
--insert into cmb_item (item,descript,descript1,sequence) values ('hotelid','Hotel ID' ,200)
insert into cmb_item (item,descript,descript1,sequence) values ('central','集团档案编码','Cent.Profile NO',210)
insert into cmb_item (item,descript,descript1,sequence) values ('censeq','序号','Cent.Senquence' ,220)
insert into cmb_item (item,descript,descript1,sequence) values ('keep','保存客史','Keep' ,230)
insert into cmb_item (item,descript,descript1,sequence) values ('override','超限额订房','Override' ,240)
insert into cmb_item (item,descript,descript1,sequence) values ('street','街道' ,'Street',250)
insert into cmb_item (item,descript,descript1,sequence) values ('zip','邮编' ,'Zipcode',260)
insert into cmb_item (item,descript,descript1,sequence) values ('town','城市' ,'Town',270)
insert into cmb_item (item,descript,descript1,sequence) values ('country','国家' ,'Country',270)
	update cmb_item set helpable = 'T',sm = 'S',help='代码帮助;(select code,descript,descript1,helpcode from countrycode order by sequence,code);code:代码;descript:描述1=20;descript1:描述2=20;helpcode:帮助码=10',descript_sql = "select descript from countrycode where code = '###'" where item = 'country';
insert into cmb_item (item,descript,descript1,sequence) values ('state','省/州','State',290)
	update cmb_item set helpable = 'T',sm = 'S',help='省/州帮助;(select code,descript from prvcode order by sequence,code);code:代码;descript:描述',descript_sql ='select descript from prvcode where code="###" '  where item = 'state';

insert into cmb_item (item,descript,descript1,sequence) values ('mobile','手机' ,'Mobile',300)
insert into cmb_item (item,descript,descript1,sequence) values ('phone','电话' ,'Phone',310)
insert into cmb_item (item,descript,descript1,sequence) values ('fax','传真','Fax',320)
insert into cmb_item (item,descript,descript1,sequence) values ('email','Email' ,'Email',330)
insert into cmb_item (item,descript,descript1,sequence) values ('idcls','证件类型','ID Type',340)
	update cmb_item set helpable = 'T',sm = 'S',help='证件类型;(select code,descript from basecode where cat="idcode" order by sequence,code);code:代码;descript:描述',descript_sql ='select descript from basecode where cat="idcode" and code = "###"'  where item = 'idcls';



insert into cmb_item (item,descript,descript1,sequence) values ('nation','国籍' ,'Nation',350)
	update cmb_item set helpable = 'T',sm = 'S',help='代码帮助;(select code,descript,descript1,helpcode from countrycode order by sequence,code);code:代码;descript:描述1=20;descript1:描述2=20;helpcode:帮助码=10',descript_sql = "select descript from countrycode where code = '###'" where item = 'nation';

insert into cmb_item (item,descript,descript1,sequence) values ('visaid','签证类型','Visa Type' ,360)
	update cmb_item set helpable = 'T',sm = 'S',help='签证类型;(select code,descript from basecode where cat="visaid" order by sequence,code);code:代码;descript:描述=30',descript_sql ='select descript from basecode where cat="visaid" and code = "###"'  where item = 'visaid';

insert into cmb_item (item,descript,descript1,sequence) values ('visano','签证号码','Visa NO',370)
insert into cmb_item (item,descript,descript1,sequence) values ('visaend','签证有效期','Visa Validity',380)
insert into cmb_item (item,descript,descript1,sequence) values ('street1','街道2','Street1',390)
insert into cmb_item (item,descript,descript1,sequence) values ('zip1','邮编2','Zipcode1',400)
insert into cmb_item (item,descript,descript1,sequence) values ('town1','城市2' ,'Town1',410)
insert into cmb_item (item,descript,descript1,sequence) values ('country1','国家' ,'Country1',420)
	update cmb_item set helpable = 'T',sm = 'S',help='代码帮助;(select code,descript,descript1,helpcode from countrycode order by sequence,code);code:代码;descript:描述1=20;descript1:描述2=20;helpcode:帮助码=10',descript_sql = "select descript from countrycode where code = '###'" where item = 'country1';

insert into cmb_item (item,descript,descript1,sequence) values ('state1','省/州2','State1' ,430)
	update cmb_item set helpable = 'T',sm = 'S',help='省/州帮助;(select code,descript from prvcode order by sequence,code);code:代码;descript:描述',descript_sql ='select descript from prvcode where code="###" '  where item = 'state1';

insert into cmb_item (item,descript,descript1,sequence) values ('mobile1','手机2','Mobile1' ,440)
insert into cmb_item (item,descript,descript1,sequence) values ('phone1','电话2','Phone1' ,450)
insert into cmb_item (item,descript,descript1,sequence) values ('fax1','传真2','Fax1' ,460)
insert into cmb_item (item,descript,descript1,sequence) values ('email1','Email2','Email2',470 );
insert into cmb_item (item,descript,descript1,sequence) values ('srqs','特殊要求','Specials',480 );
	update cmb_item set helpable = 'T',sm = 'M',help='特殊要求帮助;(select code,descript,descript1 from reqcode order by sequence);code:代码=3;descript:描述1;descript1:描述2',descript_sql = "" where item = 'srqs';

insert into cmb_item (item,descript,descript1,sequence) values ('interest','兴趣爱好','Interest',490 );
	update cmb_item set helpable = 'T',sm = 'M',help='兴趣爱好帮助;(select code,descript,descript1 from basecode where cat="interest" order by sequence);code:代码;descript:描述1=30;descript1:描述2=30',descript_sql = "" where item = 'interest';

insert into cmb_item (item,descript,descript1,sequence) values ('rmpref','房号偏好','Room Preferred',500 );
insert into cmb_item (item,descript,descript1,sequence) values ('feature','排房要求','Feature',510 );
insert into cmb_item (item,descript,descript1,sequence) values ('extrainf','附加信息','Extra Info',520 );
insert into cmb_item (item,descript,descript1,sequence) values ('refer1','前台喜好','Refer1',530 );
insert into cmb_item (item,descript,descript1,sequence) values ('refer2','餐饮喜好','Refer2',540 );
insert into cmb_item (item,descript,descript1,sequence) values ('comment','说明','Comment',550 );
insert into cmb_item (item,descript,descript1,sequence) values ('remark','备注','Remark',560 );
insert into cmb_item (item,descript,descript1,sequence) values ('src','来源','Source',570 );
	update cmb_item set helpable = 'T',sm = 'S',help='来源帮助;(select code,descript from srccode order by sequence);code:代码;descript:描述',descript_sql ='select descript from srccode where code = "###"'  where item = 'src';
insert into cmb_item (item,descript,descript1,sequence) values ('market','市场','Market',580 );
	update cmb_item set helpable = 'T',sm = 'S',help='市场代码帮助;(select code,descript from mktcode order by sequence);code:代码;descript:描述',descript_sql ='select descript from mktcode where code = "###"'  where item = 'market';
insert into cmb_item (item,descript,descript1,sequence) values ('latency','潜在客户','Latency',590 );
	update cmb_item set helpable = 'T',sm = 'S',help='潜在客户帮助;(select code,descript from basecode where cat="latency" order by sequence,code);code:代码;descript:描述=30',descript_sql ='select descript from basecode where cat="latency" and code = "###"'  where item = 'latency';
insert into cmb_item (item,descript,descript1,sequence) values ('class1','类别1','Class1',600 );
	update cmb_item set helpable = 'T',sm = 'S',help='类别1帮助;(select code,descript from basecode where cat="cuscls1" order by sequence,code);code:代码;descript:描述=30',descript_sql ='select descript from basecode where cat="cuscls1" and code = "###"'  where item = 'class1';


insert into cmb_item (item,descript,descript1,sequence) values ('class2','类别2','Class2',610 );
	update cmb_item set helpable = 'T',sm = 'S',help='类别2帮助;(select code,descript from basecode where cat="cuscls2" order by sequence,code);code:代码;descript:描述=30',descript_sql ='select descript from basecode where cat="cuscls2" and code = "###"'  where item = 'class2';
insert into cmb_item (item,descript,descript1,sequence) values ('class3','类别3','Class3',620 );
	update cmb_item set helpable = 'T',sm = 'S',help='类别3帮助;(select code,descript from basecode where cat="cuscls3" order by sequence,code);code:代码;descript:描述=30',descript_sql ='select descript from basecode where cat="cuscls3" and code = "###"'  where item = 'class3';
insert into cmb_item (item,descript,descript1,sequence) values ('class4','类别4','Class4',630 );
	update cmb_item set helpable = 'T',sm = 'S',help='类别4帮助;(select code,descript from basecode where cat="cuscls4" order by sequence,code);code:代码;descript:描述=30',descript_sql ='select descript from basecode where cat="cuscls4" and code = "###"'  where item = 'class4';
insert into cmb_item (item,descript,descript1,sequence) values ('araccnt1','应收帐号1','Araccnt1',640 );
insert into cmb_item (item,descript,descript1,sequence) values ('araccnt2','应收帐号2','Araccnt2',650 );
insert into cmb_item (item,descript,descript1,sequence) values ('belong','归属','Belong',660 );
insert into cmb_item (item,descript,descript1,sequence) values ('liason','联系人','Contactor',670 );
insert into cmb_item (item,descript,descript1,sequence) values ('liason1','联系方式','Contact Menthod',680 );
insert into cmb_item (item,descript,descript1,sequence) values ('bank','开户银行','Bank',690 );
insert into cmb_item (item,descript,descript1,sequence) values ('bankno','银行帐号','Bank NO',700 );
insert into cmb_item (item,descript,descript1,sequence) values ('taxno','税号','Tax NO',710 );
insert into cmb_item (item,descript,descript1,sequence) values ('race','民族','Race',720 );
	update cmb_item set helpable = 'T',sm = 'S',help='民族帮助;(select code,descript from basecode where cat="race" order by sequence,code);code:代码;descript:描述=30',descript_sql ='select descript from basecode where cat="race" and code="###"'  where item = 'race';
insert into cmb_item (item,descript,descript1,sequence) values ('rjplace','入境口岸','Entry Port',730 );
	update cmb_item set helpable = 'T',sm = 'S',help='入境口岸帮助;(select code,descript from basecode where cat="rjcode" order by sequence);code:代码;descript:描述=30',descript_sql ='select descript from basecode where cat="rjcode" and code="###"'  where item = 'rjplace';
insert into cmb_item (item,descript,descript1,sequence) values ('type','客户类型','Class',740 );
	update cmb_item set helpable = 'T',sm = 'S',help='客户类型帮助;(select code,descript from basecode where cat="guest_type" order by sequence,code);code:代码;descript:描述=30',descript_sql ='select descript from basecode where cat="guest_type" and code="###"'  where item = 'type';
insert into cmb_item (item,descript,descript1,sequence) values ('blkcls','黑名单类别','Blacklist Sort',750 );
	update cmb_item set helpable = 'T',sm = 'S',help='黑名单类别帮助;(select code,descript from basecode where cat="blkcls" order by sequence,code);code:代码;descript:描述=30',descript_sql ='select descript from basecode where cat="blkcls" and code="###"'  where item = 'blkcls';
insert into cmb_item (item,descript,descript1,sequence) values ('blkdes','黑名单描述','Blacklist Des',760 );


update cmb_item set helpable = 'T',sm = 'S',help='代码帮助;(select hotelid,descript,descript1,city from hotelinfo order by hotelid);hotelid:ID;descript:描述1=20;descript1:描述2=20;city:城市=10'  where item = 'hotelid';
update cmb_item set helpable = 'T',sm = 'S',help='代码帮助;(select site,descript,descript1 from bos_site order by site);site:代码;descript:描述1;descript1:描述2'  where item = 'bos_site';
update cmb_item set helpable = 'T',sm = 'S',help='代码帮助;(select code,descript,descript1 from prvcode order by code);code:代码;descript:描述1;descript1:描述2'  where item = 'bos_pccode';
update cmb_item set helpable = 'T',sm = 'S',help='代码帮助;(select code,descript,descript1 from flrcode order by sequence, code);code:代码;descript:描述1;descript1:描述2'  where item = 'flr';
update cmb_item set helpable = 'T',sm = 'S',help='代码帮助;(select code,descript,descript1 from gtype order by sequence, code);code:代码;descript:描述1;descript1:描述2'  where item = 'gtype';
update cmb_item set helpable = 'T',sm = 'S',help='代码帮助;(select type,descript,descript1 from typim order by sequence, type);type:代码=4=[general]=alignment="0";descript:描述1;descript1:描述2'  where item = 'rmtype';
update cmb_item set helpable = 'T',sm = 'S',help='预订类型帮助;(select code,descript,descript1 from restype order by sequence);code:代码;descript:描述1;descript1:描述2'  where item = 'restype';
update cmb_item set helpable = 'T',sm = 'S',help='房价码帮助;(select code,descript,src,market,begin_,end_,private,packages from rmratecode where halt="F" order by sequence,code);code:代码;descript:描述=50;src:SRC;market:MKT;begin_:BEGIN=8=yy/mm/dd;end_:END=8=yy/mm/dd;private:Pri;packages:Package=12'  where item = 'restype';
update cmb_item set helpable = 'T',sm = 'S',help='POS 模式帮助;(select code,name1,name2,descript from pos_mode_name order by code);code:代码;name1:描述1=20;name2:描述2=20;descript:说明=40'  where item = 'pos_mode_name';
update cmb_item set helpable = 'T',sm = 'S',help='包价帮助;(select code,descript,descript1 from package order by code);code:代码;descript:描述1;descript1:描述2'  where item = 'package';
update cmb_item set helpable = 'T',sm = 'S',help='调整理由帮助;(select code,descript,descript1 from reason order by sequence,code);code:代码;descript:描述1;descript1:描述2'  where item = 'reason00';
update cmb_item set helpable = 'T',sm = 'S',help='优惠理由帮助;(select code,descript,p01 from reason where p01 > 0 order by sequence,code);code:代码;descript:描述;p01:比例=6=0%'  where item = 'rtreason';
update cmb_item set helpable = 'T',sm = 'S',help='款待理由帮助;(select code,descript,p90 from reason where p90 > 0 order by sequence,code);code:代码;descript:描述;p90:比例=6=0%'  where item = 'reason90';
update cmb_item set helpable = 'T',sm = 'S',help='账单编码帮助;(select argcode,descript,descript1 from argcode order by argcode);argcode:代码;descript:描述1;descript1:描述2'  where item = 'argcode';
update cmb_item set helpable = 'T',sm = 'S',help='营业项目代码帮助;(select pccode,descript,descript1 from pccode where halt="F" and pccode < "9" order by sequence,pccode);pccode:代码;descript:描述1;descript1:描述2'  where item = 'pccode_charge';
update cmb_item set helpable = 'T',sm = 'S',help='付款方式代码帮助;(select pccode,descript,descript1 from pccode where halt="F" and pccode > "9" order by sequence,pccode);pccode:代码;descript:描述1;descript1:描述2'  where item = 'pccode_credit';
update cmb_item set helpable = 'T',sm = 'S',help='外币代码帮助;(select code,descript,descript1 from fec_def order by code);code:代码;descript:描述1;descript1:描述2'  where item = 'fec_code';
update cmb_item set helpable = 'T',sm = 'S',help='用户代码帮助;(select empno,name from sys_empno order by empno);empno:用户名;name:姓名'  where item = 'empno';
update cmb_item set helpable = 'T',sm = 'S',help='系统应用代码帮助;(select code,descript,descript1 from appid order by code);code:代码;descript:描述1;descript1:描述2'  where item = 'appid';
update cmb_item set helpable = 'T',sm = 'S',help='佣金码帮助;(select code,descript,descript1 from cmscode where halt="F" order by sequence,code);code:代码;descript:描述1;descript1:描述2'  where item = 'cmscode';
update cmb_item set helpable = 'T',sm = 'S',help='代码帮助;(select a.accnt, b.name, b.name2 from master a, guest b where a.class="A" and a.sta="I" and a.haccnt=b.no order by a.accnt);a.accnt:账号;b.name:描述1=30;b.name2:描述2=30',descript_sql = 'select descript from basecode where cat="visaid" and code="###"' where item = 'armst';
