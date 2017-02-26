IF OBJECT_ID('dbo.p_clg_report_pick_up') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_report_pick_up
;
create proc p_clg_report_pick_up
	@pc_id	char(4),
	@modu_id	char(2),
	@type		char(2), --'NT','RT','RV'
	@date1	datetime --传入的起始日期参数
as
declare
@thisday	datetime,
@fstday	datetime,
@lastday	datetime,
@value	money,
@amount	money,
@market	char(3),
@count	int,
@total	money,
@charge1_sum				money,
@charge2_sum				money,
@charge3_sum				money,
@charge4_sum				money,
@charge5_sum				money,
@charge1						money,
@charge2						money,
@charge3						money,
@charge4						money,
@charge5						money,
@package_i					money,
@package_e					money,
@operation					char(58),
@pcid						char(4),
@mdi_id						integer,
@packages					char(50),
@accnt						char(10),
@rmrate						money,
@qtrate						money,
@setrate						money,
@ratecode					char(10),
@quantity					money,
@gstno						integer,
@ret							integer,
@id							integer    -- rsvsrc
--如果输入的日期是当月，则显示日期为当日至月底，如输入为其他未到的月份，则显示全月的数据
--统计数据包括在住客人及将到客人
--房晚数统计的是当日过夜的房数；平均房价也是当日过夜的房的均价；总收入统计实际发生的收入

--declare c_src cursor for select market from rsvsrc where datediff(dd,@thisday,begin_)<=0 and datediff(dd,@thisday,end_)>0
declare c_mkt cursor for select code from mktcode order by sequence
select @fstday=bdate from sysdata

if datediff(mm,@date1,@fstday)<0
	select @fstday=firstday,@lastday=lastday from firstdays where datediff(yy,lastday,@date1)=0 and datediff(mm,lastday,@date1)=0
else
	select @lastday=lastday from firstdays where datediff(yy,lastday,@fstday)=0 and datediff(mm,lastday,@fstday)=0


