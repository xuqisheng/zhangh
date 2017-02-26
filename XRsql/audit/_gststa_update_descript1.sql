update gststa set descript1='Total' where descript='合     计';
update gststa set descript1='Province Inside' where descript='省  内';
update gststa set descript1='Province Outside' where descript='省  外';
update gststa set descript1='---Over Seas---' where descript='---境外---';
update gststa set descript1='--Foreign Guest--' where descript='---外宾---';
update gststa set descript1=a.descript1 from countrycode a where gststa.nation=a.code; 

update ygststa set descript1='Total' where descript='合     计';
update ygststa set descript1='Province Inside' where descript='省  内';
update ygststa set descript1='Province Outside' where descript='省  外';
update ygststa set descript1='---Over Seas---' where descript='---境外---';
update ygststa set descript1='--Foreign Guest--' where descript='---外宾---';
update ygststa set descript1=a.descript1 from countrycode a where ygststa.nation=a.code; 

