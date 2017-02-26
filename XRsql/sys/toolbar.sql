
// ------------------------------------------------------------------------------
//	appid : FOXHIS ϵͳӦ�ñ���
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "appid")
	drop table appid;
create table appid
(
	code			char(1)						not null,
	moduno		char(2)		default ''	not null,
	descript    varchar(20)					not null,
	descript1   varchar(30)	default ''	not null,
   ref			varchar(20)	default ''	not null,
	exename		varchar(20)	default ''	not null
);
exec sp_primarykey appid,code,moduno
create unique index index1 on appid(code,moduno)
;
insert appid select '1', '', 'ǰ̨ϵͳ', 'Front Office', '','front'
insert appid select '2', '', 'ά��ϵͳ', 'Maintance System', '','maint'
insert appid select '3', '', '����ϵͳ', 'Food System', '','pos'
insert appid select '4', '', '����ϵͳ', 'Entertainment System', '',''
insert appid select '6', '', '�绰ϵͳ', 'Phone System', '','phone'
insert appid select '8', '', 'ɣ��ϵͳ', 'Suna System', '','sunna'
insert appid select '9', '', 'Ӧ��ϵͳ', 'AR System', '',''
insert appid select 'A', '', '����ϵͳ', 'FOXHIS SCM', '','supply'
insert appid select 'B', '', '�ɱ�����ϵͳ', '�ɱ�����_eng', '','cost'
insert appid select 'C', '', '�豸����ϵͳ', '�豸����_eng', '',''
insert appid select 'V', '', 'VOD ϵͳ', 'VOD System_eng', '','vod'
insert appid select 'K', '', 'VIP ϵͳ', 'VIP System_eng', '','vip'
;
// --------------------------------------------------------------------
//	toolbar_cat : ϵͳ�������Ϸ��󹤾���
//						ͬʱҲ��ϵͳģ��Ķ���
//
//			appid		-- Ӧ�ñ��
//			moduno	-- Ӧ���ڲ���ģ����  moduno=00 ϵͳ������
//
//		�������󹤾����Ľű����壬�ɳ���Ա����code��д�����ﲻ�����塣
// --------------------------------------------------------------------
if exists(select * from sysobjects where name = "toolbar_cat" and type = 'U')
	drop table toolbar_cat;
create table toolbar_cat
(
	code			char(12)						not null,	// ���
	descript    varchar(30)					not null,	// ��������
	descript1   varchar(40)	default ''	not null,	// Ӣ������
	appid			char(1)		default ''	not null,	// Ӧ�ñ�ţ�1-ǰ̨ϵͳ��2-����ϵͳ�ȣ�
	moduno   	char(2)		default ''	not null,	// ģ���� -- ����Ϊ�մ�����ʾ����ģ�飬���� exit
	pic			varchar(20)	default ''	not null,	// ͼ�����ƹؼ���
	show			char(1)		default 'T'	not null,	// ���ã�
	lic			varchar(20)	default ''	not null,
	sequence		int			default 0	not null
)
exec sp_primarykey toolbar_cat,appid,code
create unique index index1 on toolbar_cat(appid,code)
;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '',  'system',  'ϵͳ',		'system',		'00',	'',			0;

// �����Ƕ���ǰ̨ϵͳ�ܹ�����
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'reserve',	'Ԥ��',		'Reserve',		'01',	'res',		10;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'recept', 	'�Ӵ�',		'Recept',		'02',	'recept',	20;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'casher', 	'����',		'Casher',		'03',	'cash',		30;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'pubmkt', 	'��������',	'P&R Market',	'04',	'sale',		40;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'house',  	'�ͷ�����',	'House',			'05',	'house',		50;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'business','��������',	'Business',		'06',	'bus',		60;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'polite', 	'���',		'Polite',		'07',	'car',		70;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'audit',   '�������',	'Audit',			'08',	'check',		80;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'info',  	'��Ϣ��ѯ',	'Information',	'09',	'query',		90;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'other',   '����',		'Other',			'10',	'flower',	100;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'exit',   	'�˳�',		'Exit',			'',	'exit',		800;


// --------------------------------------------------------------------
//	toolbar : ϵͳӦ����ߵĹ����б�
// --------------------------------------------------------------------
if exists(select * from sysobjects where name = "toolbar" and type = 'U')
	drop table toolbar;
create table toolbar
(
	appid			char(1)						not null,	// Ӧ�ñ�ţ�1-ǰ̨ϵͳ��2-����ϵͳ�ȣ�
	cat			varchar(40)					not null,	// ������  ������ toolbar_cat
	code			varchar(12)					not null,	// ���
	descript    varchar(30)					not null,	// ��������
	descript1   varchar(40)	default ''	not null,	// Ӣ������
	wtype			char(10)		default ''	not null,	// �༭����: response, hry, sheet, event-ϵͳ�������¼�
	auth			varchar(20)	default ''	not null,
   source  		text        default ''	not null,   // �༭
   parm  		text  		default '' 	not null,   // �༭����
	multi			char(1)		default 'F' not null,	// �Ƿ�Ϊ���ʵ����
	lic			varchar(20)	default ''	not null,
	sequence		int			default 0	not null
)
exec sp_primarykey toolbar,appid,cat, code
create unique index index1 on toolbar(appid,cat, code)
;
