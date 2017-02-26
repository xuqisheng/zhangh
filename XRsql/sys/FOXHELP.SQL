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
	SELECT 'SA','Foxhis 帮助设置','Foxhis Help Set','hry','', 
	'select hlpkey,descript,descript1 from foxhelp order by hlpkey|||hlpkey:代码;descript:描述=12;descript1:English',
	'_com_Foxhis帮助设置;(select hlpkey,descript,descript1,hlpsyntax from foxhelp order by hlpkey);hlpkey:代码=10;descript:描述=16;descript1:描述2=16;hlpsyntax:语法=256',
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
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'armst','','',	'代码帮助;(select accnt,sno,sta,char60  =  substring(rtrim(name)+"("+rtrim(name2)+")",  1,  60),mone101  =  charge-credit,accredit,mone102  =  isnull((SELECT sum(b.amount) FROM accredit b,  pccode c WHERE armst.accnt=b.cardno and b.tag="0" and b.pccode=c.pccode and c.deptno2="TOR"),  0)  from armst order by accnt);accnt:账号=10;sno:编码=10;sta:状态=4;char60:名称=30;mone101:余额=9=0.00;accredit:信用=9=0.00;mone102:授权=9=0.00;mone109==(mone101-accredit+mone102):净额=9=0.00;finposaccnt;';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'hotelid','','','代码帮助;(select hotelid,descript,descript1,city from hotelinfo order by hotelid);hotelid:ID;descript:描述1=20;descript1:描述2=20;city:城市=10;findposhotelid;';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'nation', '','','代码帮助;(select code,descript,descript1,helpcode from countrycode order by sequence,code);code:代码;descript:描述1=20;descript1:描述2=20;helpcode:帮助码=10;findposcode;'
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'country','','','代码帮助;(select code,descript,descript1,helpcode from countrycode order by sequence,code);code:代码;descript:描述1=20;descript1:描述2=20;helpcode:帮助码=10;findposcode;'
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'bos_site','','','代码帮助;(select site,descript,descript1 from bos_site order by site);site:代码;descript:描述1;descript1:描述2;findpossite;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'bos_pccode','','','代码帮助;(select pccode,descript,descript1 from bos_pccode order by sequence,pccode);pccode:代码;descript:描述1;descript1:描述2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'prv', '','','代码帮助;(select code,descript,descript1 from prvcode order by code);code:代码;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'prvcode', '','','代码帮助;(select code,descript,descript1 from prvcode order by code);code:代码;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'state','','',	'代码帮助;(select code,descript,descript1 from prvcode order by code);code:代码;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'flr','','','代码帮助;(select code,descript,descript1 from flrcode order by sequence, code);code:代码;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'gtype','','',	'代码帮助;(select code,descript,descript1 from gtype order by sequence, code);code:代码;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'rmtype','','','代码帮助;(select type,descript,descript1 from typim order by sequence, type);type:代码=4=[general]=alignment="0";descript:描述1;descript1:描述2;findpostype;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'market_tv','','','win=w_gds_tree_help;arg=market;%1';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'market','','', '市场代码帮助;(select code,descript,grp from mktcode order by sequence);code:代码;descript:描述;grp:分组;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'src_tv','','','win=w_gds_tree_help;arg=source;%1';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'src','','','宾客来源帮助;(select code,descript,grp from srccode order by sequence);code:代码;descript:描述;grp:分组;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'restype','','','预订类型帮助;(select code,descript,descript1 from restype order by sequence);code:代码;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'rmratecode' ,'','','房价码帮助;(select code,descript,src,market,begin_,end_,private,packages from rmratecode where halt="F" order by sequence,code);code:代码;descript:描述=50;src:SRC;market:MKT;begin_:BEGIN=8=yy/mm/dd;end_:END=8=yy/mm/dd;private:Pri;packages:Package=12;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pos_mode_name','','',	'POS 模式帮助;(select code,name1,name2,descript from pos_mode_name order by code);code:代码;name1:描述1=20;name2:描述2=20;descript:说明=40;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'package','','','包价帮助;(select code,descript,descript1 from package order by code);code:代码;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'packages','','','包价帮助;(select code,descript,descript1 from package order by code);code:代码;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'saleid','','','销售员帮助;(select code,descript,descript1 from saleid order by code);code:代码;descript:姓名;descript1:英文名;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'reason00','','','调整理由帮助;(select code,descript,descript1 from reason order by sequence,code);code:代码;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'rtreason','','','优惠理由帮助;(select code,descript,p01 from reason where p01 > 0 order by sequence,code);code:代码;descript:描述;p01:比例=6=0%;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'reason01','','',	'优惠理由帮助;(select code,descript,p01 from reason where p01 > 0 order by sequence,code);code:代码;descript:描述;p01:比例=6=0%;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'reason90','','','款待理由帮助;(select code,descript,p90 from reason where p90 > 0 order by sequence,code);code:代码;descript:描述;p90:比例=6=0%;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'srqs','','','特殊要求帮助;(select code,descript,descript1 from reqcode order by sequence);code:代码=3;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'argcode','','','账单编码帮助;(select argcode,descript,descript1 from argcode order by argcode);argcode:代码;descript:描述1;descript1:描述2;findposargcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccode_charge', '', '','营业项目代码帮助;(select pccode,descript,descript1 from pccode where halt="F" and pccode < "9" order by sequence,pccode);pccode:代码;descript:描述1;descript1:描述2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccode_charge1', '', '','营业项目代码帮助;(select pccode,descript,descript1 from pccode where halt="F" and pccode < "9" order by sequence,pccode);pccode:代码;descript:描述1;descript1:描述2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccode_charge2', '', '','营业项目代码帮助;(select pccode,descript,descript1 from pccode where halt="F" and pccode < "9" order by sequence,pccode);pccode:代码;descript:描述1;descript1:描述2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccode_credit', '', '','付款方式代码帮助;(select pccode,descript,descript1 from pccode where halt="F" and pccode > "9" order by sequence,pccode);pccode:代码;descript:描述1;descript1:描述2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccode_credit1', '', '','付款方式代码帮助;(select pccode,descript,descript1 from pccode where halt="F" and pccode > "9" order by sequence,pccode);pccode:代码;descript:描述1;descript1:描述2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccode_credit2', '', '','付款方式代码帮助;(select pccode,descript,descript1 from pccode where halt="F" and pccode > "9" order by sequence,pccode);pccode:代码;descript:描述1;descript1:描述2;findpospccode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'pccodes','','','win=w_gl_accnt_pccodes_help;';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'fec_code','','','外币代码帮助;(select code,descript,descript1 from fec_def order by code);code:代码;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'empno','','',	'用户代码帮助;(select empno,name from sys_empno order by empno);empno:用户名;name:姓名;findposempno;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'appid','','','系统应用代码帮助;(select code,descript,descript1 from appid order by code);code:代码;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'cmscode','','','佣金码帮助;(select code,descript,descript1 from cmscode where halt="F" order by sequence,code);code:代码;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'gdsnewcity','','','城市帮助;(select a.code,a.descript,a.descript1,b.descript1,c.descript1 from cntcode a, prvcode b,countrycode c where a.country=c.code and a.prv=b.code order by a.code);a.code:代码;a.descript:中文描述=20;a.descript1:英文描述=30;b.descript1:省=10;c.descript1:国家=10;findposa.code;';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'auto_dept','','','win=w_gds_auto_dept_list;';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char10_araccnt','','','win=w_hry_acct_for_accnt;arg=%1;A;V' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char03_floor','','','楼层代码帮助;(select code,descript,descript1 from flrcode order by code);code:代码=3;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char10_groupno','','','团体账号帮助;(select a.accnt,b.name,b.name2 from master a,guest b where a.class in ("G","M") and a.haccnt=b.no order by a.accnt);a.accnt:账号;b.name:名称=24;b.name2:名称2=24;findposa.accnt;';
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char03_pos_mode','','','餐饮模式帮助;(select code,name1,descript from pos_mode_name order by code);code:代码=3;name1:名称;descript:描述;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char05_pos_pccode','','',	'餐饮项目代码帮助;(select chgcod,descript,descript1 from pos_pccode order by chgcod);chgcod:代码;descript:描述1;descript1:描述2;findposchgcod;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char99_floors','','','楼层代码帮助;(select code,descript,descript1 from flrcode order by code);code:代码=3;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'char03_srq','','','特殊要求帮助;(select code,descript,descript1 from reqcode order by sequence);code:代码=3;descript:描述1;descript1:描述2;findposcode;' ;
insert into foxhelp(hlpkey,descript,descript1,hlpsyntax) select  'msgraph_y','','','数值列帮助;(select code_des,grp_des from pmktsummaryrep where pc_id = "#pc_id#" order by code_seq);code_des:列名=16;grp_des:描述=16;findposcode;' ;


