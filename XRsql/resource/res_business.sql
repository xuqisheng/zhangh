if exists (select 1 from  sysobjects  where  id = object_id('res_sort')  and    type = 'U')
   drop table res_sort
;
create table res_sort
(
    sortid        char(10)               not null,
    name          varchar(60)            not null,
    ename         varchar(60)            null    ,
    chkmode       char(3)                default 'qty' not null,
    maintain      int                    default 1 not null,
    remark        varchar(255)           null    ,
    moduleids     varchar(255)           null   
)
exec sp_primarykey res_sort,sortid
create unique index index1 on res_sort(sortid)
;

if exists (select 1 from  sysobjects  where  id = object_id('res_plu')  and    type = 'U')
   drop table res_plu
;
create table res_plu
(
    resid         char(10)               not null,
    sortid        char(10)               not null,
    name          char(60)               not null,
    ename         char(60)               not null,
    sta           char(1)                not null,
    qty           int                    default 1 not null,
    chkmode       char(3)                not null,
    price         money                  default 0 not null,
    stime         datetime               not null,
    etime         datetime               not null,
    period        int                    default 0 not null,
    deptno        char(3)                null    ,
    keeperid      char(3)                null    ,
    keeper        char(10)               null    ,
    pccode        char(3)                not null,
    servcode      char(1)                not null,
    pccode0       char(3)                null    ,
    place         varchar(100)           null    ,
    affair_folio  char(10)               null    ,
    disptype      char(1)                null    ,
    dwname        varchar(50)            null    ,
    remark        varchar(255)           null    ,
    picture       varchar(60)            null    ,
    always        char(1)                default 'T' null    
)
exec sp_primarykey res_plu,resid
create unique index index1 on res_plu(resid)
;

if exists (select 1 from  sysobjects  where  id = object_id('res_av')  and    type = 'U')
   drop table res_av
;
create table res_av
(
    folio         char(10)               not null,
    reftype       char(3)                not null,
    reffolio      char(10)               not null,
    reffolio1     char(10)               null    ,
    accnt         char(10)               not null,
    accnt1        char(10)               not null,
    sta           char(1)                not null,
    resid         char(10)               not null,
    qty           int                    default 1 not null,
    bdate         datetime               not null,
    stime         datetime               not null,
    etime         datetime               not null,
    sfield        int                    not null,
    efield        int                    not null,
    sfieldtime    varchar(16)            not null,
    efieldtime    varchar(16)            not null,
    summary       varchar(255)           null    ,
    worker        varchar(30)            null    ,
    amount        money                  default 0 not null,
    amount0       money                  not null,
    reason        char(3)                not null,
    flag          char(1)                default 'F' not null,
    date          datetime               null    ,
    modu_id       char(2)                null    ,
    resby         char(10)               null    ,
    resbyname     varchar(12)            null    ,
    reserved      datetime               null    ,
    cby           char(10)               null    ,
    cbyname       varchar(12)            null    ,
    cbytime       datetime               null    ,
    logmark       int                    default 0 not null,
    avid          int                    null    
)
exec sp_primarykey res_av,folio
create unique index index1 on res_av(folio)
;

if exists (select 1 from  sysobjects  where  id = object_id('res_av_h')  and    type = 'U')
   drop table res_av_h
;
create table res_av_h
(
    folio         char(10)               not null,
    reftype       char(3)                not null,
    reffolio      char(10)               not null,
    reffolio1     char(10)               null    ,
    accnt         char(10)               not null,
    accnt1        char(10)               not null,
    sta           char(1)                not null,
    resid         char(10)               not null,
    qty           int                    default 1 not null,
    bdate         datetime               not null,
    stime         datetime               not null,
    etime         datetime               not null,
    sfield        int                    not null,
    efield        int                    not null,
    sfieldtime    varchar(16)            not null,
    efieldtime    varchar(16)            not null,
    summary       varchar(255)           null    ,
    worker        varchar(30)            null    ,
    amount        money                  default 0 not null,
    amount0       money                  not null,
    reason        char(3)                not null,
    flag          char(1)                default 'F' not null,
    date          datetime               null    ,
    modu_id       char(2)                null    ,
    resby         char(10)               null    ,
    resbyname     varchar(12)            null    ,
    reserved      datetime               null    ,
    cby           char(10)               null    ,
    cbyname       varchar(12)            null    ,
    cbytime       datetime               null    ,
    logmark       int                    default 0 not null,
    avid          int                    null    
)
exec sp_primarykey res_av_h,folio
create unique index index1 on res_av_h(folio)
;

if exists (select 1 from  sysobjects  where  id = object_id('res_av_log')  and    type = 'U')
   drop table res_av_log
