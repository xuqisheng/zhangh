
// 调整 ygststa 某日的数据
drop proc p_aaa;
create proc p_aaa
	@date		datetime
as

update ygststa set dtc=(select sum(a.dtc) from ygststa a where a.date=@date and a.gclass='4' and a.order_='04' and a.nation<>'')
	where date=@date and gclass='4' and order_='04' and nation=''
update ygststa set dtc=(select sum(a.dtc) from ygststa a where a.date=@date and a.gclass='4' and ((a.order_='04' and a.nation='') or (a.order_<'04' and nation<>'')))
	where date=@date and gclass='4' and order_='' and nation=''
update ygststa set dtc=(select sum(a.dtc) from ygststa a where a.date=@date and a.gclass in ('2','3','4') and a.order_='')
	where date=@date and gclass='1' and order_='' and nation=''

update ygststa set dgc=(select sum(a.dgc) from ygststa a where a.date=@date and a.gclass='4' and a.order_='04' and a.nation<>'')
	where date=@date and gclass='4' and order_='04' and nation=''
update ygststa set dgc=(select sum(a.dgc) from ygststa a where a.date=@date and a.gclass='4' and ((a.order_='04' and a.nation='') or (a.order_<'04' and nation<>'')))
	where date=@date and gclass='4' and order_='' and nation=''
update ygststa set dgc=(select sum(a.dgc) from ygststa a where a.date=@date and a.gclass in ('2','3','4') and a.order_='')
	where date=@date and gclass='1' and order_='' and nation=''

update ygststa set dtt=(select sum(a.dtt) from ygststa a where a.date=@date and a.gclass='4' and a.order_='04' and a.nation<>'')
	where date=@date and gclass='4' and order_='04' and nation=''
update ygststa set dtt=(select sum(a.dtt) from ygststa a where a.date=@date and a.gclass='4' and ((a.order_='04' and a.nation='') or (a.order_<'04' and nation<>'')))
	where date=@date and gclass='4' and order_='' and nation=''
update ygststa set dtt=(select sum(a.dtt) from ygststa a where a.date=@date and a.gclass in ('2','3','4') and a.order_='')
	where date=@date and gclass='1' and order_='' and nation=''

update ygststa set dgt=(select sum(a.dgt) from ygststa a where a.date=@date and a.gclass='4' and a.order_='04' and a.nation<>'')
	where date=@date and gclass='4' and order_='04' and nation=''
update ygststa set dgt=(select sum(a.dgt) from ygststa a where a.date=@date and a.gclass='4' and ((a.order_='04' and a.nation='') or (a.order_<'04' and nation<>'')))
	where date=@date and gclass='4' and order_='' and nation=''
update ygststa set dgt=(select sum(a.dgt) from ygststa a where a.date=@date and a.gclass in ('2','3','4') and a.order_='')
	where date=@date and gclass='1' and order_='' and nation=''

update ygststa set mtc=(select sum(a.mtc) from ygststa a where a.date=@date and a.gclass='4' and a.order_='04' and a.nation<>'')
	where date=@date and gclass='4' and order_='04' and nation=''
update ygststa set mtc=(select sum(a.mtc) from ygststa a where a.date=@date and a.gclass='4' and ((a.order_='04' and a.nation='') or (a.order_<'04' and nation<>'')))
	where date=@date and gclass='4' and order_='' and nation=''
update ygststa set mtc=(select sum(a.mtc) from ygststa a where a.date=@date and a.gclass in ('2','3','4') and a.order_='')
	where date=@date and gclass='1' and order_='' and nation=''

update ygststa set mgc=(select sum(a.mgc) from ygststa a where a.date=@date and a.gclass='4' and a.order_='04' and a.nation<>'')
	where date=@date and gclass='4' and order_='04' and nation=''
update ygststa set mgc=(select sum(a.mgc) from ygststa a where a.date=@date and a.gclass='4' and ((a.order_='04' and a.nation='') or (a.order_<'04' and nation<>'')))
	where date=@date and gclass='4' and order_='' and nation=''
update ygststa set mgc=(select sum(a.mgc) from ygststa a where a.date=@date and a.gclass in ('2','3','4') and a.order_='')
	where date=@date and gclass='1' and order_='' and nation=''

