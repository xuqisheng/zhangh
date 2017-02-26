// ------------------------------------------------------------------------------------
//		accnt bal
// ------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "act_bal" and type="U")
	drop table act_bal;

create table act_bal
(
	date 			datetime 	not null,					// 营业日期
	accnt			char(10)		not null,					// 帐号
   name     	varchar(50) default '' null,
   sta      	char(1)  	default '' not null,
   roomno   	char(5)  	default '' not null,
   oroomno	 	char(5)  	default '' not null,
   groupno  	char(10)  	default '' not null,
   arr      	datetime 					null,
   dep      	datetime 					null,
	lastd			money			default 0 not null,		// 上日
	lastc			money			default 0 not null,		// 上日
	lastbl		money			default 0 not null,		// 上日
	day01			money			default 0 not null,		// rm
	day02			money			default 0 not null,		// fd
	day03			money			default 0 not null,		// en
	day04			money			default 0 not null,		// sp
	day05			money			default 0 not null,		// bs
	day06			money			default 0 not null,		// phone
	day07			money			default 0 not null,		// ot
	day08			money			default 0 not null,		// ot
	day09			money			default 0 not null,		// ot
	day10			money			default 0 not null,		// ot
	day11			money			default 0 not null,		// ot
	day12			money			default 0 not null,		// ot
	day99			money			default 0 not null,		
	ttd01			money			default 0 not null,
	ttd02			money			default 0 not null,
	ttd03			money			default 0 not null,
	ttd04			money			default 0 not null,
	ttd05			money			default 0 not null,
	ttd06			money			default 0 not null,
	ttd07			money			default 0 not null,
	ttd08			money			default 0 not null,
	ttd09			money			default 0 not null,
	ttd10			money			default 0 not null,
	ttd11			money			default 0 not null,
	ttd12			money			default 0 not null,
	ttd99			money			default 0 not null,
	cred01		money			default 0 not null,  // rmb
	cred02		money			default 0 not null,  // chk
	cred03		money			default 0 not null,  // crd1
	cred04		money			default 0 not null,  // crd2
	cred05		money			default 0 not null,  // ot
	cred99		money			default 0 not null,
	tcrd01		money			default 0 not null,  // rmb
	tcrd02		money			default 0 not null,  // chk
	tcrd03		money			default 0 not null,  // crd1
	tcrd04		money			default 0 not null,  // crd2
	tcrd05		money			default 0 not null,  // ot
	tcrd99		money			default 0 not null,
	tilld			money			default 0 not null,
	tillc			money			default 0 not null,
	tillbl		money			default 0 not null
)
exec sp_primarykey act_bal, accnt
create unique index index1 on act_bal(accnt)
;

// ------------------------------------------------------------------------------------
//		accnt bal  --  serve    -- 间接使用
// ------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "act_bal_serve" and type="U")
	drop table act_bal_serve;

