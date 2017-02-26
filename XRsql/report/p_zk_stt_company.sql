
if exists (select * from sysobjects where name ='p_zk_stt_company' and type ='P')
	drop proc p_zk_stt_company;
create proc p_zk_stt_company
	@begin			datetime,
	@end				datetime,
	@bno			char(10),
	@eno			char(10)
	
as
	
---------------------------------------------
-- 住店时间段房价与房数预测
---------------------------------------------
declare
	@bdate		datetime,
	@the_dat		datetime,
	@num			int,
	 @totalfee		money,
	@totalrn		money,
	@sumrm		int,
	@long			int,
	@cday			datetime,
	@b1			int,
	@b2			int,
	@b3			int,
	@b4			int,
	@temp			char(10),
	@cnum			int


create table #stt_com (
		no				char(10)			not null,
		name			varchar(50)			not null,
		sno			char(10)			not null,
		rrnum			money			not null,
		gnum			integer			not null,
		irnum			money			not null,
		inight		money			not null,
		crnum			integer			not null,
		nrnum			integer			not null,
		irate			money			not null,
		rmrev			money			not null,
		avgrate			money			not null ,
		saleid		char(20)			not null
		)
		

insert #stt_com select no,name,sno,0,0,0,0,0,0,0,0,0,saleid from guest where rtrim(sno) >= @bno 
	and rtrim(sno) <= @eno and datalength(rtrim(sno)) = 6 and 
		(no in (select cusno from ycus_xf where date >= @begin and date <= @end )
			or no in ( select agent from ycus_xf where date >= @begin and date <= @end )
				or no in ( select source from ycus_xf where date >= @begin and date <= @end))


update #stt_com set gnum = isnull((select count(distinct groupno) from ycus_xf where date >= @begin and date <= @end and (cusno = #stt_com.no or agent = #stt_com.no or source = #stt_com.no)),0)
update #stt_com set irnum = isnull((select count(distinct roomno+master) from rmuserate where date >= @begin and date <= @end and (company = #stt_com.no)),0)
update #stt_com set inight = isnull((select count(roomno) from rmuserate where date >= @begin and date <= @end and (company = #stt_com.no)),0)
update #stt_com set crnum = isnull((select count(distinct roomno+accnt) from master where arr >= @begin and arr <= @end and sta = 'X' and (cusno = #stt_com.no or agent = #stt_com.no or source = #stt_com.no)),0)
update #stt_com set crnum = crnum + isnull((select count(distinct roomno+accnt) from hmaster where arr >= @begin and arr <= @end and sta = 'X' and (cusno = #stt_com.no or agent = #stt_com.no or source = #stt_com.no)),0)
update #stt_com set nrnum = isnull((select count(distinct roomno+accnt) from master where arr >= @begin and arr <= @end and sta = 'N' and (cusno = #stt_com.no or agent = #stt_com.no or source = #stt_com.no)),0)
update #stt_com set nrnum = nrnum + isnull((select count(distinct roomno+accnt) from hmaster where arr >= @begin and arr <= @end and sta = 'N' and (cusno = #stt_com.no or agent = #stt_com.no or source = #stt_com.no)),0)
update #stt_com set rrnum = irnum + crnum + nrnum
update #stt_com set irate = irnum *100 / rrnum  where rrnum <> 0
update #stt_com set rmrev = isnull((select sum(rmrate) from rmuserate where date >= @begin and date <= @end and (company = #stt_com.no)),0)
update #stt_com set avgrate = rmrev / inight where irnum <> 0



select * from #stt_com order by sno

return


;





