if exists (select 1
            from  sysobjects
            where  id = object_id('guest_income')
            and    type = 'U')
   drop table guest_income
;

/* ============================================================ */
/*   Table: guest_income                                        */
/* ============================================================ */
create table guest_income
(
   hotelid     varchar(20)                   not null,
	no 			char(7)								not null,
	accnt			char(10)								not null,
	resno			char(10)								null,
	sta			char(1)								null,
	arr			datetime								null,
	dep			datetime								null,
	type			char(5)								null,
	roomno		char(5)								null,
	setrate		money				default 0		null,
	haccnt		char(7)								not null,
	name		   varchar(50)	 	default ''		null,	 	-- ����1
	name2		   varchar(50)	 	default ''		null,	 	-- ����2
	gstno			int				default 0		not null,
	rmnum			int				default 0		not null,
	packages		varchar(50)			default ''		not null,	-- ����
	charge		money				default 0		null,
	ref			varchar(255)						null,
   i_times     int 				default 0 		not null,   -- ס�����
   x_times     int 				default 0 		not null,   -- ȡ��Ԥ������
   n_times     int 				default 0 		not null,   -- Ӧ��δ������
   l_times     int 				default 0 		not null,   -- ��������
   i_days      int 				default 0 		not null,   -- ס������
   fb_times1   int 				default 0 		not null,   -- ��������
   en_times2   int 				default 0 		not null,   -- ���ִ���
   rm          money 			default 0 		not null, 	-- ��������
   fb       	money 			default 0 		not null, 	-- ��������
   en          money 			default 0 		not null, 	-- ��������
   mt          money 			default 0 		not null, 	-- ��������
   ot          money 			default 0 		not null, 	-- ��������
   tl          money 			default 0 		not null, 	-- ������
	sync      	char(1)			default ''		not null,	    
	lastdate		datetime					  			null,        
	cardcode char(10) null,
	cardno char(20) null
)
;
exec sp_primarykey guest_income,hotelid,accnt
create unique index index1 on guest_income(hotelid,accnt)
;
