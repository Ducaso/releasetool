set releasetoolversion=01-jan-2016
rem
rem Plaats dit script in een folder "releases" 
rem Het maakt automatisch sub folders aan en de benodigde files
rem

rem Get latest patch
call _settings.bat

rem Get input
echo off
cls
echo Latest patch: %patch_code%
echo.

set oldrelease=%release%

set /p application="Application (shortname) [%application%]: "
set /p version="Version (2 digits) [%version%]: "
set /p oldrelease="Old Release [%oldrelease%]: "
set /p release="New Release (3 digits) [%release%]: "
set /p development="Connection Development (user@sid) [%development%]: "


cls
set release_code=%application%.%version%.%release%
set release_dir=%release_code%

set oldrelease_code=%application%.%version%.%oldrelease%
set oldrelease_dir=%oldrelease_code%


echo Create Release: %release_code%
echo.
echo Make patchset from old release: %oldrelease_code%
echo.
echo Register release in development database as: %development%
echo.
pause
cls

rem Store Settings
echo set patch_code=%patch_code%> _settings.bat
echo set application=%application%>> _settings.bat
echo set version=%version%>> _settings.bat
echo set release=%release%>> _settings.bat
echo set patch=a>> _settings.bat
echo set developer=%developer%>> _settings.bat
echo set description=%description%>> _settings.bat
echo set development=%development%>> _settings.bat

rem Register patch
sqlplus %development% @_register.sql %release_code% 


rem Make folder tree

mkdir %release_dir%
mkdir %release_dir%\_patchset
mkdir %release_dir%\_patchset\apex
mkdir %release_dir%\_patchset\dba
mkdir %release_dir%\_patchset\releasenotes

copy _settings.bat %release_dir%\*.*

rem
rem Release Scripts
rem

echo off 
cls  
set outfile_bat=%release_code%_install.bat
set outfile_sql=%release_code%_install.sql
set outfile_dba=%release_code%.dba.sql
set outfile_apex=%release_code%.apex.sql
set outfile_notes=%release_code%.releasenotes.txt
               
set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
set min=%time:~3,2%
if "%min:~0,1%" == " " set min=0%min:~1,1%
set secs=%time:~6,2%
if "%secs:~0,1%" == " " set secs=0%secs:~1,1%
set timestampbuild=%date:~10,4%%date:~4,2%%date:~7,2%%hour%%min%%secs%    
    
	
set outfile=%outfile_bat%
echo rem Release %release_code% > %outfile%  
echo rem Generated %date% %time% >> %outfile%  
echo. >> %outfile%  
echo set NLS_LANG=AMERICAN_AMERICA.UTF8                   >> %outfile%  
echo echo off                                             >> %outfile%  
echo.                                                        >> %outfile%
echo rem Set Timestamp >> %outfile%
echo set hour=%%time:~0,2%%>> %outfile%
echo if "%%hour:~0,1%%" == " " set hour=0%%hour:~1,1%%>> %outfile%
echo set min=%%time:~3,2%%>> %outfile%
echo if "%%min:~0,1%%" == " " set min=0%%min:~1,1%%>> %outfile%
echo set secs=%%time:~6,2%%>> %outfile%
echo if "%%secs:~0,1%%" == " " set secs=0%%secs:~1,1%%>> %outfile%
echo set timestampbuild=%%date:~10,4%%.%%date:~4,2%%.%%date:~7,2%%,%%hour%%:%%min%%:%%secs%%>> %outfile%
echo.                                                        >> %outfile%
echo rem Deployment setting >> %outfile%
echo cls>>%outfile%  
echo call _deploy.bat>>%outfile%
echo set /p owner="Oracle Schema [%%owner%%]: ">>%outfile%
echo set /p sid="SID [%%sid%%]: ">>%outfile%
echo echo set owner=%%owner%%^>_deploy.bat>>%outfile%
echo echo set sid=%%sid%%^>^>_deploy.bat>>%outfile%

