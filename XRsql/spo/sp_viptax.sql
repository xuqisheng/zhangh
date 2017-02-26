/* 会费缴纳纪录表 */

if  exists(select * from sysobjects where name = "sp_viptax" and type ="U")
	  drop table sp_viptax;

create table sp_viptax
(
	no				char(20)		default ''			not null,			/*会员卡号*/
	packcode		char(10)		default ''			not null,			/*包价码*/
	inumber		integer		default 0 			not null,			/**/
	accnt			char(10)		default '' 			not null,			/*会费的入帐帐号*/
	pccode		char(5)		default ''			not null,			/*入账费用码*/
	
	class			char(1)		default '0' 		not null,			/*类别：0 -- 每日分摊；1 -- 按发生分摊；2 -- 不分摊,直接做收入*/
	arr			datetime		default getdate() not null, 			/*有效期的开始时间*/
	dep			datetime		default getdate() not null, 			/*有效期的结束时间*/
	bdate			datetime		default getdate() not null, 			/*分摊日期记录*/
	amount		money			default 0			not null,			/*包价总金额*/
	rate			money			default 0			not null,			/*每日分摊金额*/
	rate0			money			default 0			not null,
	posted		money			default 0			not null,			/*已经分摊金额*/
	paycode		char(5)		default ''			not null,			/*包价付款码*/
	
	halt			char(1)		default 'F'			not null,			/*撤消标记*/
	logdate		datetime		default getdate()	not null,   		/*输入时间*/
	empno			char(3)		default	''			not null,			/*操作员*/
	accnt1		char(10)		default '' 			null


)
exec sp_primarykey sp_viptax,no,packcode,inumber
create unique index index1 on sp_viptax(no,packcode,inumber)
;

/* 会费缴纳纪录表 */

if  exists(select * from sysobjects where name = "sp_hviptax" and type ="U")
	  drop table sp_hviptax;

create table sp_hviptax
(
	no				char(20)		default ''			not null,			/*会员卡号*/
	packcode		char(10)		default ''			not null,			/*包价码*/
	inumber		integer		default 0 			not null,			/**/
	accnt			char(10)		default '' 			not null,			/*会费的入帐帐号*/
	pccode		char(5)		default ''			not null,			/*入账费用码*/
	
	class			char(1)		default '0' 		not null,			/*类别：0 -- 每日分摊；1 -- 按发生分摊；2 -- 不分摊,直接做收入*/
	arr			datetime		default getdate() not null, 			/*有效期的开始时间*/
	dep			datetime		default getdate() not null, 			/*有效期的结束时间*/
	bdate			datetime		default getdate() not null, 			/*分摊日期记录*/
	amount		money			default 0			not null,			/*包价总金额*/
	rate			money			default 0			not null,			/*每日分摊金额*/
	rate0			money			default 0			not null,
	posted		money			default 0			not null,			/*已经分摊金额*/
	paycode		char(5)		default ''			not null,			/*包价付款码*/
	
	halt			char(1)		default 'F'			not null,			/*撤消标记*/
	logdate		datetime		default getdate()	not null,   		/*输入时间*/
	empno			char(3)		default	''			not null,			/*操作员*/
	accnt1		char(10)		default '' 			null

)
exec sp_primarykey sp_hviptax,no,packcode,inumber,bdate
create unique index index1 on sp_hviptax(no,packcode,inumber,bdate)
;

if  exists(select * from sysobjects where name = "sp_tax" and type ="U")
	  drop table sp_tax;

create table sp_tax
(
	no				char(20)		default ''			not null,			/*会员卡号*/
	packcode		char(10)		default ''			not null,			/*包价码*/
	inumber		integer		default 0 			not null,			/**/
	accnt			char(10)		default '' 			not null,			/*会费的入帐帐号*/
	pccode		char(5)		default ''			not null,			/*入账费用码*/
	
	audit			char(1)		default 'F'			not null,			/*撤消标记*/
	logdate		datetime		default getdate()	not null,   		/*输入时间*/
	empno			char(3)		default	''			not null,			/*操作员*/


)
exec sp_primarykey sp_tax,no,packcode,inumber
create unique index index1 on sp_tax(no,packcode,inumber)
;