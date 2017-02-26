
if exists (select * from sysobjects where name ='p_zk_for07' and type ='P')
	drop proc p_zk_for07;
create proc p_zk_for07
	@begin			datetime,
	@end				datetime,
	@type				char(200),
	@mkt			char(3),
	@pc_id			char(4),
	@longs			char(100)
	
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
	@b5			int,
	@b6			int,
	@b7			int,
	@b8			int,
	@b9			int,
	@b10			int,
	@temp			char(10),
	@cnum			int


select @temp = substring(@longs,1,charindex(',',@longs) )
select @b1 = convert(integer,substring(@temp,1,charindex('-',@temp) -1))
select @b2 = convert(integer,substring(@temp,charindex('-',@temp) +1 ,charindex(',',@temp) -charindex('-',@temp) -1))
select @longs = substring(@longs,charindex(',',@longs)+1,100)
if charindex(',',@longs) = 0
	begin
	select @cnum = 1 
	select @b2 = 999
	goto beg
	end
select @temp = substring(@longs,1,charindex(',',@longs) )
select @b3 = convert(integer,substring(@temp,1,charindex('-',@temp) -1))
select @b4 = convert(integer,substring(@temp,charindex('-',@temp) +1 ,charindex(',',@temp) -charindex('-',@temp) -1))
select @longs = substring(@longs,charindex(',',@longs)+1,100)
if charindex(',',@longs) = 0
	begin
	select @cnum = 2 
	select @b4 = 999
	goto beg
	end
select @temp = substring(@longs,1,charindex(',',@longs) )
select @b5 = convert(integer,substring(@temp,1,charindex('-',@temp) -1))
select @b6 = convert(integer,substring(@temp,charindex('-',@temp) +1 ,charindex(',',@temp) -charindex('-',@temp) -1))
select @longs = substring(@longs,charindex(',',@longs)+1,100)
if charindex(',',@longs) = 0
	begin
	select @cnum = 3 
	select @b6 = 999
	goto beg
	end
select @temp = substring(@longs,1,charindex(',',@longs) )
select @b7 = convert(integer,substring(@temp,1,charindex('-',@temp) -1))
select @b8 = convert(integer,substring(@temp,charindex('-',@temp) +1 ,charindex(',',@temp) -charindex('-',@temp) -1))
select @longs = substring(@longs,charindex(',',@longs)+1,100)
if charindex(',',@longs) = 0
	begin
	select @cnum = 4 
	select @b8 = 999
	goto beg
	end
select @temp = substring(@longs,1,charindex(',',@longs) )
select @b9 = convert(integer,substring(@temp,1,charindex('-',@temp) -1))
select @b10 = convert(integer,substring(@temp,charindex('-',@temp) +1 ,charindex(',',@temp) -charindex('-',@temp) -1))
select @longs = substring(@longs,charindex(',',@longs)+1,100)
//if charindex(',',@longs) = 0
	begin
	select @cnum = 5 
	select @b10 = 999
	goto beg
	end


beg:

--
select @bdate = bdate1 from sysdata
select @long = datediff(dd,@begin,@end)

