if exists(select * from sysobjects where name = "pccode")
	drop table pccode;
create table pccode
(
	pccode		char(3)		not null,					/* 营业点 */
	descript		char(24)		default '',					/* 中文描述 */
	descript1	char(50)		default '',					/* 其他语种描述 */
	descript2	char(50)		default '',					/* 其他语种描述 */
	descript3	char(50)		default '',					/* 其他语种描述 */
	modu			char(2)		default '',					/* 模块号 */
	jierep		char(8)		default '',					/* 底表行索引 */
	tail			char(2)		default '',					/* 底表列索引 */
	//
	commission	money			default 0 not null,		/* 给银行的回扣率(对信用卡有效) */
	limit			money			default 0 not null,		/* 信用限额 */
	reason		char(1)		default 'F' not null,	/* 是否需要输入优惠理由 */
	// deptno?为各种分类代码、排列次序以及原付款方式表中的各项
	deptno		char(3)		default '',					/* 所属营业部门 */
	deptno1		char(3)		default '' null,			/* 允许记账、自动转账、分账户分类 */
	deptno2		char(3)		default '' null,			/* 预留 */
	deptno3		char(3)		default '' null,			/* 预留 */
	deptno4		char(3)		default '' null,			/* 帐务查询分类 */
	deptno5		char(3)		default '' null,			/* 预留 */
	deptno6		char(3)		default '' null,			/* 分部门统计 */
	deptno7		char(3)		default '' null,			/* 余额表列号 */	 
	deptno8		char(3)		default '' null,			/* 费用:Rebate标志; 付款:Distribute标志*/ 
	argcode		char(2)		default '' null,			/* 缺省的账单分类 */
//	paycode		char(3)		not null,					/* 内部码,小于54为有效的付款方式 */
//	codecls		char(1)		not null,					/* 付款方式类别,refer to credcls */
//	tag1			char(3)		default '' null,			/*  */
//	tag2			char(3)		default '' null,			/*  */
//	tag3			char(3)		default '' null,			/*  */
//	tag4			integer 		default 0 null,			/*  */
//	distribute  char(4)     null,							/* 需分摊款项... */
	//
	pos_item		char(3)		default '' null
)
exec sp_primarykey pccode, pccode
create unique clustered index index1 on pccode(pccode)
;
update a_chgcod set pos_item = '';
insert pccode select pccode+servcode, descript2, descript1, '','', modu, jierep, tail, 0, 0, 'F', 
	deptno, deptno1, deptno2, deptno3, deptno4, deptno5, deptno6, deptno7, '', pccode, pccode+servcode
	from a_chgcod where pccode > '06';
//
update pccode set descript = rtrim(a.descript2) + ' - ' + pccode.descript from a_chgcod a
	where substring(pccode.pccode, 1, 2) = a.pccode and a.servcode is null;
update pccode set descript = a.descript2, descript1 = a.descript1 from a_chgcod a
	where substring(pccode.pccode, 3, 1)='A' and substring(pccode.pccode, 1, 2) = a.pccode and a.servcode is null;
update pccode set pccode = substring(pccode.pccode, 1, 2) + '9', reason = 'T', deptno8 = 'RB',
	descript = rtrim(a.descript2) + ' - Rebate', descript1 = rtrim(a.descript1) + ' - Rebate' from a_chgcod a
	where substring(pccode.pccode, 3, 1)='H' and substring(pccode.pccode, 1, 2) = a.pccode and a.servcode is null;
//
delete pccode where substring(pccode, 3, 1) in ('', 'I', 'J', 'K', 'L', 'M');
//delete pccode where substring(pccode, 3, 1) in ('A', 'I', 'J', 'K', 'L', 'M') or pccode like '9%';
update pccode set pccode = substring(pccode, 1, 2) + '0' where substring(pccode, 3, 1) = 'A';
update pccode set pccode = substring(pccode, 1, 2) + '1' where substring(pccode, 3, 1) = 'Z';
update pccode set pccode = substring(pccode, 1, 2) + '2' where substring(pccode, 3, 1) = 'B';
update pccode set pccode = substring(pccode, 1, 2) + '3' where substring(pccode, 3, 1) = 'C';
update pccode set pccode = substring(pccode, 1, 2) + '4' where substring(pccode, 3, 1) = 'D';
update pccode set pccode = substring(pccode, 1, 2) + '5' where substring(pccode, 3, 1) = 'E';
update pccode set pccode = substring(pccode, 1, 2) + '6' where substring(pccode, 3, 1) = 'F';
update pccode set pccode = substring(pccode, 1, 2) + '7' where substring(pccode, 3, 1) = 'S';
update pccode set pccode = substring(pccode, 1, 2) + '8' where substring(pccode, 3, 1) = 'T';
// JJH - Begin
delete pccode where deptno='90' and not substring(pccode, 3, 1) in ('0');
update pccode set pccode = '512' where pccode = '900';
update pccode set pccode = '514' where pccode = '910';
update pccode set pccode = '516' where pccode = '920';
update pccode set pccode = '518' where pccode = '950';
update pccode set pccode = '522' where pccode = '960';
update pccode set pccode = '524' where pccode = '970';
update pccode set pccode = '526' where pccode = '980';
update pccode set pccode = '528' where pccode = '540';
update pccode set pccode = '532' where pccode = '560';
update pccode set pccode = '534' where pccode = '570';
update pccode set pccode = '536' where pccode = '580';
update pccode set pccode = '538' where pccode = '590';
update pccode set pccode = '56' + substring(pccode, 3, 1) where pccode like '93%';
update pccode set pccode = '57' + substring(pccode, 3, 1) where pccode like '94%';
update pccode set pccode = '58' + substring(pccode, 3, 1) where pccode like '99%';
delete pccode where pccode > '02' and pccode < '9' and substring(pccode, 3, 1) > '0' and substring(pccode, 3, 1) < '9' and deptno <> '90'
// JJH - End
update a_chgcod set pos_item = a.pccode from pccode a
	where a_chgcod.pccode + a_chgcod.servcode = a.pos_item;
