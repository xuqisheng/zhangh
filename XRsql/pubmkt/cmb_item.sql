
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
 sm				char(1) 			default 'S' 	null, --������ѡS,��ѡM
 descript_sql 	varchar(255) 						null,
 halt 			char(1) default 'F' 				null, --ͣ��
);
exec sp_primarykey cmb_item, item ;
create unique index index1 on cmb_item(item);


--insert into cmb_item (item,descript,descript1,sequence) values ('no','������',10 )
insert into cmb_item (item,descript,descript1,sequence) values ('sta','״̬' ,'Status',30)
insert into cmb_item (item,descript,descript1,sequence) values ('name','����','Name', 20)
insert into cmb_item (item,descript,descript1,sequence) values ('lname','��' ,'Family Name',40)
insert into cmb_item (item,descript,descript1,sequence) values ('fname','��' ,'First Name',50)
insert into cmb_item (item,descript,descript1,sequence) values ('name2','����2','Name2',60 )
insert into cmb_item (item,descript,descript1,sequence) values ('sno','���' ,'NO',70)
insert into cmb_item (item,descript,descript1,sequence) values ('vip','Vip','Vip' ,80)
	update cmb_item set helpable = 'T',sm = 'S',help='VIP����;(select code,descript from basecode where cat="vip" order by sequence,code);code:����;descript:����=40',descript_sql ='select descript from basecode where cat="vip" and code = "###"'  where item = 'vip';

insert into cmb_item (item,descript,descript1,sequence) values ('sex','�Ա�','Gender' ,90)
	update cmb_item set helpable = 'T',sm = 'S',help='�Ա����;(select code,descript from basecode where cat="sex" order by sequence,code);code:����;descript:����=40',descript_sql ='select descript from basecode where cat="sex" and code = "###"'  where item = 'sex';
insert into cmb_item (item,descript,descript1,sequence) values ('birth','����' ,'Birthday',100)
insert into cmb_item (item,descript,descript1,sequence) values ('lang','����' ,'Language',110)
	update cmb_item set helpable = 'T',sm = 'S',help='���ְ���;(select code,descript from basecode where cat="language" order by sequence,code);code:����;descript:����=40',descript_sql ='select descript from basecode where cat="language" and code = "###"'  where item = 'lang';

insert into cmb_item (item,descript,descript1,sequence) values ('title','��ν','Title' ,120)
insert into cmb_item (item,descript,descript1,sequence) values ('city','����' ,'Recidence',130)
	update cmb_item set helpable = 'T',sm = 'S',help='�������;(select code,descript from cntcode order by code);code:����;descript:����',descript_sql ='select descript from cntcode where code="###"'  where item = 'city';


insert into cmb_item (item,descript,descript1,sequence) values ('salutation','�ƺ�' ,'Salutation',140)
insert into cmb_item (item,descript,descript1,sequence) values ('cusno','��λ��' ,'Comp.NO',150)
insert into cmb_item (item,descript,descript1,sequence) values ('unit','��λ' ,'Company',160)
insert into cmb_item (item,descript,descript1,sequence) values ('cno','ְҵ' ,'Occupation',170)
insert into cmb_item (item,descript,descript1,sequence) values ('saleid','����Ա','saler',180 )
	update cmb_item set helpable = 'T',sm = 'S',help='����Ա����;(select code,descript,descript1 from saleid order by code);code:����;descript:����;descript1:Ӣ����'  where item = 'saleid';
