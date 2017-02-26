-- ------------------------------------------------------------------------------
-- plan �ƻ�  
--                       simon 2006.8.8 
-- ------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------
-- ����
--  1. plan_cat �е���Ŀ���� planitem ����Ҫ������ı������ 
--  2. plan_code �����û�б�Ҫ��������ʱ��ֱ�Ӵ���ش������ȡ
-- ------------------------------------------------------------------------------


-- --------------------------------------
--  basecode : plan_period  �ƻ����䶨��
-- --------------------------------------
delete basecode where cat='plan_period';
delete basecode_cat where cat='plan_period';
insert basecode_cat(cat,descript,descript1,len,flag,center) 
	select 'plan_period', '�ƻ����䶨��', 'Plan Period', 1, '', 'F';
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'Y', '��', 'Year', 100);
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'S', '����', 'Season', 200);
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'M', '��', 'Month', 300);
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'H', '����', 'Half Month', 400);
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'X', 'Ѯ', 'Ten Days', 500);
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'W', '����', 'Week', 600);
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'D', '��', 'Day', 700);
select * from basecode where cat='plan_period' order by sequence, code ;


-- --------------------------------------
--  basecode : plan_type  �ƻ������
-- --------------------------------------
delete basecode where cat='plan_type';
delete basecode_cat where cat='plan_type';
insert basecode_cat(cat,descript,descript1,len,flag,center) 
	select 'plan_type', '�ƻ������', 'Plan Type', 1, '', 'F';
insert basecode(cat,code,descript,descript1,sequence) values('plan_type', 'B', 'Ԥ��', 'budget', 100);
-- insert basecode(cat,code,descript,descript1,sequence) values('plan_type', 'F', 'Ԥ��', 'Forecast', 200);
select * from basecode where cat='plan_type' order by sequence, code ;


-- -----------------------------------------------------------
--  basecode : plan_who  �ƻ������ -- �� plan_who����� 
-- -----------------------------------------------------------
delete basecode where cat='plan_who';
delete basecode_cat where cat='plan_who';
//insert basecode_cat(cat,descript,descript1,len,flag,center) 
//	select 'plan_who', '�ƻ������', 'Whose Plan', 10, '', 'F';
//-- ����� basecode.grp -��Ӧ foxhelp.hlpkey �� �ڴ���༭��ʱ��ʹ�� 
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'HOTEL', '�Ƶ�', 'Hotel', '', 100);
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'DEPTNO', '����', 'Department', 'p_deptno', 200);
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'SALEGRP', '������', 'Sales Team', 'p_salegrp', 300);
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'SALEID', '����Ա', 'Sales Agent', 'p_saleid', 400);
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'ACCOUNT', 'Э�鵥λ', 'Accounts', 'p_account', 500);
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'CONTACT', '��ϵ��', 'Contacts', 'p_contact', 600);
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'GUEST', '����', 'Guests', 'p_guest', 700);
//select * from basecode where cat='plan_who' order by sequence, code ;


-- --------------------------------------
--  plan_cat  �ƻ���𣨶��󣩶��� 
-- --------------------------------------
if exists(select * from sysobjects where name = "plan_cat")
	drop table plan_cat;
create table plan_cat
(
	cat				varchar(30)							not null,		-- plan catalog. eg: mkt, src, jourrep...... 
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	codesql			text			default ''		not null,		-- �ƻ���������� sql, �ͻ���ʹ�ã� �����Զ�����  
																				-- �����sql�����ж�Σ��÷ֺŸ���
																				-- Ҳ����ʹ proc 
	plantype			varchar(30)		default ''		not null,		-- ���Ƽƻ������ �գ��£��꣬�ܣ����ȣ����£�Ѯ ��   
																				-- �ֱ��ô��� D, M, Y, W, S, H, X �ȴ����ʾ
																				-- basecode  (cat = plan_period)
																				-- ����ֶο��Կ��Ƕ�ѡ��������ͬʱ���ƶ��ּƻ�����ʱ����һ������Ҫ����
																				-- ���һ����ϵͳ��Ҫ�����걸��ʱ�����Ա����������� ��
	planwho			varchar(255) default 'HOTEL'		not null,		-- plan_who ���Զ�ѡ 
	lic				varchar(20)	default ''		not null,		-- ��Ȩ���� 
	halt				char(1)		default 'F'		not null,
	sequence			int			default 0		not null
)
exec sp_primarykey plan_cat,cat
create unique index index1 on plan_cat(cat)
;
//insert plan_cat(cat,descript,descript1,plantype,sequence) select 'jourrep','����Ӫҵ����','Hotel Revenue','M',100;
//insert plan_cat(cat,descript,descript1,plantype,planitem,sequence) select 'market','�г�','Market','M','1=����:NT^2=����:REV^',200;
//insert plan_cat(cat,descript,descript1,plantype,planitem,sequence) select 'source','��Դ','Source','M','1=����:NT^2=����:REV^',300;
//insert plan_cat(cat,descript,descript1,plantype,planitem,sequence) select 'channel','����','Channel','M','1=����:NT^2=����:REV^',400;
//select * from plan_cat order by sequence, cat;