echo.                   >> %outfile%
echo rem Log deployment >> %outfile%
echo echo %%timestampbuild%%,%application%,%application%.%version%.%release%,%%owner%%,%%sid%% ^>^> "_deploymentlog.csv" >>%outfile%
echo.                   >> %outfile%
echo rem Deployment Release >> %outfile%
echo sqlplus %%owner%%@%%sid%% @%outfile_sql% %%owner%% %%sid%% >> %outfile%  




                                                        
set outfile=%outfile_sql%               
echo -- Release %release_code% > %outfile%  
echo -- Generated %date% %time% >> %outfile%  
echo. >> %outfile%  
echo define owner=^&1 >> %outfile%  
echo define sid=^&2 >> %outfile%  
echo spool %release_code%.install_log_^&^&owner._^&^&sid..log append >> %outfile%  
echo select to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') tstamp from dual; >> %outfile%  
echo prompt Install Release: %release_code% >> %outfile%  
echo column pch_code format a29 >> %outfile%  
echo column pch_build format a24 >> %outfile%  
echo column pch_installed format a24 >> %outfile%  
echo select pch_code, to_char(pch_build,'DD-MON-YYYY HH24:MI:SS') pch_build, to_char(pch_installed,'DD-MON-YYYY HH24:MI:SS') pch_installed from dbb_system_patches_installed_v where substr (pch_code, 1, instr (pch_code, '.', 2)) = substr (pch_code, 1, instr ('%release_code%', '.', 2)); >> %outfile%  
echo prompt Press any key to continue ... >> %outfile%  
echo pause >> %outfile%  
echo prompt Active users >> %install%
echo column workspace_name format a30 >> %install%
echo column user_name format a30 >> %install%
echo select workspace_name,user_name,session_max_idle_sec-((session_idle_timeout_on-sysdate)*60*60*24) seconds_idle from apex_workspace_sessions where session_life_timeout_on ^> sysdate order by 3;     >> %install%
echo prompt Press any key to continue ... >> %install%
echo pause >> %install%
echo @%release_code%.dba.sql  >> %outfile%  
echo insert into dbb_system_patches (pch_code,pch_releasenotes,pch_build) values ('%release_code%',rtrim('All Patches release %oldrelease_code%'),to_date(rtrim('%timestampbuild%'),'YYYYMMDDHH24MISS')); >> %outfile%  
echo commit;   >> %outfile%  
echo @%release_code%.apex.sql  >> %outfile%  
echo update dbb_system_parameters set par_value='%patch_code%' where par_code='%application%.RELEASE'; >>  %outfile%  
echo commit; >> %outfile%  
echo Prompt Compiling ... >> %outfile%  
echo exec dbms_utility.compile_schema(user,false); >> %outfile%  
echo exec dbms_utility.compile_schema(user,false); >> %outfile%  
echo exec dbms_utility.compile_schema(user,false); >> %outfile%  
echo select object_name invalid_objects from user_objects where status = 'INVALID' order by 1; >> %outfile%  
echo spool off >> %outfile%  
echo Prompt Press any key to continue ... >> %outfile%  
echo pause >> %outfile%  
echo exit  >> %outfile%  


set outfile=%outfile_notes%                     
echo -- Release %release_code% > %outfile%  
echo -- Generated %date% %time% >> %outfile%  
echo. >> %outfile%  
echo -- Contains patches: >> %outfile%  
for %%f in (%oldrelease_code%\_patchset\releasenotes\*.txt) do (                           
echo -- %%~nf                           >> %outfile%  
)                                                       
echo. >> %outfile%  
echo. >> %outfile%  
echo. >> %outfile%  
for %%f in (%oldrelease_code%\_patchset\releasenotes\*.txt) do (                           
type %%f                            >> %outfile%  
echo.                                 >> %outfile%  
)                                                       


                                                  
set outfile=%outfile_dba%                     
echo -- Release %release_code% > %outfile%  
echo -- Generated %date% %time% >> %outfile%  
echo. >> %outfile%  
echo -- Contains patches: >> %outfile%  
for %%f in (%oldrelease_code%\_patchset\dba\*.sql) do (                           
echo -- %%~nf                           >> %outfile%  
)                                                       
echo. >> %outfile%  
echo. >> %outfile%  
echo. >> %outfile%  
for %%f in (%oldrelease_code%\_patchset\dba\*.sql) do (                           
type %%f                            >> %outfile%  
echo.                                 >> %outfile%  
)                                                       


		  
set outfile=%outfile_apex% 
echo -- Release %release_code% > %outfile%  
echo -- Generated %date% %time% >> %outfile%  
echo. >> %outfile%  
echo -- Contains applications: >> %outfile%  
for %%f in (%oldrelease_code%\_patchset\apex\*.sql) do (                           
echo -- %%~nf                            >> %outfile%  
)                                                       
echo. >> %outfile%  
echo. >> %outfile%  
echo. >> %outfile%  
for %%f in (%oldrelease_code%\_patchset\apex\*.sql) do (                           
type %%f                            >> %outfile%  
echo.                                 >> %outfile%  
)                                                       
       