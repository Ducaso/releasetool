set verify off

Prompt register release &&1

insert into dbb_system_patches(pch_code, pch_releasenotes)
select '&&1'
       ,'&Releasenotes'
from dual
where not exists (select 1
                  from   dbb_system_patches
                  where  pch_code= '&&1');


update dbb_system_parameters set par_value='&&1' where par_code='APPLICATION.RELEASE'; 

				  
exit;
	   