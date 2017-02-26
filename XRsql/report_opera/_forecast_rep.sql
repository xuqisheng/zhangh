if object_id('forecast_rep') is not null
	drop table forecast_rep;

create table forecast_rep(
	pc_id			char(4)							not null,
	date			datetime								 null,
	code			char(10)			default ''	not null,
	descript		varchar(30) 	default '' 	not null,
	accnt			char(10) 		default '' 	not null,
	type			char(3)			default '' 	not null,
	quantity		integer			default 0	not null,
	gstno			integer			default 0	not null,
	rate			money				default 0	not null,
	ratecode		char(10) 		default '' 	not null,
	src			char(3)			default '' 	not null,
	market		char(3)			default '' 	not null,
	packages		varchar(20)		default '' 	not null,
	amenities	varchar(30)		default '' 	not null
);

EXEC sp_primarykey 'forecast_rep', pc_id,date,code;
CREATE UNIQUE INDEX index1 ON forecast_rep(pc_id,date,code);

// ´úÂëÁÐ±í
if object_id('fct_order') is not null
	drop table fct_order;

create table fct_order(
	pc_id			char(4)							not null,
	code			char(10)			default ''	not null,
	order_		integer			default 0	not null,
);

EXEC sp_primarykey 'fct_order', pc_id,code,order_;
CREATE UNIQUE INDEX index1 ON fct_order(pc_id,order_);


