/* PDA  */

if  exists(select * from sysobjects where name = "pos_pda" and type ="U")
	drop table pos_pda

create table pos_pda
(
	address		char(4)  		not null,             /*PDA��ַ*/
	descript		char(12)			default '' not null,  /**/
	regcode		char(4)			not null              /*������+PDA��Ӧ����*/
)
;
exec sp_primarykey pos_pda,address
create unique index index1 on pos_pda(address)
;

/* PDA ������λ���� */

if  exists(select * from sysobjects where name = "pos_reg" and type ="U")
	drop table pos_reg

create table pos_reg
(
	regcode		char(4)  		not null,             /*������+�����*/
	descript		char(12)	default ''		not null     /**/
)
;
exec sp_primarykey pos_reg,regcode
create unique index index1 on pos_reg(regcode)
;