-- --------------------------------------
--  plan_who  = plan_cat.planwho 
-- --------------------------------------
if exists(select * from sysobjects where name = "plan_who")
	drop table plan_who;
create table plan_who
(
	planwho			varchar(30)						not null,		-- �ƻ��Ķ��� 
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	codesql			text    		default 'HOTEL' not null,
	halt				char(1)		default 'F'		not null,
	sequence			int			default 0		not null
)
exec sp_primarykey plan_who,planwho
create unique index index1 on plan_who(planwho)
;
insert plan_who(planwho,descript,descript1,codesql,halt,sequence) select 'HOTEL','�Ƶ�','Hotel','HOTEL','F',0;
insert plan_who(planwho,descript,descript1,codesql,halt,sequence) select 'DEPTNO','����','Department','select code,descript,descript1 from basecode where cat=''dept'' and char_length(rtrim(code))=1 and code<>''0'' order by sequence,code','F',0;
insert plan_who(planwho,descript,descript1,codesql,halt,sequence) select 'SALEGRP','������','Sales Team','select code,descript,descript1 from salegrp where halt=''F'' order by sequence,code','F',0;
insert plan_who(planwho,descript,descript1,codesql,halt,sequence) select 'SALEID','����Ա','Sales Agent','select code,name,name2 from saleid order by sequence,code','F',0;
insert plan_who(planwho,descript,descript1,codesql,halt,sequence) select 'ACCOUNT','Э�鵥λ','Accounts','select no,name,name2 from guest where class in (''C'',''A'',''S'') order by name','F',0;
insert plan_who(planwho,descript,descript1,codesql,halt,sequence) select 'CONTACT','��ϵ��','Contacts','select a.no,b.name,b.name2 from argst a, guest b where a.no=b.no and a.tag1=''T'' order by b.name','F',0;
select * from plan_who order by sequence, planwho;


//-- --------------------------------------s
//--  plan_code  �ƻ����붨�� 
//-- --------------------------------------
//if exists(select * from sysobjects where name = "plan_code")
//	drop table plan_code;
//create table plan_code
//(
//	cat				varchar(30)							not null,
//	clskey			varchar(30)						not null,		-- class key ��ʾ class �Ĺؼ��� 
//	class				varchar(30)						not null,
//   descript   		varchar(60)    				not null,
//   descript1  		varchar(60) default ''   	not null,
//	rectype			char(2)		default  ''		null,				-- B, C or Null 
//	toop				char(2)		default  ''		null,				-- +, /, % 
//	toclass1			varchar(60)	default  ''		null,				-- clskey+class
//	toclass2			varchar(60)	default  ''		null,				-- clskey+class
//	unit				char(6)		default  '. .'	null,				-- .., % 
//	show				char(1)		default  'T'	null,
//	flag				char(10)		default  '>='	null,				-- �ƻ�����, ��ʾ���ݶԱ�Ҫ��ģ����� >, >=, <, <=, =, ... 
//	scope1			money			default 0		not null,		-- �ƻ���Χ���� 
//	scope2			money			default 0		not null,
//	scope3			money			default 0		not null,
//	extra 			varchar(30)	default  ''		null,
//	sequence			int			default 0 		not null
//)
//exec sp_primarykey plan_code,cat,clskey,class
//create unique index index1 on plan_code(cat,clskey,class)
//;
//insert plan_code select 'jourrep','class',class,descript,descript1,rectype,toop,toclass1,toclass2,unit,show,'>=',0,0,0,'',0 from jourrep ;
//update plan_code set toclass1='class'+toclass1 where cat='jourrep' and rtrim(toclass1) is not null;
//update plan_code set toclass2='class'+toclass2 where cat='jourrep' and rtrim(toclass2) is not null;
//update plan_code set sequence = convert(int, class) where cat='jourrep'
//
//insert plan_code select 'market','grp',code,descript,descript1,'C','','','','','T','>=',0,0,0,'',0 from basecode where cat='market_cat';
//insert plan_code select 'market','code',code,descript,descript1,'B','+','grp'+grp,'','','T','>=',0,0,0,'',0 from mktcode ;
//
//insert plan_code select 'source','grp',code,descript,descript1,'C','',grp,'','','T','>=',0,0,0,'',0 from basecode where cat='src_cat';
//insert plan_code select 'source','code',code,descript,descript1,'B','+','grp'+grp,'','','T','>=',0,0,0,'',0 from srccode ;
//
//insert plan_code select 'channel','code',code,descript,descript1,'B','','','','','T','>=',0,0,0,'',0 from basecode where cat='channel';
//
//select * from plan_code order by cat, sequence, class;


-- ----------------------------------------------------
--  plan_def  �ƻ����ݴ洢. ��ʱ���֧��8������
-- ----------------------------------------------------
if exists(select * from sysobjects where name = "plan_def")
	drop table plan_def;
