CREATE TABLE int_menu (
	inumber float,
	int_menu char(10),
	pos_menu char(10),
	accnt char(10),
	paycode char(5),
	sta char(1));

exec   sp_primarykey int_menu, inumber,int_menu
create unique index index1 on int_menu(inumber,int_menu)
;