insert into cmb_item (item,descript,descript1,sequence) values ('master','���ʺ�','Master.NO' ,190)
--insert into cmb_item (item,descript,descript1,sequence) values ('hotelid','Hotel ID' ,200)
insert into cmb_item (item,descript,descript1,sequence) values ('central','���ŵ�������','Cent.Profile NO',210)
insert into cmb_item (item,descript,descript1,sequence) values ('censeq','���','Cent.Senquence' ,220)
insert into cmb_item (item,descript,descript1,sequence) values ('keep','�����ʷ','Keep' ,230)
insert into cmb_item (item,descript,descript1,sequence) values ('override','���޶��','Override' ,240)
insert into cmb_item (item,descript,descript1,sequence) values ('street','�ֵ�' ,'Street',250)
insert into cmb_item (item,descript,descript1,sequence) values ('zip','�ʱ�' ,'Zipcode',260)
insert into cmb_item (item,descript,descript1,sequence) values ('town','����' ,'Town',270)
insert into cmb_item (item,descript,descript1,sequence) values ('country','����' ,'Country',270)
	update cmb_item set helpable = 'T',sm = 'S',help='�������;(select code,descript,descript1,helpcode from countrycode order by sequence,code);code:����;descript:����1=20;descript1:����2=20;helpcode:������=10',descript_sql = "select descript from countrycode where code = '###'" where item = 'country';
insert into cmb_item (item,descript,descript1,sequence) values ('state','ʡ/��','State',290)
	update cmb_item set helpable = 'T',sm = 'S',help='ʡ/�ݰ���;(select code,descript from prvcode order by sequence,code);code:����;descript:����',descript_sql ='select descript from prvcode where code="###" '  where item = 'state';

insert into cmb_item (item,descript,descript1,sequence) values ('mobile','�ֻ�' ,'Mobile',300)
insert into cmb_item (item,descript,descript1,sequence) values ('phone','�绰' ,'Phone',310)
insert into cmb_item (item,descript,descript1,sequence) values ('fax','����','Fax',320)
insert into cmb_item (item,descript,descript1,sequence) values ('email','Email' ,'Email',330)
insert into cmb_item (item,descript,descript1,sequence) values ('idcls','֤������','ID Type',340)
	update cmb_item set helpable = 'T',sm = 'S',help='֤������;(select code,descript from basecode where cat="idcode" order by sequence,code);code:����;descript:����',descript_sql ='select descript from basecode where cat="idcode" and code = "###"'  where item = 'idcls';



insert into cmb_item (item,descript,descript1,sequence) values ('nation','����' ,'Nation',350)
	update cmb_item set helpable = 'T',sm = 'S',help='�������;(select code,descript,descript1,helpcode from countrycode order by sequence,code);code:����;descript:����1=20;descript1:����2=20;helpcode:������=10',descript_sql = "select descript from countrycode where code = '###'" where item = 'nation';

insert into cmb_item (item,descript,descript1,sequence) values ('visaid','ǩ֤����','Visa Type' ,360)
	update cmb_item set helpable = 'T',sm = 'S',help='ǩ֤����;(select code,descript from basecode where cat="visaid" order by sequence,code);code:����;descript:����=30',descript_sql ='select descript from basecode where cat="visaid" and code = "###"'  where item = 'visaid';

insert into cmb_item (item,descript,descript1,sequence) values ('visano','ǩ֤����','Visa NO',370)
insert into cmb_item (item,descript,descript1,sequence) values ('visaend','ǩ֤��Ч��','Visa Validity',380)
insert into cmb_item (item,descript,descript1,sequence) values ('street1','�ֵ�2','Street1',390)
insert into cmb_item (item,descript,descript1,sequence) values ('zip1','�ʱ�2','Zipcode1',400)
insert into cmb_item (item,descript,descript1,sequence) values ('town1','����2' ,'Town1',410)
insert into cmb_item (item,descript,descript1,sequence) values ('country1','����' ,'Country1',420)
	update cmb_item set helpable = 'T',sm = 'S',help='�������;(select code,descript,descript1,helpcode from countrycode order by sequence,code);code:����;descript:����1=20;descript1:����2=20;helpcode:������=10',descript_sql = "select descript from countrycode where code = '###'" where item = 'country1';

insert into cmb_item (item,descript,descript1,sequence) values ('state1','ʡ/��2','State1' ,430)
	update cmb_item set helpable = 'T',sm = 'S',help='ʡ/�ݰ���;(select code,descript from prvcode order by sequence,code);code:����;descript:����',descript_sql ='select descript from prvcode where code="###" '  where item = 'state1';

