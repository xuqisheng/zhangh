-------------------------------------------------------------------------------------------
-- foxhelp
-------------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'foxhelp' and type ='U')
	drop table foxhelp
;
create table foxhelp (
	hlpkey			varchar(32)						not null, 
	descript    	varchar(30)		default ''	not null,
	descript1   	varchar(30)		default ''	not null,
	hlpsyntax		text				default ''	not null 
)
;
exec sp_primarykey foxhelp,hlpkey
create unique index index1 on foxhelp(hlpkey)
;

-------------------------------------------------------------------------------------------
-- maint
-------------------------------------------------------------------------------------------
INSERT INTO syscode_maint ( code,descript,descript1,wtype,auth,show,source,parm ) 
	SELECT 'SA','Foxhis ��������','Foxhis Help Set','hry','', 
	'select hlpkey,descript,descript1 from foxhelp order by hlpkey|||hlpkey:����;descript:����=12;descript1:English',
	'_com_Foxhis��������;(select hlpkey,descript,descript1,hlpsyntax from foxhelp order by hlpkey);hlpkey:����=10;descript:����=16;descript1:����2=16;hlpsyntax:�﷨=256',
	'';

 
-------------------------------------------------------------------------------------------
-- data
-------------------------------------------------------------------------------------------
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'birthplace', '', '', 'win=w_gl_reserve_region_help;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'whereto',  '', '', 'win=w_gl_reserve_region_help;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'wherefrom', '', '', 'win=w_gl_reserve_region_help;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'city',  '', '', 'win=w_gl_reserve_region_help;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'cusno', '', '','win=w_gds_reserve_search_guest;arg=FIXC%1' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'agent', '', '','win=w_gds_reserve_search_guest;arg=FIXA%1' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'source', '', '','win=w_gds_reserve_search_guest;arg=FIXS%1' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'haccnt', '', '','win=w_gds_reserve_search_guest;arg=FIXF%1' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'unit', '', '','win=w_gds_reserve_search_guest;arg=CAS%1' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'guest', '', '','win=w_gds_reserve_search_guest;arg=FGCAS%1' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'armst','','',	'�������;(select accnt,sno,sta,char60  =  substring(rtrim(name)+"("+rtrim(name2)+")",  1,  60),mone101  =  charge-credit,accredit,mone102  =  isnull((SELECT sum(b.amount) FROM accredit b,  pccode c WHERE armst.accnt=b.cardno and b.tag="0" and b.pccode=c.pccode and c.deptno2="TOR"),  0)  from armst order by accnt);accnt:�˺�=10;sno:����=10;sta:״̬=4;char60:����=30;mone101:���=9=0.00;accredit:����=9=0.00;mone102:��Ȩ=9=0.00;mone109==(mone101-accredit+mone102):����=9=0.00;finposaccnt;';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'hotelid','','','�������;(select hotelid,descript,descript1,city from hotelinfo order by hotelid);hotelid:ID;descript:����1=20;descript1:����2=20;city:����=10;findposhotelid;';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'nation', '','','�������;(select code,descript,descript1,helpcode from countrycode order by sequence,code);code:����;descript:����1=20;descript1:����2=20;helpcode:������=10;findposcode;'
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'country','','','�������;(select code,descript,descript1,helpcode from countrycode order by sequence,code);code:����;descript:����1=20;descript1:����2=20;helpcode:������=10;findposcode;'
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'bos_site','','','�������;(select site,descript,descript1 from bos_site order by site);site:����;descript:����1;descript1:����2;findpossite;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'bos_pccode','','','�������;(select pccode,descript,descript1 from bos_pccode order by sequence,pccode);pccode:����;descript:����1;descript1:����2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'prv', '','','�������;(select code,descript,descript1 from prvcode order by code);code:����;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'prvcode', '','','�������;(select code,descript,descript1 from prvcode order by code);code:����;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'state','','',	'�������;(select code,descript,descript1 from prvcode order by code);code:����;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'flr','','','�������;(select code,descript,descript1 from flrcode order by sequence, code);code:����;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'gtype','','',	'�������;(select code,descript,descript1 from gtype order by sequence, code);code:����;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'rmtype','','','�������;(select type,descript,descript1 from typim order by sequence, type);type:����=4=[general]=alignment="0";descript:����1;descript1:����2;findpostype;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'market_tv','','','win=w_gds_tree_help;arg=market;%1';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'market','','', '�г��������;(select code,descript,grp from mktcode order by sequence);code:����;descript:����;grp:����;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'src_tv','','','win=w_gds_tree_help;arg=source;%1';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'src','','','������Դ����;(select code,descript,grp from srccode order by sequence);code:����;descript:����;grp:����;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'restype','','','Ԥ�����Ͱ���;(select code,descript,descript1 from restype order by sequence);code:����;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'rmratecode' ,'','','���������;(select code,descript,src,market,begin_,end_,private,packages from rmratecode where halt="F" order by sequence,code);code:����;descript:����=50;src:SRC;market:MKT;begin_:BEGIN=8=yy/mm/dd;end_:END=8=yy/mm/dd;private:Pri;packages:Package=12;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pos_mode_name','','',	'POS ģʽ����;(select code,name1,name2,descript from pos_mode_name order by code);code:����;name1:����1=20;name2:����2=20;descript:˵��=40;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'package','','','���۰���;(select code,descript,descript1 from package order by code);code:����;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'packages','','','���۰���;(select code,descript,descript1 from package order by code);code:����;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'saleid','','','����Ա����;(select code,descript,descript1 from saleid order by code);code:����;descript:����;descript1:Ӣ����;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'reason00','','','�������ɰ���;(select code,descript,descript1 from reason order by sequence,code);code:����;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'rtreason','','','�Ż����ɰ���;(select code,descript,p01 from reason where p01 > 0 order by sequence,code);code:����;descript:����;p01:����=6=0%;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'reason01','','',	'�Ż����ɰ���;(select code,descript,p01 from reason where p01 > 0 order by sequence,code);code:����;descript:����;p01:����=6=0%;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'reason90','','','������ɰ���;(select code,descript,p90 from reason where p90 > 0 order by sequence,code);code:����;descript:����;p90:����=6=0%;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'srqs','','','����Ҫ�����;(select code,descript,descript1 from reqcode order by sequence);code:����=3;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'argcode','','','�˵��������;(select argcode,descript,descript1 from argcode order by argcode);argcode:����;descript:����1;descript1:����2;findposargcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccode_charge', '', '','Ӫҵ��Ŀ�������;(select pccode,descript,descript1 from pccode where halt="F" and pccode < "9" order by sequence,pccode);pccode:����;descript:����1;descript1:����2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccode_charge1', '', '','Ӫҵ��Ŀ�������;(select pccode,descript,descript1 from pccode where halt="F" and pccode < "9" order by sequence,pccode);pccode:����;descript:����1;descript1:����2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccode_charge2', '', '','Ӫҵ��Ŀ�������;(select pccode,descript,descript1 from pccode where halt="F" and pccode < "9" order by sequence,pccode);pccode:����;descript:����1;descript1:����2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccode_credit', '', '','���ʽ�������;(select pccode,descript,descript1 from pccode where halt="F" and pccode > "9" order by sequence,pccode);pccode:����;descript:����1;descript1:����2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccode_credit1', '', '','���ʽ�������;(select pccode,descript,descript1 from pccode where halt="F" and pccode > "9" order by sequence,pccode);pccode:����;descript:����1;descript1:����2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccode_credit2', '', '','���ʽ�������;(select pccode,descript,descript1 from pccode where halt="F" and pccode > "9" order by sequence,pccode);pccode:����;descript:����1;descript1:����2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccodes','','','win=w_gl_accnt_pccodes_help;';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'fec_code','','','��Ҵ������;(select code,descript,descript1 from fec_def order by code);code:����;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'empno','','',	'�û��������;(select empno,name from sys_empno order by empno);empno:�û���;name:����;findposempno;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'appid','','','ϵͳӦ�ô������;(select code,descript,descript1 from appid order by code);code:����;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'cmscode','','','Ӷ�������;(select code,descript,descript1 from cmscode where halt="F" order by sequence,code);code:����;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'gdsnewcity','','','���а���;(select a.code,a.descript,a.descript1,b.descript1,c.descript1 from cntcode a, prvcode b,countrycode c where a.country=c.code and a.prv=b.code order by a.code);a.code:����;a.descript:��������=20;a.descript1:Ӣ������=30;b.descript1:ʡ=10;c.descript1:����=10;findposa.code;';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'auto_dept','','','win=w_gds_auto_dept_list;';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char10_araccnt','','','win=w_hry_acct_for_accnt;arg=%1;A;V' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char03_floor','','','¥��������;(select code,descript,descript1 from flrcode order by code);code:����=3;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char10_groupno','','','�����˺Ű���;(select a.accnt,b.name,b.name2 from master a,guest b where a.class in ("G","M") and a.haccnt=b.no order by a.accnt);a.accnt:�˺�;b.name:����=24;b.name2:����2=24;findposa.accnt;';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char03_pos_mode','','','����ģʽ����;(select code,name1,descript from pos_mode_name order by code);code:����=3;name1:����;descript:����;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char05_pos_pccode','','',	'������Ŀ�������;(select chgcod,descript,descript1 from pos_pccode order by chgcod);chgcod:����;descript:����1;descript1:����2;findposchgcod;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char99_floors','','','¥��������;(select code,descript,descript1 from flrcode order by code);code:����=3;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char03_srq','','','����Ҫ�����;(select code,descript,descript1 from reqcode order by sequence);code:����=3;descript:����1;descript1:����2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'msgraph_y','','','��ֵ�а���;(select code_des,grp_des from pmktsummaryrep where pc_id = "#pc_id#" order by code_seq);code_des:����=16;grp_des:����=16;findposcode;' ;