create table act_bal_serve
(
	date 			datetime 	not null,					// 营业日期
	accnt			char(10)		not null,					// 帐号
   name     	varchar(50) default '' null,
   sta      	char(1)  	default '' not null,
   roomno   	char(5)  	default '' not null,
   oroomno 		char(5)  	default '' not null,
   groupno  	char(10)  	default '' not null,
   arr      	datetime 					null,
   dep      	datetime 					null,
	lastd			money			default 0 not null,		// 上日
	lastc			money			default 0 not null,		// 上日
	lastbl		money			default 0 not null,		// 上日
	day01			money			default 0 not null,		// rm
	day02			money			default 0 not null,		// fd
	day03			money			default 0 not null,		// en
	day04			money			default 0 not null,		// sp
	day05			money			default 0 not null,		// bs
	day06			money			default 0 not null,		// phone
	day07			money			default 0 not null,		// ot
	day08			money			default 0 not null,		// ot
	day09			money			default 0 not null,		// ot
	day10			money			default 0 not null,		// ot
	day11			money			default 0 not null,		// ot
	day12			money			default 0 not null,		// ot
	day99			money			default 0 not null,		
	ttd01			money			default 0 not null,
	ttd02			money			default 0 not null,
	ttd03			money			default 0 not null,
	ttd04			money			default 0 not null,
	ttd05			money			default 0 not null,
	ttd06			money			default 0 not null,
	ttd07			money			default 0 not null,
	ttd08			money			default 0 not null,
	ttd09			money			default 0 not null,
	ttd10			money			default 0 not null,
	ttd11			money			default 0 not null,
	ttd12			money			default 0 not null,
	ttd99			money			default 0 not null,
	cred01		money			default 0 not null,  // rmb
	cred02		money			default 0 not null,  // chk
	cred03		money			default 0 not null,  // crd1
	cred04		money			default 0 not null,  // crd2
	cred05		money			default 0 not null,  // ot
	cred99		money			default 0 not null,
	tcrd01		money			default 0 not null,  // rmb
	tcrd02		money			default 0 not null,  // chk
	tcrd03		money			default 0 not null,  // crd1
	tcrd04		money			default 0 not null,  // crd2
	tcrd05		money			default 0 not null,  // ot
	tcrd99		money			default 0 not null,
	tilld			money			default 0 not null,
	tillc			money			default 0 not null,
	tillbl		money			default 0 not null
)
exec sp_primarykey act_bal_serve, accnt
create unique index index1 on act_bal_serve(accnt)
;

// ------------------------------------------------------------------------------------
//		accnt bal  - for year
// ------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "yact_bal" and type="U")
	drop table yact_bal;

create table yact_bal
(
	date 			datetime 	not null,					// 营业日期
	accnt			char(10)		not null,					// 帐号
   name     	varchar(50) default '' null,
   sta      	char(1)  	default '' not null,
   roomno   	char(5)  	default '' not null,
   oroomno 		char(5)  	default '' not null,
   groupno  	char(10)  	default '' not null,
   arr      	datetime 					null,
   dep      	datetime 					null,
	lastd			money			default 0 not null,		// 上日
	lastc			money			default 0 not null,		// 上日
	lastbl		money			default 0 not null,		// 上日
	day01			money			default 0 not null,		// rm
	day02			money			default 0 not null,		// fd
	day03			money			default 0 not null,		// en
	day04			money			default 0 not null,		// sp
	day05			money			default 0 not null,		// bs
	day06			money			default 0 not null,		// phone
	day07			money			default 0 not null,		// ot
	day08			money			default 0 not null,		// ot
	day09			money			default 0 not null,		// ot
	day10			money			default 0 not null,		// ot
	day11			money			default 0 not null,		// ot
	day12			money			default 0 not null,		// ot
	day99			money			default 0 not null,		
	ttd01			money			default 0 not null,
	ttd02			money			default 0 not null,
	ttd03			money			default 0 not null,
	ttd04			money			default 0 not null,
	ttd05			money			default 0 not null,
	ttd06			money			default 0 not null,
	ttd07			money			default 0 not null,
	ttd08			money			default 0 not null,
	ttd09			money			default 0 not null,
	ttd10			money			default 0 not null,
	ttd11			money			default 0 not null,
	ttd12			money			default 0 not null,
	ttd99			money			default 0 not null,
	cred01		money			default 0 not null,  // rmb
	cred02		money			default 0 not null,  // chk
	cred03		money			default 0 not null,  // crd1
	cred04		money			default 0 not null,  // crd2
	cred05		money			default 0 not null,  // ot
	cred99		money			default 0 not null,
	tcrd01		money			default 0 not null,  // rmb
	tcrd02		money			default 0 not null,  // chk
	tcrd03		money			default 0 not null,  // crd1
	tcrd04		money			default 0 not null,  // crd2
	tcrd05		money			default 0 not null,  // ot
	tcrd99		money			default 0 not null,
	tilld			money			default 0 not null,
	tillc			money			default 0 not null,
	tillbl		money			default 0 not null
)
exec sp_primarykey yact_bal, date, accnt
create unique index index1 on yact_bal(date, accnt)
;
