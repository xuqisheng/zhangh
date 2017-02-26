if exists(select * from sysobjects where name = "pccode")
	drop table pccode;
create table pccode
(
	pccode		char(5)		not null,					/* Ӫҵ�� */
	descript		char(24)		default '',					/* �������� */
	descript1	char(50)		default '',					/* ������������ */
	descript2	char(50)		default '',					/* ������������ */
	descript3	char(50)		default '',					/* ������������ */
	modu			char(2)		default '',					/* ģ��� */
	jierep		char(8)		default '',					/* �ױ������� */
	tail			char(2)		default '',					/* �ױ������� */
	//
	commission	money			default 0 not null,		/* �����еĻؿ���(�����ÿ���Ч) */
	limit			money			default 0 not null,		/* �����޶� */
	reason		char(1)		default 'F' not null,	/* �Ƿ���Ҫ�����Ż����� */
	// deptno?Ϊ���ַ�����롢���д����Լ�ԭ���ʽ���еĸ���
	deptno		char(5)		default '',					/* chgcod:����Ӫҵ����,paymth:���ʽ����� */
	deptno1		char(5)		default '' null,			/* chgcod:������ˡ��Զ�ת�ˡ����˻�����,paymth:�ڲ����(���Կ��ǲ���,����sequence) */
	deptno2		char(5)		default '' null,			/* chgcod:��Ʊ����(ԭԤ��), paymth:���ʽ���ڲ�������*/
	deptno3		char(5)		default '' null,			/* chgcod:Ԥ��, paymth:98�ܵ�����,����ֻ�������ʸ��� */
	deptno4		char(5)		default '' null,			/* chgcod:�����ѯ����, paymth:ISC���ÿ�,���������ÿ�*/
	deptno5		char(5)		default '' null,			/* �÷������ʹ�õ�ģ��F(Front)A(Ar)P(Pos), (ԭchgcod:��Ʊ����, paymth:Ԥ��)--�޸�����2006/09/21 */
	deptno6		char(5)		default '' null,			/* chgcod:�����к�, paymth:99ǰ̨����,����ֻ����POS��ʹ�ã�������ǰ̨ʹ��(�����Ժ�ͳһ��deptno5) */	 
	deptno7		char(5)		default '' null,			/* chgcod:ҵ��ͳ��, paymth:��Ҵ���, ��Ӧfec_def��code */
	deptno8		char(5)		default '' null,			/* chgcod:Rebate��־, paymth:Distribute��־ */ 
	argcode		char(3)		default '' null,			/* ȱʡ���˵�����, 9����Ϊ����9����Ϊ����, ���ܵ���9 */
//	paycode		char(3)		not null,					/* �ڲ���,С��54Ϊ��Ч�ĸ��ʽ */
//	codecls		char(1)		not null,					/* ���ʽ���,refer to credcls */
//	tag1			char(3)		default '' null,			/*  */
//	tag2			char(3)		default '' null,			/*  */
//	tag3			char(3)		default '' null,			/*  */
//	tag4			integer 		default 0 null,			/*  */
//	distribute  char(4)     null,							/* ���̯����... */
	//
	pos_item		char(3)		default '' null
)
exec sp_primarykey pccode, pccode
create unique clustered index index1 on pccode(pccode)
;

insert pccode select pccode+servcode, descript2, descript1, '','', modu, jierep, tail, 0, 0, 'F', 
	deptno, deptno1, deptno2, deptno3, deptno4, deptno5, deptno6, deptno7, '', pccode, pos_item
	from chgcod where not pccode in ('03', '05', '06');