insert into cmb_item (item,descript,descript1,sequence) values ('mobile1','�ֻ�2','Mobile1' ,440)
insert into cmb_item (item,descript,descript1,sequence) values ('phone1','�绰2','Phone1' ,450)
insert into cmb_item (item,descript,descript1,sequence) values ('fax1','����2','Fax1' ,460)
insert into cmb_item (item,descript,descript1,sequence) values ('email1','Email2','Email2',470 );
insert into cmb_item (item,descript,descript1,sequence) values ('srqs','����Ҫ��','Specials',480 );
	update cmb_item set helpable = 'T',sm = 'M',help='����Ҫ�����;(select code,descript,descript1 from reqcode order by sequence);code:����=3;descript:����1;descript1:����2',descript_sql = "" where item = 'srqs';

insert into cmb_item (item,descript,descript1,sequence) values ('interest','��Ȥ����','Interest',490 );
	update cmb_item set helpable = 'T',sm = 'M',help='��Ȥ���ð���;(select code,descript,descript1 from basecode where cat="interest" order by sequence);code:����;descript:����1=30;descript1:����2=30',descript_sql = "" where item = 'interest';

insert into cmb_item (item,descript,descript1,sequence) values ('rmpref','����ƫ��','Room Preferred',500 );
insert into cmb_item (item,descript,descript1,sequence) values ('feature','�ŷ�Ҫ��','Feature',510 );
insert into cmb_item (item,descript,descript1,sequence) values ('extrainf','������Ϣ','Extra Info',520 );
insert into cmb_item (item,descript,descript1,sequence) values ('refer1','ǰ̨ϲ��','Refer1',530 );
insert into cmb_item (item,descript,descript1,sequence) values ('refer2','����ϲ��','Refer2',540 );
insert into cmb_item (item,descript,descript1,sequence) values ('comment','˵��','Comment',550 );
insert into cmb_item (item,descript,descript1,sequence) values ('remark','��ע','Remark',560 );
insert into cmb_item (item,descript,descript1,sequence) values ('src','��Դ','Source',570 );
	update cmb_item set helpable = 'T',sm = 'S',help='��Դ����;(select code,descript from srccode order by sequence);code:����;descript:����',descript_sql ='select descript from srccode where code = "###"'  where item = 'src';
insert into cmb_item (item,descript,descript1,sequence) values ('market','�г�','Market',580 );
	update cmb_item set helpable = 'T',sm = 'S',help='�г��������;(select code,descript from mktcode order by sequence);code:����;descript:����',descript_sql ='select descript from mktcode where code = "###"'  where item = 'market';
insert into cmb_item (item,descript,descript1,sequence) values ('latency','Ǳ�ڿͻ�','Latency',590 );
	update cmb_item set helpable = 'T',sm = 'S',help='Ǳ�ڿͻ�����;(select code,descript from basecode where cat="latency" order by sequence,code);code:����;descript:����=30',descript_sql ='select descript from basecode where cat="latency" and code = "###"'  where item = 'latency';
insert into cmb_item (item,descript,descript1,sequence) values ('class1','���1','Class1',600 );
	update cmb_item set helpable = 'T',sm = 'S',help='���1����;(select code,descript from basecode where cat="cuscls1" order by sequence,code);code:����;descript:����=30',descript_sql ='select descript from basecode where cat="cuscls1" and code = "###"'  where item = 'class1';


insert into cmb_item (item,descript,descript1,sequence) values ('class2','���2','Class2',610 );
	update cmb_item set helpable = 'T',sm = 'S',help='���2����;(select code,descript from basecode where cat="cuscls2" order by sequence,code);code:����;descript:����=30',descript_sql ='select descript from basecode where cat="cuscls2" and code = "###"'  where item = 'class2';
insert into cmb_item (item,descript,descript1,sequence) values ('class3','���3','Class3',620 );
	update cmb_item set helpable = 'T',sm = 'S',help='���3����;(select code,descript from basecode where cat="cuscls3" order by sequence,code);code:����;descript:����=30',descript_sql ='select descript from basecode where cat="cuscls3" and code = "###"'  where item = 'class3';
