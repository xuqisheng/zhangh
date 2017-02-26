/* 压缩AR账务使用的临时表 */

if exists (select * from sysobjects where name ='ar_compress' and type ='U')
	drop table ar_compress;
create table ar_compress
(
	pc_id			char(4)		not null, 
	mdi_id		integer		not null, 
	pccode		char(5)		not null,
	bdate			datetime		not null,
	ref1			char(10)		not null,
	ref2			char(50)		not null,
	ar_subtotal	char(1)		not null,
	quantity		money			default 0 not null,				/* 数量 */
	charge		money			default 0 not null,				/* 借方数,记录客人消费 */
	charge1		money			default 0 not null,				/* 借方数(基本费) */
	charge2		money			default 0 not null,				/* 借方数(优惠费) */
	charge3		money			default 0 not null,				/* 借方数(服务费) */
	charge4		money			default 0 not null,				/* 借方数(税、附加费) */
	charge5		money			default 0 not null,				/* 借方数(其它) */
	package_d	money			default 0 not null,				/* 实际使用Package的金额,对应Package_Detail.charge */
	package_c	money			default 0 not null,				/* Package允许消费的金额,对应Package.credit,Package_Detail.credit */
	package_a	money			default 0 not null,				/* Package的实际金额,对应Package.amount */
	credit		money			default 0 not null,				/* 贷方数,记录客人定金及结算款 */
	charge9		money			default 0 not null,				/* 借方数,记录已经结算的客人消费 */
	credit9		money			default 0 not null				/* 贷方数,记录已经结算的客人定金及结算款 */
)
create index index1 on ar_compress(pc_id, mdi_id)
;


