/* ============================================================ */
/*   Database name:  model_res                                  */
/*   DBMS name:      Sybase SQL Server 11                       */
/*   Created on:     2003-04-09  09:23                          */
/* ============================================================ */

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

