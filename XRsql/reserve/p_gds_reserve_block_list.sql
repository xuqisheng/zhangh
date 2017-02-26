
// 注意， rsvdtl 中的 accnt 不是 master 的 accnt, 而是 rsvsaccnt-saccnt !!!

drop  proc p_gds_reserve_block_list;

create  proc p_gds_reserve_block_list
	@rm_type    	varchar(255) = '',
	@time				datetime = '2000/01/01',
	@class			char(1) = ''

as

create table #blocklist(
	accnt		char(10),
	name		varchar(60),
	sta		char(1),
	class		char(1),
	type		char(5),
	roomno	char(5),
	s_time	datetime,
	e_time	datetime,
	quan		int
)


insert #blocklist
	select a.accnt, '', b.sta, '', a.type, a.roomno, a.begin_, a.end_, a.quantity
		from rsvdtl a, master b
			where a.accnt=b.accnt and b.class<>'F'
					and charindex(b.sta,'RCGI')>0
					and a.end_ > @time
					and a.begin_ <= @time
					and (rtrim(@rm_type) is null or charindex(a.type+'_', @rm_type) > 0)
					and (rtrim(@class) is null
							or @class='G'
							or (@class='R' and charindex(b.sta,'RCG')>0)
							or (@class='D' and charindex(b.sta,'RCG')>0 and datediff(dd,b.arr,@time)=0)
							)


insert #blocklist
	select a.accnt, '', b.sta, b.class, a.type, a.roomno, a.begin_, a.end_, a.quantity
		from rsvdtl a, master b
			where a.accnt=b.accnt and b.class='F'
					and charindex(b.sta,'RCGI')>0
					and a.end_ > @time
					and a.begin_ <= @time
					and rtrim(b.groupno) is null
					and (rtrim(@rm_type) is null or charindex(a.type+'_', @rm_type) > 0)
					and (rtrim(@class) is null
							or (@class='Z' and b.class='Z')
							or (@class='L' and b.class='L')
							or (@class='T' and charindex(b.class,'Z,L')=0)
							or (@class='R' and charindex(b.sta,'RCG')>0)
							or (@class='D' and charindex(b.sta,'RCG')>0 and datediff(dd,b.arr,@time)=0)
							)

update #blocklist set #blocklist.name=rtrim(b.name)
	from master a, guest b
		where a.accnt=#blocklist.accnt and a.haccnt=b.no 

select * from #blocklist order by type, s_time
return 0
;
