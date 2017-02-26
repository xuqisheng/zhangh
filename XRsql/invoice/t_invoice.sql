

if exists (select * from sysobjects where name = 't_cyj_invoice_insert' and type = 'TR')
   drop trigger t_cyj_invoice_insert;

create trigger t_cyj_invoice_insert
	on invoice
  for insert as

insert into invoice_log  select * from inserted  ;

if exists (select * from sysobjects where name = 't_cyj_invoice_update' and type = 'TR')
   drop trigger t_cyj_invoice_update;

create trigger t_cyj_invoice_update
	on invoice
  for update as

if update(logmark)
	insert into invoice_log 	select * from inserted  ;