delete from pmktrep where pc_id=@pc_id and modu_id=@modu_id
select @thisday = @fstday
while datediff(dd,@thisday,@lastday)>=0
begin
	insert into pmktrep(pc_id,modu_id,date) select @pc_id,@modu_id,@thisday
	--insert into #pickup select @thisday,grp,code,null,null,null from mktcode order by grp,sequence
	select @count=0,@total=0
	open c_mkt
	fetch c_mkt into @market
	while @@sqlstatus=0
	begin
		select @count=@count+1, @value=0
		--房晚，平均房价
		if @type='NT' --rm nights
			begin
				select @value=isnull(sum(a.quantity),0) from rsvsrc a --change1:no is null,not 0
				 where datediff(dd,@thisday,a.begin_)<=0 and datediff(dd,@thisday,a.end_)>0 and a.market=@market and a.roomno = ''
				select @value=@value+count(distinct a.roomno) from rsvsrc a
				 where a.begin_<=@thisday and a.end_>@thisday and a.market=@market and a.roomno <> '' and a.type not in (select type from typim where tag = 'P')
			end
		else if @type='RT' --average rate
			begin
				--select @value=isnull(sum(a.quantity),0) from rsvsrc a,master b --change2:same with 1
				-- where a.accnt=b.accnt and datediff(dd,@thisday,a.begin_)<=0 and datediff(dd,@thisday,a.end_)>0 and b.market=@market and a.roomno = ''
				--select @value=@value+count(distinct a.roomno) from rsvsrc a,master b
				-- where a.accnt=b.accnt and a.begin_<=@thisday and a.end_>@thisday and b.market=@market and a.roomno <> ''
				--计算平均房价，同住房只算一间，但是两个记录的房价要相加！！！
				--select @value=sum(a.quantity*a.rate) from rsvsrc a,master b
				-- where a.accnt=b.accnt and datediff(dd,@thisday,a.begin_)<=0 and datediff(dd,@thisday,a.end_)>0 and b.market=@market
				--2008.6.2
                select @value=sum(a.quantity*a.rate) from rsvsrc_detail a
                    where datediff(dd,@thisday,a.date_)=0 and a.market=@market and a.type not in (select type from typim where tag = 'P')
			end
		else if @type='RV' --total revenue=room revenue+packages
			begin

				--select @value=isnull(sum(a.charge),0) from account a,rsvsrc b,master c where a.accnt=b.accnt and b.accnt=c.accnt and datediff(dd,@thisday,a.log_date)=0
 				--	and datediff(dd,@thisday,b.begin_)<=0 and datediff(dd,@thisday,b.end_)>0 and c.market=@market
				--	and a.pccode < '9' and (a.crradjt in ('AD', '') or (a.crradjt in ('LT', 'LA') and a.tofrom= '')) --change5:revenue
				select @value=sum(a.quantity*a.trate) from rsvsrc_detail a
				 where datediff(dd,@thisday,a.date_)=0 and a.market=@market and a.type not in (select type from typim where tag = 'P')
			end

	--	update #pickup set nights=@value,avgrate=@avgrate,revenue=@revenue where day=@thisday and market=@market
		if @value>0
			begin
			select @total=@total+@value
			if @count=1
				update pmktrep set v1=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=2
				update pmktrep set v2=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=3
				update pmktrep set v3=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=4
				update pmktrep set v4=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=5
				update pmktrep set v5=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=6
				update pmktrep set v6=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=7
				update pmktrep set v7=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=8
				update pmktrep set v8=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=9
				update pmktrep set v9=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=10
				update pmktrep set v10=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=11
				update pmktrep set v11=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=12
				update pmktrep set v12=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=13
				update pmktrep set v13=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=14
				update pmktrep set v14=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=15
				update pmktrep set v15=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=16
				update pmktrep set v16=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=17
				update pmktrep set v17=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=18
				update pmktrep set v18=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=19
				update pmktrep set v19=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=20
				update pmktrep set v20=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=21
				update pmktrep set v21=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=22
				update pmktrep set v22=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=23
				update pmktrep set v23=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=24
				update pmktrep set v24=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=25
				update pmktrep set v25=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=26
				update pmktrep set v26=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=27
				update pmktrep set v27=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=28
				update pmktrep set v28=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=29
				update pmktrep set v29=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=30
				update pmktrep set v30=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=31
				update pmktrep set v31=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=32
				update pmktrep set v32=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=33
				update pmktrep set v33=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=34
				update pmktrep set v34=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=35
				update pmktrep set v35=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=36
				update pmktrep set v36=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=37
				update pmktrep set v37=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=38
				update pmktrep set v38=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=39
				update pmktrep set v39=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=40
				update pmktrep set v40=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=41
				update pmktrep set v41=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=42
				update pmktrep set v42=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=43
				update pmktrep set v43=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=44
				update pmktrep set v44=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=45
				update pmktrep set v45=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=46
				update pmktrep set v46=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=47
				update pmktrep set v47=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=48
				update pmktrep set v48=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=49
				update pmktrep set v49=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			else if @count=50
				update pmktrep set v50=@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
			end
		fetch c_mkt into @market
	end
	close c_mkt

	update pmktrep set vtl=@total where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
	--
	--
	select @thisday=dateadd(dd,1,@thisday)
end

