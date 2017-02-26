if object_id('mktrep') is not null
	drop table mktrep;

create table mktrep(
	pc_id				char(4)						not null,
	date				char(10)					  	    null,
	grp				char(10)		default ''  not null,
	item				varchar(20) default '' 	not null,

	mkt01 			money 		default 0 	not null,	mkt02 			money 		default 0 	not null,
	mkt03 			money			default 0 	not null,	mkt04 			money			default 0 	not null,
	mkt05 			money			default 0 	not null,	mkt06 			money			default 0 	not null,
	mkt07	 			money			default 0 	not null,	mkt08 			money			default 0 	not null,
	mkt09 			money			default 0 	not null,	mkt10 			money			default 0 	not null,
	mkt11 			money 		default 0 	not null,	mkt12 			money 		default 0 	not null,
	mkt13 			money			default 0 	not null,	mkt14 			money			default 0 	not null,
	mkt15 			money			default 0 	not null,	mkt16 			money			default 0 	not null,
	mkt17	 			money			default 0 	not null,	mkt18 			money			default 0 	not null,
	mkt19 			money			default 0 	not null,	mkt20 			money			default 0 	not null,
	mkt21 			money 		default 0 	not null,	mkt22 			money 		default 0 	not null,
	mkt23 			money			default 0 	not null,	mkt24 			money			default 0 	not null,
	mkt25 			money			default 0 	not null,	mkt26 			money			default 0 	not null,
	mkt27	 			money			default 0 	not null,	mkt28 			money			default 0 	not null,
	mkt29 			money			default 0 	not null,	mkt30 			money			default 0 	not null,
	mkt31 			money 		default 0 	not null,	mkt32 			money 		default 0 	not null,
	mkt33 			money			default 0 	not null,	mkt34 			money			default 0 	not null,
	mkt35 			money			default 0 	not null,	mkt36 			money			default 0 	not null,
	mkt37	 			money			default 0 	not null,	mkt38 			money			default 0 	not null,
	mkt39 			money			default 0 	not null,	mkt40 			money			default 0 	not null,

	mkttt 			money			default 0 	not null
)
;