;
create table res_av_log
(
    folio         char(10)               not null,
    reftype       char(3)                not null,
    reffolio      char(10)               not null,
    reffolio1     char(10)               null    ,
    accnt         char(10)               not null,
    accnt1        char(10)               not null,
    sta           char(1)                not null,
    resid         char(10)               not null,
    qty           int                    default 1 not null,
    bdate         datetime               not null,
    stime         datetime               not null,
    etime         datetime               not null,
    sfield        int                    not null,
    efield        int                    not null,
    sfieldtime    varchar(16)            not null,
    efieldtime    varchar(16)            not null,
    summary       varchar(255)           null    ,
    worker        varchar(30)            null    ,
    amount        money                  default 0 not null,
    amount0       money                  not null,
    reason        char(3)                not null,
    flag          char(1)                default 'F' not null,
    date          datetime               null    ,
    modu_id       char(2)                null    ,
    resby         char(10)               null    ,
    resbyname     varchar(12)            null    ,
    reserved      datetime               null    ,
    cby           char(10)               null    ,
    cbyname       varchar(12)            null    ,
    cbytime       datetime               null    ,
    logmark       int                    default 0 not null,
    avid          int                    null    
)
exec sp_primarykey res_av_log,folio,logmark
;
if exists (select 1 from  sysobjects  where  id = object_id('res_ooo')  and    type = 'U')
   drop table res_ooo
;
create table res_ooo
(
    folio         char(10)               not null,
    sta           char(1)                not null,
    resid         char(10)               not null,
    qty           int                    default 1 not null,
    bdate         datetime               not null,
    stime         datetime               not null,
    etime         datetime               not null,
    sfield        int                    not null,
    efield        int                    not null,
    sfieldtime    varchar(16)            not null,
    efieldtime    varchar(16)            not null,
    summary       varchar(255)           null    ,
    worker        varchar(30)            null    ,
    modu_id       char(2)                null    ,
    resby         char(10)               null    ,
    resbyname     varchar(12)            null    ,
    reserved      datetime               null    ,
    cby           char(10)               null    ,
    cbyname       varchar(12)            null    ,
    cbytime       datetime               null    ,
    logmark       int                    default 0 not null 
)
exec sp_primarykey res_ooo,folio
create unique index index1 on res_ooo(folio)
;
if exists (select 1 from  sysobjects  where  id = object_id('res_ooo_h')  and    type = 'U')
   drop table res_ooo_h
;
create table res_ooo_h
(
    folio         char(10)               not null,
    sta           char(1)                not null,
    resid         char(10)               not null,
    qty           int                    default 1 not null,
    bdate         datetime               not null,
    stime         datetime               not null,
    etime         datetime               not null,
    sfield        int                    not null,
    efield        int                    not null,
    sfieldtime    varchar(16)            not null,
    efieldtime    varchar(16)            not null,
    summary       varchar(255)           null    ,
    worker        varchar(30)            null    ,
    modu_id       char(2)                null    ,
    resby         char(10)               null    ,
    resbyname     varchar(12)            null    ,
    reserved      datetime               null    ,
    cby           char(10)               null    ,
    cbyname       varchar(12)            null    ,
    cbytime       datetime               null    ,
    logmark       int                    default 0 not null 
)
exec sp_primarykey res_ooo_h,folio
create unique index index1 on res_ooo_h(folio)
;
if exists (select 1 from  sysobjects  where  id = object_id('res_ooo_log')  and    type = 'U')
   drop table res_ooo_log
;
create table res_ooo_log
(
    folio         char(10)               not null,
    sta           char(1)                not null,
    resid         char(10)               not null,
    qty           int                    default 1 not null,
    bdate         datetime               not null,
    stime         datetime               not null,
    etime         datetime               not null,
    sfield        int                    not null,
    efield        int                    not null,
    sfieldtime    varchar(16)            not null,
    efieldtime    varchar(16)            not null,
    summary       varchar(255)           null    ,
    worker        varchar(30)            null    ,
    modu_id       char(2)                null    ,
    resby         char(10)               null    ,
    resbyname     varchar(12)            null    ,
    reserved      datetime               null    ,
    cby           char(10)               null    ,
    cbyname       varchar(12)            null    ,
    cbytime       datetime               null    ,
    logmark       int                    default 0 not null 
)
exec sp_primarykey res_ooo_log,folio,logmark 
;

/*  Insert trigger "ti_res_av" for table "res_av"  */
create trigger ti_res_av on res_av for insert as
begin
    declare
       @maxcard  int,
       @numrows  int,
       @numnull  int,
       @errno    int,
       @errmsg   varchar(255)

    select  @numrows = @@rowcount
    if @numrows = 0
       return

    insert into res_av_log select * from inserted


    return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
;

/*  Update trigger "tu_res_av" for table "res_av"  */
create trigger tu_res_av on res_av for update as
begin
   declare
      @maxcard  int,
      @numrows  int,
      @numnull  int,
      @errno    int,
      @errmsg   varchar(255)

      select  @numrows = @@rowcount
      if @numrows = 0
         return
      if update(logmark)
          insert into res_av_log select * from inserted



      return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
;

/*  Insert trigger "ti_res_ooo" for table "res_ooo"  */
create trigger ti_res_ooo on res_ooo for insert as
begin
    declare
       @maxcard  int,
       @numrows  int,
       @numnull  int,
       @errno    int,
       @errmsg   varchar(255)

    select  @numrows = @@rowcount
    if @numrows = 0
       return

    insert into res_ooo_log select * from inserted


    return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
;