update ygststa set mtt=(select sum(a.mtt) from ygststa a where a.date=@date and a.gclass='4' and a.order_='04' and a.nation<>'')
	where date=@date and gclass='4' and order_='04' and nation=''
update ygststa set mtt=(select sum(a.mtt) from ygststa a where a.date=@date and a.gclass='4' and ((a.order_='04' and a.nation='') or (a.order_<'04' and nation<>'')))
	where date=@date and gclass='4' and order_='' and nation=''
update ygststa set mtt=(select sum(a.mtt) from ygststa a where a.date=@date and a.gclass in ('2','3','4') and a.order_='')
	where date=@date and gclass='1' and order_='' and nation=''


update ygststa set mgt=(select sum(a.mgt) from ygststa a where a.date=@date and a.gclass='4' and a.order_='04' and a.nation<>'')
	where date=@date and gclass='4' and order_='04' and nation=''
update ygststa set mgt=(select sum(a.mgt) from ygststa a where a.date=@date and a.gclass='4' and ((a.order_='04' and a.nation='') or (a.order_<'04' and nation<>'')))
	where date=@date and gclass='4' and order_='' and nation=''
update ygststa set mgt=(select sum(a.mgt) from ygststa a where a.date=@date and a.gclass in ('2','3','4') and a.order_='')
	where date=@date and gclass='1' and order_='' and nation=''


update ygststa set ytc=(select sum(a.ytc) from ygststa a where a.date=@date and a.gclass='4' and a.order_='04' and a.nation<>'')
	where date=@date and gclass='4' and order_='04' and nation=''
update ygststa set ytc=(select sum(a.ytc) from ygststa a where a.date=@date and a.gclass='4' and ((a.order_='04' and a.nation='') or (a.order_<'04' and nation<>'')))
	where date=@date and gclass='4' and order_='' and nation=''
update ygststa set ytc=(select sum(a.ytc) from ygststa a where a.date=@date and a.gclass in ('2','3','4') and a.order_='')
	where date=@date and gclass='1' and order_='' and nation=''

update ygststa set ygc=(select sum(a.ygc) from ygststa a where a.date=@date and a.gclass='4' and a.order_='04' and a.nation<>'')
	where date=@date and gclass='4' and order_='04' and nation=''
update ygststa set ygc=(select sum(a.ygc) from ygststa a where a.date=@date and a.gclass='4' and ((a.order_='04' and a.nation='') or (a.order_<'04' and nation<>'')))
	where date=@date and gclass='4' and order_='' and nation=''
update ygststa set ygc=(select sum(a.ygc) from ygststa a where a.date=@date and a.gclass in ('2','3','4') and a.order_='')
	where date=@date and gclass='1' and order_='' and nation=''

update ygststa set ytt=(select sum(a.ytt) from ygststa a where a.date=@date and a.gclass='4' and a.order_='04' and a.nation<>'')
	where date=@date and gclass='4' and order_='04' and nation=''
update ygststa set ytt=(select sum(a.ytt) from ygststa a where a.date=@date and a.gclass='4' and ((a.order_='04' and a.nation='') or (a.order_<'04' and nation<>'')))
	where date=@date and gclass='4' and order_='' and nation=''
update ygststa set ytt=(select sum(a.ytt) from ygststa a where a.date=@date and a.gclass in ('2','3','4') and a.order_='')
	where date=@date and gclass='1' and order_='' and nation=''

update ygststa set ygt=(select sum(a.ygt) from ygststa a where a.date=@date and a.gclass='4' and a.order_='04' and a.nation<>'')
	where date=@date and gclass='4' and order_='04' and nation=''
update ygststa set ygt=(select sum(a.ygt) from ygststa a where a.date=@date and a.gclass='4' and ((a.order_='04' and a.nation='') or (a.order_<'04' and nation<>'')))
	where date=@date and gclass='4' and order_='' and nation=''
update ygststa set ygt=(select sum(a.ygt) from ygststa a where a.date=@date and a.gclass in ('2','3','4') and a.order_='')
	where date=@date and gclass='1' and order_='' and nation=''

return 
;


//
//exec p_aaa '2003.10.31';
//select * from ygststa where date=@date order by gclass, order_, nation;
