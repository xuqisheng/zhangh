IF OBJECT_ID('dbo.p_clg_report_room_rtcode') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_report_room_rtcode
;
create proc p_clg_report_room_rtcode
	@pc_id	char(4),
	@modu_id	char(2),
	@type		char(1),
	@date1	datetime, --起始日期，最多一个月
	@date2	datetime,
	@mode		char(2)
as
declare
@thisday	datetime,
@fstday	datetime,
@lastday	datetime,
@value	money,
@total	money,
@grp		char(10),
@code		char(10),
@count	int
--如果输入日期范围大于一个月，则从开始日期显示一个月
--从ymktsummaryrep统计，只统计历史数据。


if @type='R'
	declare c_rate cursor for select a.grp,a.code from mktsummaryrep a,rmratecode b where a.class=@type and b.halt='F' and a.code=b.code and a.grp=b.cat order by grp,code
else if @type='S'
	declare c_rate cursor for select a.grp,a.code from mktsummaryrep a,srccode b where a.class='S' and a.code=b.code and a.grp=b.grp order by grp,code
else if @type='M'
	declare c_rate cursor for select a.grp,a.code from mktsummaryrep a,mktcode b where a.class='M' and a.code=b.code and a.grp=b.grp order by grp,code
else if @type='C'
	declare c_rate cursor for select a.grp,a.code from mktsummaryrep a,basecode b where a.class='C' and b.cat='channel' and a.code=b.code and a.grp=b.grp order by grp,code
else if @type='L'
	declare c_rate cursor for select '',a.code from mktsummaryrep a,restype b where a.class='L' and a.code=b.code order by code

select @fstday=@date1
if datediff(dd,@date1,@date2) > 30
	select @lastday=dateadd(dd,30,@date1)
else
	select @lastday=@date2

delete from praterep where pc_id=@pc_id and modu_id=@modu_id
open c_rate
fetch c_rate into @grp,@code
while @@sqlstatus = 0
	begin
	insert into praterep(pc_id,modu_id,grp,code) values(@pc_id,@modu_id,@grp,@code)
	select @thisday = @fstday,@count=0,@total=0
	while datediff(dd,@thisday,@lastday)>=0
		begin
		select @count=@count+1
		select @value=0
		if @mode='rn'
			select @value=rquan from ymktsummaryrep where datediff(dd,@thisday,date)=0 and class=@type and grp=@grp and code=@code
		else if @mode='av'
			--begin
			--select @value=rquan from ymktsummaryrep where datediff(dd,@thisday,date)=0 and class=@type and grp=@grp and code=@code
			--if @value > 0
			--	select @value=sum(rate) from ymktsummaryrep_detail where datediff(dd,@thisday,date)=0 and sta='I' and ratecode=@code
			select @value=rincome from ymktsummaryrep where datediff(dd,@thisday,date)=0 and class=@type and grp=@grp and code=@code
	--end
		else if @mode='rv'
			select @value=tincome from ymktsummaryrep where datediff(dd,@thisday,date)=0 and class=@type and grp=@grp and code=@code

		if @value>0
			begin
			select @total=@total+@value
			if @count=1
				update praterep set v1=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=2
				update praterep set v2=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=3
				update praterep set v3=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=4
				update praterep set v4=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=5
				update praterep set v5=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=6
				update praterep set v6=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=7
				update praterep set v7=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=8
				update praterep set v8=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=9
				update praterep set v9=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=10
				update praterep set v10=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=11
				update praterep set v11=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=12
				update praterep set v12=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=13
				update praterep set v13=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=14
				update praterep set v14=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=15
				update praterep set v15=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=16
				update praterep set v16=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=17
				update praterep set v17=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=18
				update praterep set v18=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=19
				update praterep set v19=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=20
				update praterep set v20=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=21
				update praterep set v21=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=22
				update praterep set v22=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=23
				update praterep set v23=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=24
				update praterep set v24=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=25
				update praterep set v25=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=26
				update praterep set v26=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=27
				update praterep set v27=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=28
				update praterep set v28=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=29
				update praterep set v29=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=30
				update praterep set v30=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			else if @count=31
				update praterep set v31=@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
			end
		select @thisday=dateadd(dd,1,@thisday)
		end
	update praterep set vtl=@total where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
	fetch c_rate into @grp,@code
	end
close c_rate