create table plan_def
(
	cat				varchar(30)							not null,		-- plan_cat 
	owner				varchar(30)							not null,		-- plan_who 
	planwho 			varchar(30)							not null,		-- plan_who ��Ӧ�Ĵ��� 
	item 				varchar(30)							not null,      -- plan_item �ƻ���Ŀ
	type				char(1)								not null,		-- plan_type 
	clskey			varchar(30)							not null,		-- grp 
	class				varchar(30)							not null,		-- code 
	period			varchar(30)							not null,		-- plan_period �ɡ��ƻ����䶨�塯�������ַ�ƴ�Ӷ���
																					-- �磺Y2005, Y2006, M200601, M200609, S200601, D20060909 �� 
	amount1			money			default 0		not null,
//	amount2			money			default 0		not null,
//	amount3			money			default 0		not null,
//	amount4			money			default 0		not null,
//	amount5			money			default 0		not null,
//	amount6			money			default 0		not null,
//	amount7			money			default 0		not null,
//	amount8			money			default 0		not null,
	empno				char(10)							not null,		-- Ԥ���ֶΣ�ϵͳ������Ҫ�Լƻ����Ƽ�¼��־
	changed			datetime							not null,
	logmark			int			default 0		not null
)
exec sp_primarykey plan_def,cat,owner,planwho,type,clskey,class,period,item
create unique index index1 on plan_def(cat,owner,planwho,type,clskey,class,period,item)
;

if exists(select * from sysobjects where name = "plan_def_log")
	drop table plan_def_log;
create table plan_def_log
(
	cat				varchar(30)							not null,
	owner				varchar(30)							not null,
	planwho 			varchar(30)							not null,		-- plan_who ��Ӧ�Ĵ��� 
	item 				varchar(30)						not null,         -- ��Ŀ
	type				char(1)								not null,
	clskey			varchar(30)							not null,
	class				varchar(30)							not null,
	period			varchar(30)							not null,		-- �ɡ��ƻ����䶨�塯�������ַ�ƴ�Ӷ���
																				-- �磺Y2005, Y2006, M200601, M200609, S200601, D20060909 �� 
	amount1			money			default 0		not null,
//	amount2			money			default 0		not null,
//	amount3			money			default 0		not null,
//	amount4			money			default 0		not null,
//	amount5			money			default 0		not null,
//	amount6			money			default 0		not null,
//	amount7			money			default 0		not null,
//	amount8			money			default 0		not null,
	empno				char(10)							not null,		-- Ԥ���ֶΣ�ϵͳ������Ҫ�Լƻ����Ƽ�¼��־
	changed			datetime							not null,
	logmark			int			default 0		not null
)
exec sp_primarykey plan_def_log,cat,owner,planwho,type,clskey,class,period,logmark,item
create unique index index1 on plan_def_log(cat,owner,planwho,type,clskey,class,period,logmark,item)
;

//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200601','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200602','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200603','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200604','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200605','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200606','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200607','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200608','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200609','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200610','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200611','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200612','FOX',getdate() from jourrep order by class; 
//
//select * from plan_def order by cat, period, class; 

 
// ------------------------------------------------------------------------------------
//		plan_def ������
// ------------------------------------------------------------------------------------
//if exists (select * from sysobjects where name = 't_gds_plan_def_insert' and type = 'TR')
//	drop trigger t_gds_plan_def_insert;
//create trigger t_gds_plan_def_insert
//   on plan_def for insert
//	as
//begin
//insert lgfl select 'plan_?', no, '', no, cby, changed from inserted
//end;
if exists (select * from sysobjects where name = 't_gds_plan_def_update' and type = 'TR')
	drop trigger t_gds_plan_def_update
;
create trigger t_gds_plan_def_update
   on plan_def for update
	as
begin
if update(logmark)   -- ע�⣬���������� deleted
	insert plan_def_log select deleted.* from deleted
end;

//  ��־��Ŀ���� 
delete lgfl_des where columnname like 'plan_%';
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount1', '��ֵ1', 'Amount1', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount2', '��ֵ2', 'Amount2', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount3', '��ֵ3', 'Amount3', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount4', '��ֵ4', 'Amount4', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount5', '��ֵ5', 'Amount5', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount6', '��ֵ6', 'Amount6', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount7', '��ֵ7', 'Amount7', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount8', '��ֵ8', 'Amount8', 'O');.



-- --------------------------------------
--  plan_item  ������Ŀ���� 
-- --------------------------------------
if exists(select * from sysobjects where name = "plan_item")
	drop table plan_item;
create table plan_item
(
	cat				varchar(30)							not null,		-- plan catalog. eg: mkt, src, jourrep...... 
	item 				varchar(30)						not null,         -- ��Ŀ
   descript   		varchar(60)    				not null,         -- ��������
   descript1  		varchar(60) default ''   	not null,			-- Ӣ������
	format			varchar(30)	default '#,##0.00' not null,		-- ��ʽ 
	tag				varchar(30) default ''   	not null,			-- Ԥ��
	halt				char(1)		default 'F'		not null,			
	sequence			int			default 0		not null				
)		
create unique index index1 on plan_item(cat,item)
;		