delete pccode where substring(pccode, 3, 1) in ('A', 'I', 'J', 'K', 'L', 'M') or pccode like '9%';
update pccode set pccode = substring(pccode, 1, 2) + '0' where substring(pccode, 3, 1) = '';
update pccode set pccode = substring(pccode, 1, 2) + '1' where substring(pccode, 3, 1) = 'Z';
update pccode set pccode = substring(pccode, 1, 2) + '2' where substring(pccode, 3, 1) = 'B';
update pccode set pccode = substring(pccode, 1, 2) + '3' where substring(pccode, 3, 1) = 'C';
update pccode set pccode = substring(pccode, 1, 2) + '4' where substring(pccode, 3, 1) = 'D';
update pccode set pccode = substring(pccode, 1, 2) + '5' where substring(pccode, 3, 1) = 'E';
update pccode set pccode = substring(pccode, 1, 2) + '6' where substring(pccode, 3, 1) = 'F';
update pccode set pccode = substring(pccode, 1, 2) + '7' where substring(pccode, 3, 1) = 'S';
update pccode set pccode = substring(pccode, 1, 2) + '8' where substring(pccode, 3, 1) = 'T';
update pccode set pccode = substring(pccode, 1, 2) + '9', reason = 'T' where substring(pccode, 3, 1) = 'H';
update pccode set descript = rtrim(a.descript2) + ' - ' + pccode.descript from chgcod a
	where substring(pccode.pccode, 3, 1)!='0' and substring(pccode.pccode, 1, 2) = a.pccode and a.servcode is null;
//
insert pccode select '9' + substring(paycode, 2, 2), descript2, '', '', '', '', '', tail, commission, limit1, 'F', 
	paycode, codecls, tag1, tag2, tag3, convert(char(3), tag4), '', '', substring(isnull(distribute, ''), 2, 3), '98', ''
	from paymth;
update pccode set reason = 'T' where pccode like '9%' and deptno8 <> '';
update pccode set deptno4 = 'ISC' where pccode like '9%' and deptno1 in ('C', 'D');
update pccode set pccode = '00' + substring(pccode, 3, 1) where pccode like '02%';
update pccode set descript = 'Rebate - ' + (select a.descript from pccode a where a.pccode = substring(pccode.pccode, 1, 2) + '0'),
	deptno8 = 'RB' where pccode < '9' and pccode like '%9';
//
update pccode set deptno1 = '00' where pccode < '020';
update pccode set deptno1 = '01' where pccode like '1%';
update pccode set deptno1 = '02' where pccode like '2%';
update pccode set deptno1 = '07' where modu = '06';
update pccode set deptno1 = '05' where modu = '09';
update pccode set deptno1 = '06' where substring(pccode, 1, 2) in ('68', '69', '70', '71');
//
if exists(select * from sysobjects where name = "argcode")
	drop table argcode;
create table argcode
(
	argcode		char(2)		not null,					/* Ӫҵ�� */
	descript		char(24)		default '',					/* �������� */
	descript1	char(50)		default '',					/* ������������ */
	descript2	char(50)		default '',					/* ������������ */
	descript3	char(50)		default '',					/* ������������ */
)
exec sp_primarykey argcode, argcode
create unique clustered index index1 on argcode(argcode)
;
insert argcode select pccode, descript, descript1, descript2, descript3 from pccode where pccode like '%0' and pccode < '9';
//
insert basecode values ('jierep_tail', '01', '��Ӫ', '', 'T', 'F', 10, '');
insert basecode values ('jierep_tail', '02', 'ʳƷ', '', 'T', 'F', 20, '');
insert basecode values ('jierep_tail', '03', '��Ʒ', '', 'T', 'F', 30, '');
insert basecode values ('jierep_tail', '04', '����', '', 'T', 'F', 40, '');
insert basecode values ('jierep_tail', '05', '����', '', 'T', 'F', 50, '');
insert basecode values ('jierep_tail', '06', '����', '', 'T', 'F', 60, '');
insert basecode values ('jierep_tail', '07', '�����', '', 'T', 'F', 70, '');
insert basecode values ('jierep_tail', '08', '���', '', 'T', 'F', 80, '');
insert basecode values ('jierep_tail', '09', '�ۿ�', '', 'T', 'F', 90, '');
//
insert basecode values ('dairep_tail', '01', '�����', '', 'T', 'F', 10, '');
insert basecode values ('dairep_tail', '02', '֧Ʊ', '', 'T', 'F', 20, '');
insert basecode values ('dairep_tail', '03', '���ڿ�', '', 'T', 'F', 30, '');
insert basecode values ('dairep_tail', '04', '���⿨', '', 'T', 'F', 40, '');
insert basecode values ('dairep_tail', '05', '�ڲ�ת��', '', 'T', 'F', 50, '');
insert basecode values ('dairep_tail', '06', '����', '', 'T', 'F', 60, '');
insert basecode values ('dairep_tail', '07', '��ת���', '', 'T', 'F', 70, '');
//
INSERT INTO sysdefault VALUES (	'd_gl_code_paymth_edit',	'argcode',	'98');