insert into cmb_item (item,descript,descript1,sequence) values ('class4','���4','Class4',630 );
	update cmb_item set helpable = 'T',sm = 'S',help='���4����;(select code,descript from basecode where cat="cuscls4" order by sequence,code);code:����;descript:����=30',descript_sql ='select descript from basecode where cat="cuscls4" and code = "###"'  where item = 'class4';
insert into cmb_item (item,descript,descript1,sequence) values ('araccnt1','Ӧ���ʺ�1','Araccnt1',640 );
insert into cmb_item (item,descript,descript1,sequence) values ('araccnt2','Ӧ���ʺ�2','Araccnt2',650 );
insert into cmb_item (item,descript,descript1,sequence) values ('belong','����','Belong',660 );
insert into cmb_item (item,descript,descript1,sequence) values ('liason','��ϵ��','Contactor',670 );
insert into cmb_item (item,descript,descript1,sequence) values ('liason1','��ϵ��ʽ','Contact Menthod',680 );
insert into cmb_item (item,descript,descript1,sequence) values ('bank','��������','Bank',690 );
insert into cmb_item (item,descript,descript1,sequence) values ('bankno','�����ʺ�','Bank NO',700 );
insert into cmb_item (item,descript,descript1,sequence) values ('taxno','˰��','Tax NO',710 );
insert into cmb_item (item,descript,descript1,sequence) values ('race','����','Race',720 );
	update cmb_item set helpable = 'T',sm = 'S',help='�������;(select code,descript from basecode where cat="race" order by sequence,code);code:����;descript:����=30',descript_sql ='select descript from basecode where cat="race" and code="###"'  where item = 'race';
insert into cmb_item (item,descript,descript1,sequence) values ('rjplace','�뾳�ڰ�','Entry Port',730 );
	update cmb_item set helpable = 'T',sm = 'S',help='�뾳�ڰ�����;(select code,descript from basecode where cat="rjcode" order by sequence);code:����;descript:����=30',descript_sql ='select descript from basecode where cat="rjcode" and code="###"'  where item = 'rjplace';
insert into cmb_item (item,descript,descript1,sequence) values ('type','�ͻ�����','Class',740 );
	update cmb_item set helpable = 'T',sm = 'S',help='�ͻ����Ͱ���;(select code,descript from basecode where cat="guest_type" order by sequence,code);code:����;descript:����=30',descript_sql ='select descript from basecode where cat="guest_type" and code="###"'  where item = 'type';
insert into cmb_item (item,descript,descript1,sequence) values ('blkcls','���������','Blacklist Sort',750 );
	update cmb_item set helpable = 'T',sm = 'S',help='������������;(select code,descript from basecode where cat="blkcls" order by sequence,code);code:����;descript:����=30',descript_sql ='select descript from basecode where cat="blkcls" and code="###"'  where item = 'blkcls';
insert into cmb_item (item,descript,descript1,sequence) values ('blkdes','����������','Blacklist Des',760 );