update a_chgcod set pos_item = a.pccode from pccode a
	where a_chgcod.pos_item = '' and a_chgcod.pccode + 'A' = a.pos_item;
update a_chgcod set pos_item = '007' where pccode = '02' and servcode in ('C');
update a_chgcod set pos_item = '000' where pccode = '02';
update a_chgcod set pos_item = '004' where pccode = '01' and servcode in (Null, '', 'A', 'I', 'S', 'T', 'Z');
update a_chgcod set pos_item = '005' where pccode = '01' and servcode in ('B');
update a_chgcod set pos_item = '007' where pccode = '01' and servcode in ('C');
update a_chgcod set pos_item = '006' where pccode = '01' and servcode in ('E');
update a_chgcod set pos_item = '009' where pccode = '01' and servcode in ('H');
update a_chgcod set old_pccode = pccode + servcode;
update a_chgcod set pos_item = pccode + servcode where pccode in ('03', '05', '06');
//
insert pccode select '9' + substring(paycode, 2, 2), descript2, '', '', '', '', '', tail, commission, limit1, 'F', 
	codecls, paycode, tag1, tag2, tag3, convert(char(3), tag4), '', '', substring(isnull(distribute, ''), 2, 3), '98', ''
	from a_paymth;
//update pccode set reason = 'T' where pccode like '9%' and deptno8 <> '';
delete pccode where pccode='916';
insert pccode select * from a_pccode where pccode='902';
update pccode set deptno4 = 'ISC' where pccode like '9%' and deptno in ('C', 'D');
update pccode set deptno3 = '98' where pccode like '9%' and deptno3 in ('');
update pccode set deptno3 = '' where pccode like '9%' and deptno3 in ('03');
update pccode set deptno6 = '99' where pccode like '9%' and substring(deptno2, 1, 2) <> 'TO';
update pccode set descript1 = a.descript1 from a_pccode a where pccode.pccode = a.pccode and pccode.pccode like '9%';
//update pccode set pccode = '00' + substring(pccode, 3, 1) where pccode like '02%';
//update pccode set descript = 'Rebate - ' + (select a.descript from pccode a where a.pccode = substring(pccode.pccode, 1, 2) + '0'),
//	deptno8 = 'RB' where pccode < '9' and pccode like '%9';
////
//update pccode set deptno1 = '00' where pccode < '020';
//update pccode set deptno1 = '01' where pccode like '1%';
//update pccode set deptno1 = '02' where pccode like '2%';
//update pccode set deptno1 = '07' where modu = '06';
//update pccode set deptno1 = '05' where modu = '09';
//update pccode set deptno1 = '06' where substring(pccode, 1, 2) in ('68', '69', '70', '71');
//
insert pccode select * from a_pccode where pccode<'02';
// JJH Begin
update pccode set deptno = '05', deptno1 = '05', deptno2 = '05', deptno3 = '05', deptno4 = '05', deptno5 = '05', deptno6 = '05'
	where pccode < '02';
// JJH End
if exists(select * from sysobjects where name = "argcode")
	drop table argcode;
create table argcode
(
	argcode		char(2)		not null,					/* 营业点 */
	descript		char(24)		default '',					/* 中文描述 */
	descript1	char(50)		default '',					/* 其他语种描述 */
	descript2	char(50)		default '',					/* 其他语种描述 */
	descript3	char(50)		default '',					/* 其他语种描述 */
)
exec sp_primarykey argcode, argcode
create unique clustered index index1 on argcode(argcode)
;
insert argcode select pccode, descript, descript1, descript2, descript3 from pccode where pccode like '%0' and pccode < '9';
//
truncate table reason_type;
insert reason_type select * from v5..reason_type;
truncate table reason;
insert reason select * from v5..reason;

delete basecode where cat='artag1';
insert basecode select 'artag1', code, name1, isnull(name2, ''), 'T', 'F', 10, '' from v5..artagcode;
