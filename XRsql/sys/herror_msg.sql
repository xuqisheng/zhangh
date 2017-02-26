--------------------------------------------------------------------------------
--	去掉唯一索引，因为可能需要存储多行 ?? 
--		不行，因为系统里调用过多，修改困难；也许使用另外一张表吧。
--------------------------------------------------------------------------------
if object_id('herror_msg') is not null
	drop table herror_msg;
CREATE TABLE herror_msg 
(
    pc_id   char(4)     NOT NULL,
    modu_id char(2)     NOT NULL,
    ret     int         NOT NULL,
    msg     varchar(70) DEFAULT '' NOT NULL
);
exec sp_primarykey herror_msg, pc_id, modu_id;
CREATE unique INDEX herror_msg ON dbo.herror_msg(pc_id ,modu_id)
;

if object_id('p_hry_error_msg') is not null
	drop proc p_hry_error_msg;
create proc p_hry_error_msg
   @pc_id   char(4),
   @ret     int,
   @msg     varchar(70),
   @modu_id char(2) = '01'
as

if exists (select pc_id from herror_msg where pc_id = @pc_id and modu_id = @modu_id )
   update herror_msg set ret = @ret,msg = @msg where pc_id = @pc_id and modu_id = @modu_id
else
   insert herror_msg values (@pc_id,@modu_id,@ret,@msg)

return 0
;