-- change4 average total need divide
	if @type='RT'
		begin
		insert into pmktrep select @pc_id,@modu_id,'2050-01-01',
			sum(v1),sum(v2),sum(v3),sum(v4),sum(v5),sum(v6),sum(v7),sum(v8),sum(v9),sum(v10),
			sum(v11),sum(v12),sum(v13),sum(v14),sum(v15),sum(v16),sum(v17),sum(v18),sum(v19),sum(v20),
			sum(v21),sum(v22),sum(v23),sum(v24),sum(v25),sum(v26),sum(v27),sum(v28),sum(v29),sum(v30),
			sum(v31),sum(v32),sum(v33),sum(v34),sum(v35),sum(v36),sum(v37),sum(v38),sum(v39),sum(v40),
			sum(v41),sum(v42),sum(v43),sum(v44),sum(v45),sum(v46),sum(v47),sum(v48),sum(v49),sum(v50),sum(vtl),'' from pmktrep where pc_id=@pc_id and modu_id=@modu_id
		insert into pmktrep select @pc_id,@modu_id,'2050-01-02',0,0,0,0,0,0,0,0,0,0
		,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'' --房晚合计
		select @thisday = @fstday
		while datediff(dd,@thisday,@lastday)>=0
		begin
			select @count=0,@total=0
			open c_mkt
			fetch c_mkt into @market
			while @@sqlstatus=0
			begin
				select @count=@count+1, @value=0
				select @value=isnull(sum(a.quantity),0) from rsvsrc a --change1:no is null,not 0
				 where datediff(dd,@thisday,a.begin_)<=0 and datediff(dd,@thisday,a.end_)>0 and a.market=@market and a.roomno = ''
				select @value=@value+count(distinct a.roomno) from rsvsrc a
				 where a.begin_<=@thisday and a.end_>@thisday and a.market=@market and a.roomno <> '' and a.type not in (select type from typim where tag = 'P')

				select @total=@total+@value
				if @value>0
				begin
					if @count=1
					begin
						update pmktrep set v1=v1/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v1=v1+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=2
					begin
						update pmktrep set v2=v2/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v2=v2+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=3
					begin
						update pmktrep set v3=v3/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v3=v3+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=4
					begin
						update pmktrep set v4=v4/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v4=v4+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=5
					begin
						update pmktrep set v5=v5/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v5=v5+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=6
					begin
						update pmktrep set v6=v6/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v6=v6+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=7
					begin
						update pmktrep set v7=v7/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v7=v7+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=8
					begin
						update pmktrep set v8=v8/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v8=v8+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=9
					begin
						update pmktrep set v9=v9/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v9=v9+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=10
					begin
						update pmktrep set v10=v10/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v10=v10+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=11
					begin
						update pmktrep set v11=v11/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v11=v11+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=12
					begin
						update pmktrep set v12=v12/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v12=v12+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=13
					begin
						update pmktrep set v13=v13/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v13=v13+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=14
					begin
						update pmktrep set v14=v14/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v14=v14+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=15
					begin
						update pmktrep set v15=v15/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v15=v15+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=16
					begin
						update pmktrep set v16=v16/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v16=v16+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=17
					begin
						update pmktrep set v17=v17/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v17=v17+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=18
					begin
						update pmktrep set v18=v18/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v18=v18+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=19
					begin
						update pmktrep set v19=v19/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v19=v19+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=20
					begin
						update pmktrep set v20=v20/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v20=v20+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=21
					begin
						update pmktrep set v21=v21/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v21=v21+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=22
					begin
						update pmktrep set v22=v22/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v22=v22+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=23
					begin
						update pmktrep set v23=v23/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v23=v23+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=24
					begin
						update pmktrep set v24=v24/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v24=v24+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=25
					begin
						update pmktrep set v25=v25/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v25=v25+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=26
					begin
						update pmktrep set v26=v26/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v26=v26+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=27
					begin
						update pmktrep set v27=v27/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v27=v27+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=28
					begin
						update pmktrep set v28=v28/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v28=v28+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=29
					begin
						update pmktrep set v29=v29/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v29=v29+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=30
					begin
						update pmktrep set v30=v30/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v30=v30+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=31
					begin
						update pmktrep set v31=v31/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v31=v31+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=32
					begin
						update pmktrep set v32=v32/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v32=v32+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=33
					begin
						update pmktrep set v33=v33/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v33=v33+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=34
					begin
						update pmktrep set v34=v34/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v34=v34+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=35
					begin
						update pmktrep set v35=v35/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v35=v35+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=36
					begin
						update pmktrep set v36=v36/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v36=v36+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=37
					begin
						update pmktrep set v37=v37/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v37=v37+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=38
					begin
						update pmktrep set v38=v38/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v38=v38+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=39
					begin
						update pmktrep set v39=v39/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v39=v39+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=40
					begin
						update pmktrep set v40=v40/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v40=v40+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=41
					begin
						update pmktrep set v41=v41/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v41=v41+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=42
					begin
						update pmktrep set v42=v42/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v42=v42+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=43
					begin
						update pmktrep set v43=v43/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v43=v43+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=44
					begin
						update pmktrep set v44=v44/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v44=v44+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=45
					begin
						update pmktrep set v45=v45/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v45=v45+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=46
					begin
						update pmktrep set v46=v46/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v46=v46+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=47
					begin
						update pmktrep set v47=v47/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v47=v47+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=48
					begin
						update pmktrep set v48=v48/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v48=v48+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=49
					begin
						update pmktrep set v49=v49/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v49=v49+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end
					else if @count=50
					begin
						update pmktrep set v50=v50/@value where pc_id=@pc_id and modu_id=@modu_id and date=@thisday
						update pmktrep set v50=v50+@value where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'
					end

				end
				fetch c_mkt into @market
			end
			close c_mkt

			if @total>0
				update pmktrep set vtl=vtl/@total where pc_id=@pc_id and modu_id=@modu_id and date=@thisday

			--
			select @thisday=dateadd(dd,1,@thisday)
		end

		update pmktrep set vtl=v1+v2+v3+v4+v5+v6+v7+v8+v9+v10+v11+v12+v13+v14+v15+v16+v17+v18+v19+v20+v21+v22+v23+v24+v25+
						v26+v27+v28+v29+v30+v31+v32+v33+v34+v35+v36+v37+v38+v39+v40+v41+v42+v43+v44+v45+v46+v47+v48+v49+v50
			where pc_id=@pc_id and modu_id=@modu_id and date='2050-01-02'

		insert pmktrep select @pc_id,@modu_id,'2050-01-03',v1=a.v1/b.v1,v2=a.v2/b.v2,
		v3=a.v3/b.v3,v4=a.v4/b.v4,v5=a.v5/b.v5,v6=a.v6/b.v6,v7=a.v7/b.v7,v8=a.v8/b.v8,v9=a.v9/b.v9,v10=a.v10/b.v10,
		v11=a.v11/b.v11,v12=a.v12/b.v12,v13=a.v13/b.v13,v14=a.v14/b.v14,v15=a.v15/b.v15,v16=a.v16/b.v16,v17=a.v17/b.v17,
		v18=a.v18/b.v18,v19=a.v19/b.v19,v20=a.v20/b.v20,v21=a.v21/b.v21,v22=a.v22/b.v22,v23=a.v23/b.v23,v24=a.v24/b.v24,
		v25=a.v25/b.v25,v26=a.v26/b.v26,v27=a.v27/b.v27,v28=a.v28/b.v28,v29=a.v29/b.v29,v30=a.v30/b.v30,v31=a.v31/b.v31,
		v32=a.v32/b.v32,v33=a.v33/b.v33,v34=a.v34/b.v34,v35=a.v35/b.v35,v36=a.v36/b.v36,v37=a.v37/b.v37,v38=a.v38/b.v38,
		v39=a.v39/b.v39,v40=a.v40/b.v40,v41=a.v41/b.v41,v42=a.v42/b.v42,v43=a.v43/b.v43,v44=a.v44/b.v44,v45=a.v45/b.v45,
		v46=a.v46/b.v46,v47=a.v47/b.v47,v48=a.v48/b.v48,v49=a.v49/b.v49,v50=a.v50/b.v50,vtl=a.vtl/b.vtl,''
		from pmktrep a,pmktrep b where b.pc_id=a.pc_id and b.modu_id=a.modu_id
		and a.pc_id=@pc_id and a.modu_id=@modu_id and a.date='2050-01-01' and b.date='2050-01-02'
		delete from pmktrep where pc_id=@pc_id and modu_id=@modu_id and (date='2050-01-01' or date='2050-01-02')
		update pmktrep set sdate=convert(char(10),date,111) where date<>'2050-01-03'
		update pmktrep set sdate='TOTAL' where date='2050-01-03'
		end

deallocate cursor c_mkt
--select * from #pickup
;