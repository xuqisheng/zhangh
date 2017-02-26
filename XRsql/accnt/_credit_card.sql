// 客人信用卡定义表
if exists(select * from sysobjects where type ="U" and name = "credit_card")
   drop table credit_card;

create table credit_card
(
	no						char(7)			not null,								/* 客人号 */
	pccode				char(3)			not null,								/* 信用卡型 */
	cardno				char(20)			not null,								/* 信用卡号 */
	expiry_date			datetime			null,										/* 信用有效期 */
	cby					char(10)			not null,								/* 工号 */
	changed				datetime			default getdate() not null,		/* 时间 */
);
exec sp_primarykey credit_card, no, pccode, cardno
create unique index index1 on credit_card(no, pccode, cardno)
;
INSERT INTO credit_card VALUES ('2000337','911','3301012092134','2038/1/1','HRY',getdate());
INSERT INTO credit_card VALUES ('2000337','912','8937458973345','2038/1/1','HRY',getdate());
