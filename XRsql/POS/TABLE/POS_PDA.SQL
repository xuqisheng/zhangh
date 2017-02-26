/* PDA  */

if  exists(select * from sysobjects where name = "pos_pda" and type ="U")
	drop table pos_pda

create table pos_pda
(
	address		char(4)  		not null,             /*PDA地址*/
	descript		char(12)			default '' not null,  /**/
	regcode		char(4)			not null              /*餐厅号+PDA对应区域*/
)
;
exec sp_primarykey pos_pda,address
create unique index index1 on pos_pda(address)
;

/* PDA 管理餐位区域 */

if  exists(select * from sysobjects where name = "pos_reg" and type ="U")
	drop table pos_reg

create table pos_reg
(
	regcode		char(4)  		not null,             /*餐厅号+区域号*/
	descript		char(12)	default ''		not null     /**/
)
;
exec sp_primarykey pos_reg,regcode
create unique index index1 on pos_reg(regcode)
;
