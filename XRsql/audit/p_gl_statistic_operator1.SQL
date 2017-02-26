IF OBJECT_ID('dbo.p_gl_statistic_operator1') IS NOT NULL
    DROP PROCEDURE dbo.p_gl_statistic_operator1
;
create proc p_gl_statistic_operator1
	@pc_id				char(4),
	@year					integer,
	@cat					char(30),
	@grp					char(10),
	@code					char(10),
	@para1				varchar(255),				-- revenus_room,revenus_service,-revenus_package (注意:只能有+,-或者没有)
	@para2 				varchar(255),				-- rooms_occupancy (注意:只能有+,-或者没有)
	@operator			char(1),						-- 只能有*,/,没有表示+
	@option				char(10) = 'cat'
as
declare
	@key					varchar(30),
	@operator1			money,
	@pos					integer

insert into statistic_t select distinct @pc_id,'para1',grp,code,tag,0 from statistic_t where pc_id=@pc_id
insert into statistic_t select distinct @pc_id,'para2',grp,code,tag,0 from statistic_t where pc_id=@pc_id
insert into statistic_t select distinct @pc_id,@cat,grp,code,tag,0 from statistic_t where pc_id=@pc_id

-- Para 1
while not rtrim(@para1) is null
	begin
	-- 分解para
	select @pos = charindex(',', @para1)
	if @pos = 0
		select @key = @para1, @para1 = ''
	else
		select @key = substring(@para1, 1, @pos - 1), @para1 = substring(@para1, @pos + 1, 255)
	if substring(@key, 1, 1) = '-'
		select @key = substring(@key, 2, 30), @operator1 = -1.0
	else if substring(@key, 1, 1) = '+'
		select @key = substring(@key, 2, 30), @operator1 = 1.0
	else
		select @operator1 = 1.0
	--
    update statistic_t set amount=amount+isnull(@operator1 * (select isnull(a.amount, 0) from statistic_t a where a.cat=@key and a.pc_id=statistic_t.pc_id and 
        a.grp=statistic_t.grp and a.code=statistic_t.code),0) where cat='para1' and pc_id=@pc_id
	end

-- Para 2
while not rtrim(@para2) is null
	begin
	-- 分解para
	select @pos = charindex(',', @para2)
	if @pos = 0
		select @key = @para2, @para2 = ''
	else
		select @key = substring(@para2, 1, @pos - 1), @para2 = substring(@para2, @pos + 1, 255)
	if substring(@key, 1, 1) = '-'
		select @key = substring(@key, 2, 30), @operator1 = -1
	else if substring(@key, 1, 1) = '+'
		select @key = substring(@key, 2, 30), @operator1 = 1
	else
		select @operator1 = 1.0
	--
    update statistic_t set amount=amount+isnull(@operator1 * (select isnull(a.amount, 0) from statistic_t a where a.cat=@key and a.pc_id=statistic_t.pc_id and 
        a.grp=statistic_t.grp and a.code=statistic_t.code),0) where cat='para2' and pc_id=@pc_id
	end
-- 计算


if @operator in ('/', '%')
	begin
    delete from statistic_t where cat='para2' and amount=0 and pc_id=@pc_id
    update statistic_t set amount=(select isnull(a.amount, 0) from statistic_t a where a.pc_id=statistic_t.pc_id and a.grp=statistic_t.grp and
       a.code=statistic_t.code and a.cat='para1')/(select b.amount from statistic_t b where b.pc_id=statistic_t.pc_id and b.grp=statistic_t.grp and
       b.code=statistic_t.code and b.cat='para2') where cat=@cat and pc_id=@pc_id and exists(select 1 from statistic_t c where c.pc_id=statistic_t.pc_id and c.grp=statistic_t.grp and
       c.code=statistic_t.code and c.cat='para2' and c.amount>0)

	if @operator = '%'
		update statistic_t set amount=amount*100 where cat=@cat and pc_id=@pc_id
    end
else if @operator = '*'
    update statistic_t set amount=(select isnull(a.amount, 0) from statistic_t a where a.pc_id=statistic_t.pc_id and a.grp=statistic_t.grp and
     a.code=statistic_t.code and a.cat='para1')*(select isnull(b.amount, 0) from statistic_t b where b.pc_id=statistic_t.pc_id and b.grp=statistic_t.grp and
     b.code=statistic_t.code and b.cat='para2') where cat=@cat and pc_id=@pc_id
else
    update statistic_t set amount=isnull((select isnull(a.amount, 0) from statistic_t a where a.pc_id=statistic_t.pc_id and a.grp=statistic_t.grp and
     a.code=statistic_t.code and a.cat='para1')+(select isnull(b.amount, 0) from statistic_t b where b.pc_id=statistic_t.pc_id and b.grp=statistic_t.grp and
     b.code=statistic_t.code and b.cat='para2'),0) where cat=@cat and pc_id=@pc_id
delete from statistic_t where cat<>@cat and pc_id=@pc_id
;