delete from for07 where pc_id = @pc_id

					
while @long >= 0
	begin
	if @cnum >= 1
		begin
		insert for07 select convert(char(10),dateadd(day,@long,@begin),11), '1.Length of Stay '+rtrim(convert(char(10),@b1))+'-'+rtrim(convert(char(10),@b2)),'ADR',type,0,0,10 ,@pc_id from typim where charindex(','+rtrim(type)+',',','+rtrim(@type)+',')>0 or @type = '%'
		insert for07 select convert(char(10),dateadd(day,@long,@begin),11), '1.Length of Stay '+rtrim(convert(char(10),@b1))+'-'+rtrim(convert(char(10),@b2)),'Rooms Sold',type,0,0,20 ,@pc_id from typim where charindex(','+rtrim(type)+',',','+rtrim(@type)+',')>0 or @type = '%'
		end
	if @cnum >= 2
		begin
		insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'2.Length of Stay '+rtrim(convert(char(10),@b3))+'-'+rtrim(convert(char(10),@b4)),'ADR',type,0,0,30 ,@pc_id from typim where charindex(','+rtrim(type)+',',','+rtrim(@type)+',')>0 or @type = '%'
		insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'2.Length of Stay '+rtrim(convert(char(10),@b3))+'-'+rtrim(convert(char(10),@b4)),'Rooms Sold',type,0,0,40 ,@pc_id from typim where charindex(','+rtrim(type)+',',','+rtrim(@type)+',')>0 or @type = '%'
		end
	if @cnum >= 3
		begin
		insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'3.Length of Stay '+rtrim(convert(char(10),@b5))+'-'+rtrim(convert(char(10),@b6)),'ADR',type,0,0,50 ,@pc_id from typim where charindex(','+rtrim(type)+',',','+rtrim(@type)+',')>0 or @type = '%'
		insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'3.Length of Stay '+rtrim(convert(char(10),@b5))+'-'+rtrim(convert(char(10),@b6)),'Rooms Sold',type,0,0,60 ,@pc_id from typim where charindex(','+rtrim(type)+',',','+rtrim(@type)+',')>0 or @type = '%'
		end
	if @cnum >= 4
		begin
		insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'4.Length of Stay '+rtrim(convert(char(10),@b7))+'-'+rtrim(convert(char(10),@b8)),'ADR',type,0,0,70 ,@pc_id from typim where charindex(','+rtrim(type)+',',','+rtrim(@type)+',')>0 or @type = '%'
		insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'4.Length of Stay '+rtrim(convert(char(10),@b7))+'-'+rtrim(convert(char(10),@b8)),'Rooms Sold',type,0,0,80 ,@pc_id from typim where charindex(','+rtrim(type)+',',','+rtrim(@type)+',')>0 or @type = '%'
		end
	if @cnum >= 5
		begin
		insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'5.Length of Stay '+rtrim(convert(char(10),@b9))+'-'+rtrim(convert(char(10),@b10)),'ADR',type,0,0,90 ,@pc_id from typim where charindex(','+rtrim(type)+',',','+rtrim(@type)+',')>0 or @type = '%'
		insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'5.Length of Stay '+rtrim(convert(char(10),@b9))+'-'+rtrim(convert(char(10),@b10)),'Rooms Sold',type,0,0,100 ,@pc_id from typim where charindex(','+rtrim(type)+',',','+rtrim(@type)+',')>0 or @type = '%'
		end
	
	insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'Grand Total','ADR','总计:',0,0,110 ,@pc_id
	insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'Grand Total','Rooms Sold','总计:',0,0,120 ,@pc_id
	insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'Grand Total','OCC(%)','总计:',0,0,130 ,@pc_id
	insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'Grand Total','Average LOS','总计:',0,0,140 ,@pc_id
	insert for07 select convert(char(10),dateadd(day,@long,@begin),11),'Grand Total','Rooms Rem.','总计:',0,0,150 ,@pc_id
	select @long = @long - 1
	end