/*  Update trigger "tu_res_ooo" for table "res_ooo"  */
create trigger tu_res_ooo on res_ooo for update as
begin
   declare
      @maxcard  int,
      @numrows  int,
      @numnull  int,
      @errno    int,
      @errmsg   varchar(255)

      select  @numrows = @@rowcount
      if @numrows = 0
         return

      if update(logmark)
          insert into res_ooo_log select * from inserted



      return

/*  Errors handling  */
error:
    raiserror @errno @errmsg
    rollback  transaction
end
;


-------------------------------------------------------------------------------
--- 初始化状态代码 
--------------------------------------------------------------------------------
--- 预订处理状态 
if exists(select 1 from basecode_cat where cat='dict_status.avs')
	delete basecode_cat where cat='dict_status.avs';
insert basecode_cat(cat,descript,descript1,len) select 'dict_status.avs', '会议室预订状态', 'meet room reseve status', 1;

delete basecode where cat='dict_status.avs'
;
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select	'dict_status.avs',	'R',	'预订',	'Reserve','T','F',0,'1' 
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select	'dict_status.avs',	'O',	'确认',	'OK','T','F',0,'1' 
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select	'dict_status.avs',	'X',	'取消',	'Cancel','T','F',0,'1' 
;
--- 资源维修状态 
if exists(select 1 from basecode_cat where cat='dict_status.rso')
	delete basecode_cat where cat='dict_status.rso';
insert basecode_cat(cat,descript,descript1,len) select 'dict_status.rso', '会议室维修状态', 'meet room maint status', 1;

delete basecode where cat='dict_status.rso'
;
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select	'dict_status.rso',	'A',	'预约',	'Reserve','T','F',0,'' 
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select	'dict_status.rso',	'B',	'维修',	'Service','T','F',0,'' 
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select	'dict_status.rso',	'C',	'确认',	'OK','T','F',0,'' 
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select	'dict_status.rso',	'X',	'取消',	'Cancel','T','F',0,'' 
;

-- 资源类别
DELETE res_sort 
;
INSERT INTO res_sort(sortid,name,ename,chkmode,maintain,remark,moduleids) VALUES ( 'HYS', '会议室', '', 'mtr', 1, '', '')
INSERT INTO res_sort(sortid,name,ename,chkmode,maintain,remark,moduleids) VALUES ( 'XHP', '消耗品', '', 'qty', 0, '', '')
INSERT INTO res_sort(sortid,name,ename,chkmode,maintain,remark,moduleids) VALUES ( 'COFFER', '保险箱', '', 'olu', 1, '', '')
INSERT INTO res_sort(sortid,name,ename,chkmode,maintain,remark,moduleids) VALUES ( 'CAR', '汽车', '', 'olu', 1, '', '')
INSERT INTO res_sort(sortid,name,ename,chkmode,maintain,remark,moduleids) VALUES ( 'TAX', '租赁设备', '', 'min', 1, '', '')
;
--------------------------------------------------------------------------------
--  GoodsAVStatus
--------------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='GoodsAVStatus')
	delete basecode_cat where cat='GoodsAVStatus';
insert basecode_cat(cat,descript,descript1,len) select 'GoodsAVStatus', '物品租赁状态', 'GoodsAVStatus', 1;

delete basecode where cat='GoodsAVStatus'
;
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'GoodsAVStatus', 'R', '预订', 'Reserve','T','F',0,'2'
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'GoodsAVStatus', 'I', '确认', 'Inure','T','F',0,'2'
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'GoodsAVStatus', 'O', '归还', 'Over','T','F',0,'2'
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'GoodsAVStatus', 'X', '取消', 'Cancel','T','F',0,'2'
;

--------------------------------------------------------------------------------
--  GoodsAVFolio
--------------------------------------------------------------------------------
if exists(select 1 from sys_extraid where cat='GAV')
	delete sys_extraid where cat='GAV';
insert sys_extraid(cat,descript,id) select 'GAV', '物品租赁单据号码', 0;

--------------------------------------------------------------------------------
--  MeetAVFolio
--------------------------------------------------------------------------------
if exists(select 1 from sys_extraid where cat='MTR')
	delete sys_extraid where cat='MTR';
insert sys_extraid(cat,descript,id) select 'MTR', '会议室预订单据号码', 0;

-- 维护代码
DELETE FROM syscode_maint WHERE  code like 'P%'
DELETE FROM syscode_maint WHERE  code like 'R%'
;
INSERT INTO syscode_maint VALUES ('P',	'场地','','','','','',	'')
INSERT INTO syscode_maint VALUES ('P1','场地','','response','res','d_place_code','w_place_code',	'')
INSERT INTO syscode_maint VALUES ('P2','会议室','','response','res','d_res_meet','w_res_plu_meet','')
INSERT INTO syscode_maint VALUES ('R','租赁物品','','','','','','')
INSERT INTO syscode_maint VALUES ('R1','物品','','response','res','d_res_plu_list','w_res_plu_maint','')
INSERT INTO syscode_maint VALUES ('R2','类别','','response','res','d_res_sort_list','w_res_sort_maint','')
;
