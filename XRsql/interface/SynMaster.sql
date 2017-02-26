---------------------------------------------------------------------
--	研发一部 配合 研发二部 crs 项目 - simon 2006.4.5
---------------------------------------------------------------------


---------------------------------------------------------------------
--	同步标记表 - 吴健儿
---------------------------------------------------------------------
if exists(select * from sysobjects where name = 'synmaster')
	drop table synmaster;
create table synmaster
(
	masteraccnt     varchar(10)  								not null,
	belongtable     varchar(50)  	default 'master' 		not null,
	operateflag     char(1)   		default 'Y' 			not null   --Y表示需要更新,N表示不需更新
);
exec   sp_primarykey synmaster, belongtable, masteraccnt
create unique index index1 on synmaster(belongtable, masteraccnt)
;



//---------------------------------------------------------------------
//--	PMS 系统处理- 在 master update 触发器里面增加如下语句
//--	注意:
//--		在判断是否需要登记 synmaster, 可以采取判断某些列才处理的方式，
//--		具体就是通过 update(??) 来进行 
//---------------------------------------------------------------------
//declare	@masteraccnt 	char(10)
//select @masteraccnt = accnt from inserted where exp_s3 like 'CRS:%'
//if @@rowcount>0 and update(logmark) // and (update(type) or update(room) or update(ratecode) or update(market) or update(???)) 
//begin
//	if not exists(select 1 from synmaster where belongtable='master' and masteraccnt=@masteraccnt)
//		insert synmaster(masteraccnt, belongtable, operateflag) values(@masteraccnt, 'master', 'Y')
//	else
//		update synmaster set operateflag='Y' where belongtable='master' and masteraccnt=@masteraccnt 
//end
//
//