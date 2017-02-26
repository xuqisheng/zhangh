if exists(select * from sysobjects where name = "pccode")
	drop table pccode;
create table pccode
(
	pccode		char(5)		not null,					/* 营业点 */
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
	deptno		char(5)		default '',					/* chgcod:所属营业部门,paymth:付款方式的类别 */
	deptno1		char(5)		default '' null,			/* chgcod:允许记账、自动转账、分账户分类,paymth:内部序号(可以考虑不用,改用sequence) */
	deptno2		char(5)		default '' null,			/* chgcod:发票分类(原预留), paymth:付款方式的内部特征码*/
	deptno3		char(5)		default '' null,			/* chgcod:预留, paymth:98能当定金,其他只能做结帐付款 */
	deptno4		char(5)		default '' null,			/* chgcod:帐务查询分类, paymth:ISC信用卡,其他非信用卡*/
	deptno5		char(5)		default '' null,			/* 该费用码可使用的模块F(Front)A(Ar)P(Pos), (原chgcod:发票分类, paymth:预留)--修改日期2006/09/21 */
	deptno6		char(5)		default '' null,			/* chgcod:余额表列号, paymth:99前台可用,其他只能在POS点使用，不能在前台使用(考虑以后统一用deptno5) */	 
	deptno7		char(5)		default '' null,			/* chgcod:业绩统计, paymth:外币代码, 对应fec_def的code */
	deptno8		char(5)		default '' null,			/* chgcod:Rebate标志, paymth:Distribute标志 */ 
	argcode		char(3)		default '' null,			/* 缺省的账单分类, 9以下为费用9以上为付款, 不能等于9 */
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
insert basecode values ('jierep_tail', '01', '主营', '', 'T', 'F', 10, '');
insert basecode values ('jierep_tail', '02', '食品', '', 'T', 'F', 20, '');
insert basecode values ('jierep_tail', '03', '饮品', '', 'T', 'F', 30, '');
insert basecode values ('jierep_tail', '04', '香烟', '', 'T', 'F', 40, '');
insert basecode values ('jierep_tail', '05', '杂项', '', 'T', 'F', 50, '');
insert basecode values ('jierep_tail', '06', '其它', '', 'T', 'F', 60, '');
insert basecode values ('jierep_tail', '07', '服务费', '', 'T', 'F', 70, '');
insert basecode values ('jierep_tail', '08', '款待', '', 'T', 'F', 80, '');
insert basecode values ('jierep_tail', '09', '折扣', '', 'T', 'F', 90, '');
//
insert basecode values ('dairep_tail', '01', '人民币', '', 'T', 'F', 10, '');
insert basecode values ('dairep_tail', '02', '支票', '', 'T', 'F', 20, '');
insert basecode values ('dairep_tail', '03', '国内卡', '', 'T', 'F', 30, '');
insert basecode values ('dairep_tail', '04', '国外卡', '', 'T', 'F', 40, '');
insert basecode values ('dairep_tail', '05', '内部转账', '', 'T', 'F', 50, '');
insert basecode values ('dairep_tail', '06', '其它', '', 'T', 'F', 60, '');
insert basecode values ('dairep_tail', '07', '待转款待', '', 'T', 'F', 70, '');
//
INSERT INTO sysdefault VALUES (	'd_gl_code_paymth_edit',	'argcode',	'98');
