IF OBJECT_ID('vrmsta') IS NOT NULL
    DROP VIEW vrmsta
;
create view vrmsta as
select a.roomno, a.oroomno, a.type, a.ocsta, a.sta, b.eccocode,
		a.hall, a.flr, a.rmreg, a.tmpsta  
	from rmsta a, rmstamap b 
	where a.ocsta+a.sta = b.code 
;

select * from vrmsta; 