update cmb_item set helpable = 'T',sm = 'S',help='�������;(select hotelid,descript,descript1,city from hotelinfo order by hotelid);hotelid:ID;descript:����1=20;descript1:����2=20;city:����=10'  where item = 'hotelid';
update cmb_item set helpable = 'T',sm = 'S',help='�������;(select site,descript,descript1 from bos_site order by site);site:����;descript:����1;descript1:����2'  where item = 'bos_site';
update cmb_item set helpable = 'T',sm = 'S',help='�������;(select code,descript,descript1 from prvcode order by code);code:����;descript:����1;descript1:����2'  where item = 'bos_pccode';
update cmb_item set helpable = 'T',sm = 'S',help='�������;(select code,descript,descript1 from flrcode order by sequence, code);code:����;descript:����1;descript1:����2'  where item = 'flr';
update cmb_item set helpable = 'T',sm = 'S',help='�������;(select code,descript,descript1 from gtype order by sequence, code);code:����;descript:����1;descript1:����2'  where item = 'gtype';
update cmb_item set helpable = 'T',sm = 'S',help='�������;(select type,descript,descript1 from typim order by sequence, type);type:����=4=[general]=alignment="0";descript:����1;descript1:����2'  where item = 'rmtype';
update cmb_item set helpable = 'T',sm = 'S',help='Ԥ�����Ͱ���;(select code,descript,descript1 from restype order by sequence);code:����;descript:����1;descript1:����2'  where item = 'restype';
update cmb_item set helpable = 'T',sm = 'S',help='���������;(select code,descript,src,market,begin_,end_,private,packages from rmratecode where halt="F" order by sequence,code);code:����;descript:����=50;src:SRC;market:MKT;begin_:BEGIN=8=yy/mm/dd;end_:END=8=yy/mm/dd;private:Pri;packages:Package=12'  where item = 'restype';
update cmb_item set helpable = 'T',sm = 'S',help='POS ģʽ����;(select code,name1,name2,descript from pos_mode_name order by code);code:����;name1:����1=20;name2:����2=20;descript:˵��=40'  where item = 'pos_mode_name';
update cmb_item set helpable = 'T',sm = 'S',help='���۰���;(select code,descript,descript1 from package order by code);code:����;descript:����1;descript1:����2'  where item = 'package';
update cmb_item set helpable = 'T',sm = 'S',help='�������ɰ���;(select code,descript,descript1 from reason order by sequence,code);code:����;descript:����1;descript1:����2'  where item = 'reason00';
update cmb_item set helpable = 'T',sm = 'S',help='�Ż����ɰ���;(select code,descript,p01 from reason where p01 > 0 order by sequence,code);code:����;descript:����;p01:����=6=0%'  where item = 'rtreason';
update cmb_item set helpable = 'T',sm = 'S',help='������ɰ���;(select code,descript,p90 from reason where p90 > 0 order by sequence,code);code:����;descript:����;p90:����=6=0%'  where item = 'reason90';
update cmb_item set helpable = 'T',sm = 'S',help='�˵��������;(select argcode,descript,descript1 from argcode order by argcode);argcode:����;descript:����1;descript1:����2'  where item = 'argcode';
update cmb_item set helpable = 'T',sm = 'S',help='Ӫҵ��Ŀ�������;(select pccode,descript,descript1 from pccode where halt="F" and pccode < "9" order by sequence,pccode);pccode:����;descript:����1;descript1:����2'  where item = 'pccode_charge';
update cmb_item set helpable = 'T',sm = 'S',help='���ʽ�������;(select pccode,descript,descript1 from pccode where halt="F" and pccode > "9" order by sequence,pccode);pccode:����;descript:����1;descript1:����2'  where item = 'pccode_credit';
update cmb_item set helpable = 'T',sm = 'S',help='��Ҵ������;(select code,descript,descript1 from fec_def order by code);code:����;descript:����1;descript1:����2'  where item = 'fec_code';
update cmb_item set helpable = 'T',sm = 'S',help='�û��������;(select empno,name from sys_empno order by empno);empno:�û���;name:����'  where item = 'empno';
update cmb_item set helpable = 'T',sm = 'S',help='ϵͳӦ�ô������;(select code,descript,descript1 from appid order by code);code:����;descript:����1;descript1:����2'  where item = 'appid';
update cmb_item set helpable = 'T',sm = 'S',help='Ӷ�������;(select code,descript,descript1 from cmscode where halt="F" order by sequence,code);code:����;descript:����1;descript1:����2'  where item = 'cmscode';
update cmb_item set helpable = 'T',sm = 'S',help='�������;(select a.accnt, b.name, b.name2 from master a, guest b where a.class="A" and a.sta="I" and a.haccnt=b.no order by a.accnt);a.accnt:�˺�;b.name:����1=30;b.name2:����2=30',descript_sql = 'select descript from basecode where cat="visaid" and code="###"' where item = 'armst';