-- change4 average total need divide
if @mode='av'
	begin
	insert into praterep select @pc_id,@modu_id,'ZZZ','','T',
		sum(v1),sum(v2),sum(v3),sum(v4),sum(v5),sum(v6),sum(v7),sum(v8),sum(v9),sum(v10),
		sum(v11),sum(v12),sum(v13),sum(v14),sum(v15),sum(v16),sum(v17),sum(v18),sum(v19),sum(v20),
		sum(v21),sum(v22),sum(v23),sum(v24),sum(v25),sum(v26),sum(v27),sum(v28),sum(v29),sum(v30),
		sum(v31),sum(vtl) from praterep where pc_id=@pc_id and modu_id=@modu_id
	insert into praterep select @pc_id,@modu_id,'ZZZ','',@type,0,0,0,0,0,0,0,0,0,0
	,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 --房晚合计
	open c_rate
	fetch c_rate into @grp,@code
	while @@sqlstatus=0
	begin
		select @count=0,@total=0
		select @thisday = @fstday
		while datediff(dd,@thisday,@lastday)>=0
		begin
			select @count=@count+1
			select @value=0
			select @value=rquan from ymktsummaryrep where datediff(dd,@thisday,date)=0 and class=@type and grp=@grp and code=@code

			select @total=@total+@value
			if @value>0
			begin
				if @count=1
				begin
					update praterep set v1=v1/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v1=v1+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=2
				begin
					update praterep set v2=v2/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v2=v2+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=3
				begin
					update praterep set v3=v3/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v3=v3+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=4
				begin
					update praterep set v4=v4/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v4=v4+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=5
				begin
					update praterep set v5=v5/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v5=v5+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=6
				begin
					update praterep set v6=v6/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v6=v6+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=7
				begin
					update praterep set v7=v7/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v7=v7+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=8
				begin
					update praterep set v8=v8/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v8=v8+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=9
				begin
					update praterep set v9=v9/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v9=v9+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=10
				begin
					update praterep set v10=v10/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v10=v10+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=11
				begin
					update praterep set v11=v11/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v11=v11+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=12
				begin
					update praterep set v12=v12/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v12=v12+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=13
				begin
					update praterep set v13=v13/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v13=v13+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=14
				begin
					update praterep set v14=v14/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v14=v14+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=15
				begin
					update praterep set v15=v15/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v15=v15+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=16
				begin
					update praterep set v16=v16/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v16=v16+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=17
				begin
					update praterep set v17=v17/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v17=v17+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=18
				begin
					update praterep set v18=v18/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v18=v18+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=19
				begin
					update praterep set v19=v19/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v19=v19+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=20
				begin
					update praterep set v20=v20/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v20=v20+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=21
				begin
					update praterep set v21=v21/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v21=v21+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=22
				begin
					update praterep set v22=v22/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v22=v22+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=23
				begin
					update praterep set v23=v23/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v23=v23+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=24
				begin
					update praterep set v24=v24/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v24=v24+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=25
				begin
					update praterep set v25=v25/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v25=v25+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=26
				begin
					update praterep set v26=v26/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v26=v26+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=27
				begin
					update praterep set v27=v27/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v27=v27+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=28
				begin
					update praterep set v28=v28/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v28=v28+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=29
				begin
					update praterep set v29=v29/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v29=v29+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=30
				begin
					update praterep set v30=v30/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v30=v30+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
				else if @count=31
				begin
					update praterep set v31=v31/@value where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code
					update praterep set v31=v31+@value where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type
				end
			end
			select @thisday=dateadd(dd,1,@thisday)
		end
		if @total>0
			update praterep set vtl=vtl/@total where pc_id=@pc_id and modu_id=@modu_id and grp=@grp and code=@code

		fetch c_rate into @grp,@code
	end
	close c_rate



	update praterep set vtl=v1+v2+v3+v4+v5+v6+v7+v8+v9+v10+v11+v12+v13+v14+v15+v16+v17+v18+v19+v20+v21+v22+v23+v24+v25+
					v26+v27+v28+v29+v30+v31
		where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and code=@type

	insert praterep select @pc_id,@modu_id,'ZZZ','','TOTAL',v1=a.v1/b.v1,v2=a.v2/b.v2,
	v3=a.v3/b.v3,v4=a.v4/b.v4,v5=a.v5/b.v5,v6=a.v6/b.v6,v7=a.v7/b.v7,v8=a.v8/b.v8,v9=a.v9/b.v9,v10=a.v10/b.v10,
	v11=a.v11/b.v11,v12=a.v12/b.v12,v13=a.v13/b.v13,v14=a.v14/b.v14,v15=a.v15/b.v15,v16=a.v16/b.v16,v17=a.v17/b.v17,
	v18=a.v18/b.v18,v19=a.v19/b.v19,v20=a.v20/b.v20,v21=a.v21/b.v21,v22=a.v22/b.v22,v23=a.v23/b.v23,v24=a.v24/b.v24,
	v25=a.v25/b.v25,v26=a.v26/b.v26,v27=a.v27/b.v27,v28=a.v28/b.v28,v29=a.v29/b.v29,v30=a.v30/b.v30,v31=a.v31/b.v31,
	vtl=a.vtl/b.vtl
	from praterep a,praterep b where b.pc_id=a.pc_id and b.modu_id=a.modu_id
	and a.pc_id=@pc_id and a.modu_id=@modu_id and a.grp='ZZZ' and b.grp='ZZZ' and a.code='T' and b.code=@type
	delete from praterep where pc_id=@pc_id and modu_id=@modu_id and grp='ZZZ' and (code='T' or code=@type)
end

deallocate cursor c_rate
if @type='R'
	update praterep set des=descript from rmratecode where pc_id=@pc_id and modu_id=@modu_id and praterep.code=rmratecode.code
else if @type='S'
	update praterep set des=descript from srccode where pc_id=@pc_id and modu_id=@modu_id and praterep.code=srccode.code
else if @type='M'
	update praterep set des=descript from mktcode where pc_id=@pc_id and modu_id=@modu_id and praterep.code=mktcode.code
else if @type='C'
	update praterep set des=descript from basecode where pc_id=@pc_id and modu_id=@modu_id and praterep.code=basecode.code
else if @type='L'
	update praterep set des=descript from restype where pc_id=@pc_id and modu_id=@modu_id and praterep.code=restype.code

--select * from praterep;