select @long = datediff(dd,@begin,@end)
while @long >= 0
	begin
	select @cday = dateadd(day,@long,@begin)
	if @cday<=@bdate
		begin
		if @cnum >= 1
			begin
			update for07 set a = (select isnull(count(1),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b1 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b2 and market like @mkt and type like @type and type = for07.rmtype ) where date=convert(char(10),@cday,11) and pc_id=@pc_id  and days='1.Length of Stay '+rtrim(convert(char(10),@b1))+'-'+rtrim(convert(char(10),@b2)) and type='Rooms Sold'
			update for07 set a = a + (select isnull(count(1),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b1 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b2 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='1.Length of Stay '+rtrim(convert(char(10),@b1))+'-'+rtrim(convert(char(10),@b2)) and type='Rooms Sold'
			update for07 set a = (select isnull(sum(setrate),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b1 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b2 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='1.Length of Stay '+rtrim(convert(char(10),@b1))+'-'+rtrim(convert(char(10),@b2)) and type='ADR'
			update for07 set a = a + (select isnull(sum(setrate),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b1 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b2 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='1.Length of Stay '+rtrim(convert(char(10),@b1))+'-'+rtrim(convert(char(10),@b2)) and type='ADR'
			update for07 set b = a where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='1.Length of Stay '+rtrim(convert(char(10),@b1))+'-'+rtrim(convert(char(10),@b2)) and type='ADR'
			update for07 set a = a / isnull(((select isnull(count(1),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b1 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b2 and market like @mkt and type like @type )+(select isnull(count(1),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b1 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b2 and market like @mkt and type like @type )),1) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='1.Length of Stay '+rtrim(convert(char(10),@b1))+'-'+rtrim(convert(char(10),@b2)) and type='ADR'  and a<>0
			end
		if @cnum >= 2
			begin
			update for07 set a = (select isnull(count(1),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b3 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b4 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='2.Length of Stay '+rtrim(convert(char(10),@b3))+'-'+rtrim(convert(char(10),@b4)) and type='Rooms Sold'
			update for07 set a = a + (select isnull(count(1),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b3 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b4 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='2.Length of Stay '+rtrim(convert(char(10),@b3))+'-'+rtrim(convert(char(10),@b4)) and type='Rooms Sold'
			update for07 set a = (select isnull(sum(setrate),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b3 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b4 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='2.Length of Stay '+rtrim(convert(char(10),@b3))+'-'+rtrim(convert(char(10),@b4)) and type='ADR'
			update for07 set a = a + (select isnull(sum(setrate),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b3 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b4 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='2.Length of Stay '+rtrim(convert(char(10),@b3))+'-'+rtrim(convert(char(10),@b4)) and type='ADR'
			update for07 set b = a where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='2.Length of Stay '+rtrim(convert(char(10),@b3))+'-'+rtrim(convert(char(10),@b4)) and type='ADR'
			update for07 set a = a / isnull(((select isnull(count(1),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b3 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b4 and market like @mkt and type like @type )+(select isnull(count(1),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b3 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b4 and market like @mkt and type like @type )),1) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='2.Length of Stay '+rtrim(convert(char(10),@b3))+'-'+rtrim(convert(char(10),@b4)) and type='ADR'  and a<>0
			end
		if @cnum >= 3
			begin
			update for07 set a = (select isnull(count(1),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b5 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b6 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='3.Length of Stay '+rtrim(convert(char(10),@b5))+'-'+rtrim(convert(char(10),@b6)) and type='Rooms Sold'
			update for07 set a = a + (select isnull(count(1),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b5 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b6 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='3.Length of Stay '+rtrim(convert(char(10),@b5))+'-'+rtrim(convert(char(10),@b6)) and type='Rooms Sold'
			update for07 set a = (select isnull(sum(setrate),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b5 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b6 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='3.Length of Stay '+rtrim(convert(char(10),@b5))+'-'+rtrim(convert(char(10),@b6)) and type='ADR'
			update for07 set a = a + (select isnull(sum(setrate),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b5 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b6 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='3.Length of Stay '+rtrim(convert(char(10),@b5))+'-'+rtrim(convert(char(10),@b6)) and type='ADR'
			update for07 set b = a where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='3.Length of Stay '+rtrim(convert(char(10),@b5))+'-'+rtrim(convert(char(10),@b6)) and type='ADR'
			update for07 set a = a / isnull(((select isnull(count(1),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b5 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b6 and market like @mkt and type like @type )+(select isnull(count(1),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b5 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b6 and market like @mkt and type like @type )),1) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='3.Length of Stay '+rtrim(convert(char(10),@b5))+'-'+rtrim(convert(char(10),@b6)) and type='ADR'  and a<>0
			end
		if @cnum >= 4
			begin
			update for07 set a = (select isnull(count(1),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b7 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b8 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='4.Length of Stay '+rtrim(convert(char(10),@b7))+'-'+rtrim(convert(char(10),@b8)) and type='Rooms Sold'
			update for07 set a = a + (select isnull(count(1),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b7 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b8 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='4.Length of Stay '+rtrim(convert(char(10),@b7))+'-'+rtrim(convert(char(10),@b8)) and type='Rooms Sold'
			update for07 set a = (select isnull(sum(setrate),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b7 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b8 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='4.Length of Stay '+rtrim(convert(char(10),@b7))+'-'+rtrim(convert(char(10),@b8)) and type='ADR'
			update for07 set a = a + (select isnull(sum(setrate),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b7 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b8 and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='4.Length of Stay '+rtrim(convert(char(10),@b7))+'-'+rtrim(convert(char(10),@b8)) and type='ADR'
			update for07 set b = a where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='4.Length of Stay '+rtrim(convert(char(10),@b7))+'-'+rtrim(convert(char(10),@b8)) and type='ADR'
			update for07 set a = a / isnull(((select isnull(count(1),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b7 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b8 and market like @mkt and type like @type )+(select isnull(count(1),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b7 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b8 and market like @mkt and type like @type )),1) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='4.Length of Stay '+rtrim(convert(char(10),@b7))+'-'+rtrim(convert(char(10),@b8)) and type='ADR'  and a<>0
			end
		if @cnum >= 5
			begin
			update for07 set a = (select isnull(count(1),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b9  and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='5.Length of Stay '+rtrim(convert(char(10),@b9))+'-'+rtrim(convert(char(10),@b10)) and type='Rooms Sold'
			update for07 set a = a + (select isnull(count(1),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b9  and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='5.Length of Stay '+rtrim(convert(char(10),@b9))+'-'+rtrim(convert(char(10),@b10)) and type='Rooms Sold'
			update for07 set a = (select isnull(sum(setrate),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b9  and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='5.Length of Stay '+rtrim(convert(char(10),@b9))+'-'+rtrim(convert(char(10),@b10)) and type='ADR'
			update for07 set a = a + (select isnull(sum(setrate),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b9  and market like @mkt and type like @type and type = for07.rmtype ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='5.Length of Stay '+rtrim(convert(char(10),@b9))+'-'+rtrim(convert(char(10),@b10)) and type='ADR'
			update for07 set b = a where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='5.Length of Stay '+rtrim(convert(char(10),@b9))+'-'+rtrim(convert(char(10),@b10)) and type='ADR'
			update for07 set a = a / isnull(((select isnull(count(1),0) from master where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b9 and market like @mkt and type like @type )+(select isnull(count(1),0) from hmaster where type = for07.rmtype and sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b9 and market like @mkt and type like @type )),1) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='5.Length of Stay '+rtrim(convert(char(10),@b9))+'-'+rtrim(convert(char(10),@b10)) and type='ADR'  and a<>0
			end

		
		update for07 set a=(select isnull(sum(datediff(dd,convert(char,arr,112),dep)),0) from master where sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday  and market like @mkt and type like @type ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='Grand Total' and type='Average LOS'
		update for07 set a=a+(select isnull(sum(datediff(dd,convert(char,arr,112),dep)),0) from hmaster where sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and market like @mkt and type like @type) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='Grand Total' and type='Average LOS'
		update for07 set a=a/isnull(((select isnull(count(1),0) from master where sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and market like @mkt and type like @type )+(select isnull(count(1),0) from hmaster where sta not in ('N','X') and  class='F' and  master=accnt and  convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and market like @mkt and type like @type )),1) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='Grand Total' and type='Average LOS'  and a<>0
		end
	else
		begin
		if @cnum >= 1
			begin
			update for07 set a = (select count(distinct accnt) from rsvsrc_detail where type=for07.rmtype and convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b1 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b2 and market like @mkt and type like @type) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='1.Length of Stay '+rtrim(convert(char(10),@b1))+'-'+rtrim(convert(char(10),@b2)) and type='Rooms Sold'
			update for07 set a = (select isnull(sum(rmrate)/isnull(count(accnt),1),0) from rsvsrc_detail where type=for07.rmtype and convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b1 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b2 and market like @mkt and type like @type) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='1.Length of Stay '+rtrim(convert(char(10),@b1))+'-'+rtrim(convert(char(10),@b2)) and type='ADR'
			update for07 set b = a where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='1.Length of Stay '+rtrim(convert(char(10),@b1))+'-'+rtrim(convert(char(10),@b2)) and type='ADR'
			end
		if @cnum >= 2
			begin
			update for07 set a = (select count(distinct accnt) from rsvsrc_detail where type=for07.rmtype and convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b3 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b4 and market like @mkt and type like @type) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='2.Length of Stay '+rtrim(convert(char(10),@b3))+'-'+rtrim(convert(char(10),@b4)) and type='Rooms Sold'
			update for07 set a = (select isnull(sum(rmrate)/isnull(count(accnt),1),0) from rsvsrc_detail where type=for07.rmtype and convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b3 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b4 and market like @mkt and type like @type) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='2.Length of Stay '+rtrim(convert(char(10),@b3))+'-'+rtrim(convert(char(10),@b4)) and type='ADR'
			update for07 set b = a where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='2.Length of Stay '+rtrim(convert(char(10),@b3))+'-'+rtrim(convert(char(10),@b4)) and type='ADR'
			end
		if @cnum >= 3
			begin
			update for07 set a = (select count(distinct accnt) from rsvsrc_detail where type=for07.rmtype and convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b5 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b4 and market like @mkt and type like @type) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='3.Length of Stay '+rtrim(convert(char(10),@b5))+'-'+rtrim(convert(char(10),@b6)) and type='Rooms Sold'
			update for07 set a = (select isnull(sum(rmrate)/isnull(count(accnt),1),0) from rsvsrc_detail where type=for07.rmtype and convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b5 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b4 and market like @mkt and type like @type) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='3.Length of Stay '+rtrim(convert(char(10),@b5))+'-'+rtrim(convert(char(10),@b6)) and type='ADR'
			update for07 set b = a where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='3.Length of Stay '+rtrim(convert(char(10),@b5))+'-'+rtrim(convert(char(10),@b6)) and type='ADR'
			end
		if @cnum >= 4
			begin
			update for07 set a = (select count(distinct accnt) from rsvsrc_detail where type=for07.rmtype and convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b7 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b8 and market like @mkt and type like @type) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='4.Length of Stay '+rtrim(convert(char(10),@b7))+'-'+rtrim(convert(char(10),@b8)) and type='Rooms Sold'
			update for07 set a = (select isnull(sum(rmrate)/isnull(count(accnt),1),0) from rsvsrc_detail where type=for07.rmtype and convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b7 and DATEDIFF(dd,convert(char,arr,112),dep)<=@b8 and market like @mkt and type like @type) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='4.Length of Stay '+rtrim(convert(char(10),@b7))+'-'+rtrim(convert(char(10),@b8)) and type='ADR'
			update for07 set b = a where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='4.Length of Stay '+rtrim(convert(char(10),@b7))+'-'+rtrim(convert(char(10),@b8)) and type='ADR'
			end
		if @cnum >= 5
			begin
			update for07 set a = (select count(distinct accnt) from rsvsrc_detail where type=for07.rmtype and convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b9 and market like @mkt and type like @type) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='5.Length of Stay '+rtrim(convert(char(10),@b9))+'-'+rtrim(convert(char(10),@b10)) and type='Rooms Sold'
			update for07 set a = (select isnull(sum(rmrate)/isnull(count(accnt),1),0) from rsvsrc_detail where type=for07.rmtype and convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and DATEDIFF(dd,convert(char,arr,112),dep)>=@b9 and market like @mkt and type like @type) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='5.Length of Stay '+rtrim(convert(char(10),@b9))+'-'+rtrim(convert(char(10),@b10)) and type='ADR'
			update for07 set b = a where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='5.Length of Stay '+rtrim(convert(char(10),@b9))+'-'+rtrim(convert(char(10),@b10)) and type='ADR'
			end
		
		update for07 set a = (select isnull(count(1),0) from rsvsrc_detail where convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday  and market like @mkt and type like @type ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='Grand Total' and type='Average LOS' and pc_id=@pc_id
		update for07 set a = a / (select isnull(count(distinct accnt),1) from rsvsrc_detail where convert(char,arr,112)<=convert(char,@cday,112) and dep>=@cday and market like @mkt and type like @type ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='Grand Total' and type='Average LOS' and a<>0	 and pc_id=@pc_id
		end
	update for07 set a=(select sum(a) from for07 where days like '%Length of Stay%' and type = 'Rooms Sold' and date =convert(char(10),@cday,11) and pc_id=@pc_id ) where date = convert(char(10),@cday,11) and days='Grand Total' and type = 'Rooms Sold' and pc_id=@pc_id
	update for07 set a=isnull((select sum(b) from for07 where days like '%Length of Stay%' and type = 'ADR' and date =convert(char(10),@cday,11) and pc_id=@pc_id )/(select a from for07 where date = convert(char(10),@cday,11) and days='Grand Total' and type = 'Rooms Sold' and a<>0 and pc_id=@pc_id),0) where date = convert(char(10),@cday,11) and days='Grand Total' and type = 'ADR' and pc_id=@pc_id 
	select @sumrm=count(1) from rmsta where not (sta='O' and futbegin<=dateadd(dd,0,@cday) and futend>=dateadd(dd,0,@cday))
	update for07 set a =(select sum(a) / @sumrm from for07 where type='Rooms Sold' and date =convert(char(10),@cday,11) and days like '%Length of Stay%' and pc_id=@pc_id )*100 where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='Grand Total' and type='OCC(%)' and pc_id=@pc_id
	update for07 set a =(select @sumrm - sum(a) from for07 where type='Rooms Sold' and date =convert(char(10),@cday,11) and days like '%Length of Stay%' and pc_id=@pc_id ) where pc_id=@pc_id  and date=convert(char(10),@cday,11)  and days='Grand Total' and type='Rooms Rem.' and pc_id=@pc_id
	select @long = @long - 1
	end

select * from for07 where pc_id = @pc_id order by date,sequence 




;




