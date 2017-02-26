
// �����ƷѶ���

insert into basecode_cat(cat,descript) select 'pos_timedef', '�����Ʒ�';
insert into basecode(cat,code,descript,descript1) select 'pos_timedef', '01','�����ҼƷ�','�����ҼƷ�';
insert into basecode(cat,code,descript,descript1) select 'pos_timedef', '02','������Ʒ�','������Ʒ�';

CREATE TABLE pos_timedef (
	id 		char(2)			default ''  not null ,
	thisid 	char(2)			default ''  not null ,
	timedesc char(30)			default ''  not null ,
	datecond char(60)			default ''  not null ,
	start_t 	char(8)			default '00:00:00'  not null ,          -- ��ʼʱ��
	end_t 	char(8)			default '00:00:00'  not null ,			  -- ����ʱ��
	leng_ 	integer			default 60  not null ,			  -- ��λʱ��
	factor 	money 			default 0   not null )          -- �Ƽ� 
;

exec sp_primarykey pos_timedef,id,thisid
create unique index index1 on pos_timedef(id,thisid)
;
INSERT INTO pos_timedef VALUES (	'01',	'01',	'��һ������0ʱ��7ʱ',	'w:1234567',	'00:00:00',	'06:59:59',	60, 50);
INSERT INTO pos_timedef VALUES (	'01',	'02',	'��һ������7ʱ��24ʱ',	'w:1234567',	'07:00:00',	'23:59:59',	60, 100);
INSERT INTO pos_timedef VALUES (	'02',	'01',	'��һ������0ʱ��7ʱ',	'w:1234567',	'00:00:00',	'06:59:59',	60, 50);
INSERT INTO pos_timedef VALUES (	'02',	'02',	'��һ������7ʱ��22ʱ',	'w:1234567',	'07:00:00',	'21:59:59',	60, 100);
INSERT INTO pos_timedef VALUES (	'02',	'03',	'��һ������22ʱ��0��',	'w:1234567',	'22:00:00',	'23:59:59',	60, 120);

// ��ʱ��ż�����
CREATE TABLE pos_timeanal (
	pc_id    char(4)				default ''  not null ,
	id 	   char(2)				default ''  not null ,
	thisid   char(2)				default ''  not null ,
	start_t  char(8)				default '00:00:00'  not null ,
	end_t    char(8)				default '00:00:00'  not null ,
	factor   money					default 0   not null ,          -- ����
	leng_ 	integer			   default 60  not null ,			  -- ��λ�Ƽ�ʱ��,����
	duration money					default 0   not null );         -- ����

exec sp_primarykey pos_timeanal,pc_id,id,thisid
create unique index index1 on pos_timeanal(pc_id,id,thisid)
;
