set releasetoolversion=30-dec-2016
rem
rem Plaats dit script in een folder "releases" 
rem Het maakt automatisch sub folders aan en de benodigde files
rem

rem Get latest patch
call _settings.bat

rem Get input
echo off
cls
echo Latest patch: %patch_code% %description%
echo.

echo Application: %application%
echo Version....: %version%
echo Release....: %release%
echo.

set /p patch="Patch [%patch%]: "
set /p developer="Developer [%developer%]: "
set /p description="Description oneWord [%description%]: "
set releasenotes=%description%


cls
set release_code=%application%.%version%.%release%
set patch_code=%application%.%version%.%release%.%patch%

set release_dir=%release_code%
set patch_dir=%release_dir%\%patch_code%_%developer%_%description%


echo Create patch: %patch_code%
echo.
echo in directory: %patch_dir% 
echo.
echo Register patch in development database as: %development%
echo.
pause
cls

rem Store latest patch WINDOWS
echo set patch_code=%patch_code%> _settings.bat
echo set application=%application%>> _settings.bat
echo set version=%version%>> _settings.bat
echo set release=%release%>> _settings.bat
echo set patch=%patch%>> _settings.bat
echo set developer=%developer%>> _settings.bat
echo set description=%description%>> _settings.bat
echo set development=%development%>> _settings.bat



rem Register patch
sqlplus %development% @_register.sql %patch_code% 



rem Make folder tree

mkdir %release_dir%
mkdir %release_dir%\_patchset
mkdir %release_dir%\_patchset\apex
mkdir %release_dir%\_patchset\dba
mkdir %release_dir%\_patchset\ddl
mkdir %release_dir%\_patchset\dat
mkdir %release_dir%\_patchset\files
mkdir %release_dir%\_patchset\releasenotes
mkdir %patch_dir%
mkdir %patch_dir%\apex
mkdir %patch_dir%\dba
mkdir %patch_dir%\files
cls



rem
rem _build_patch.sql
rem

set buildfile_sql=%patch_dir%\_build_patch.sql

echo set echo off            >  %buildfile_sql%
echo set feedback off        >>  %buildfile_sql%
echo set pages 0             >>  %buildfile_sql%
echo set lines 999           >>  %buildfile_sql%
echo set trimspool on        >>  %buildfile_sql%
echo spool releasenotes.txt  >>  %buildfile_sql%
echo prompt =========================================================== >>  %buildfile_sql%
echo prompt Release Notes Patch %patch_code% (%developer%) >>  %buildfile_sql%
echo prompt =========================================================== >>  %buildfile_sql%
echo column pch_code format a20  >>  %buildfile_sql%
echo column pcn_code format a15  >>  %buildfile_sql%
echo column pcn_desc format a820  >>  %buildfile_sql%
echo select pch_code, pcn_code, pcn_desc from dbb_system_patch_releasenotes, dbb_system_patches where pch_code ='%patch_code%' and pch_id = pcn_pch_id order by pcn_code;   >>  %buildfile_sql%
echo spool off               >>  %buildfile_sql%
echo spool dba\releasenotes.dat  >>  %buildfile_sql%
echo select cmd from exp_system_patches where code like '%patch_code%%%' order by code;   >>  %buildfile_sql%
echo spool off               >>  %buildfile_sql%
echo exit                    >>  %buildfile_sql%





rem
rem Script to generate Patch
rem

set buildfile=%patch_dir%\_build_patch.bat

echo rem Build Patch.........: %patch_code%          >  %buildfile%
echo rem Generated...........: %date% %time%         >> %buildfile%
echo rem Release tool version: %releasetoolversion%  >> %buildfile%
echo.                                                        >> %buildfile%
echo.                                                        >> %buildfile%
echo set hour=%%time:~0,2%%>> %buildfile%
echo if "%%hour:~0,1%%" == " " set hour=0%%hour:~1,1%%>> %buildfile%
echo set min=%%time:~3,2%%>> %buildfile%
echo if "%%min:~0,1%%" == " " set min=0%%min:~1,1%%>> %buildfile%
echo set secs=%%time:~6,2%%>> %buildfile%
echo if "%%secs:~0,1%%" == " " set secs=0%%secs:~1,1%%>> %buildfile%
echo set timestampbuild=%%date:~10,4%%%%date:~4,2%%%%date:~7,2%%%%hour%%%%min%%%%secs%%>> %buildfile%
echo.                                                        >> %buildfile%
echo sqlplus %development% @_build_patch.sql                 >> %buildfile%
echo.                                                        >> %buildfile%
echo rem Generate APEX notes                                      >> %buildfile%
echo echo ===========================================================  ^> apex_notes.txt   >> %buildfile%
echo echo APEX Apps Patch %patch_code%     ^>^> apex_notes.txt   >> %buildfile%
echo echo ===========================================================  ^>^> apex_notes.txt   >> %buildfile%
echo for %%%%f in (apex\*.sql) do (                           >> %buildfile%
echo echo %%%%~nf                    ^>^> apex_notes.txt   >> %buildfile%
echo )                                                       >> %buildfile%
echo echo.                   ^>^> apex_notes.txt   >> %buildfile%
echo echo.                   ^>^> apex_notes.txt   >> %buildfile%
echo echo.                   ^>^> apex_notes.txt   >> %buildfile%
echo.                                                        >> %buildfile%
echo rem Generate dba notes                                      >> %buildfile%
echo echo ===========================================================  ^> dba_notes.txt   >> %buildfile%
echo echo DBA Objects / Data updates Patch %patch_code%     ^>^> dba_notes.txt   >> %buildfile%
echo echo ===========================================================  ^>^> dba_notes.txt   >> %buildfile%
echo echo.                                ^>^> dba_notes.txt   >> %buildfile%
echo echo Scripts:                          ^>^> dba_notes.txt   >> %buildfile%
echo echo ------------------------------  ^>^> dba_notes.txt   >> %buildfile%
echo for %%%%f in (dba\*.sql) do (                           >> %buildfile%
echo echo %%%%f                    ^>^> dba_notes.txt   >> %buildfile%
echo )                                                       >> %buildfile%
echo echo.                                ^>^> dba_notes.txt   >> %buildfile%
echo echo Tables:                          ^>^> dba_notes.txt   >> %buildfile%
echo echo ------------------------------  ^>^> dba_notes.txt   >> %buildfile%
echo for %%%%f in (dba\*.tab) do (                           >> %buildfile%
echo echo %%%%~nf                    ^>^> dba_notes.txt   >> %buildfile%
echo )                                                       >> %buildfile%
echo echo.                                ^>^> dba_notes.txt   >> %buildfile%
echo echo Package Specifiations:                          ^>^> dba_notes.txt   >> %buildfile%
echo echo ------------------------------  ^>^> dba_notes.txt   >> %buildfile%
echo for %%%%f in (dba\*.pks) do (                           >> %buildfile%
echo echo %%%%~nf                    ^>^> dba_notes.txt   >> %buildfile%
echo )                                                       >> %buildfile%
echo echo.                                ^>^> dba_notes.txt   >> %buildfile%
echo echo Package Bodies:                          ^>^> dba_notes.txt   >> %buildfile%
echo echo ------------------------------  ^>^> dba_notes.txt   >> %buildfile%
echo for %%%%f in (dba\*.pkb) do (                           >> %buildfile%
echo echo %%%%~nf                    ^>^> dba_notes.txt   >> %buildfile%
echo )                                                       >> %buildfile%
echo echo.                                ^>^> dba_notes.txt   >> %buildfile%
echo echo Views:                          ^>^> dba_notes.txt   >> %buildfile%
echo echo ------------------------------  ^>^> dba_notes.txt   >> %buildfile%
echo for %%%%f in (dba\*.vw) do (                            >> %buildfile%
echo echo %%%%~nf                    ^>^> dba_notes.txt   >> %buildfile%
echo )                                                       >> %buildfile%	
echo echo.                                ^>^> dba_notes.txt   >> %buildfile%
echo echo Data:                          ^>^> dba_notes.txt   >> %buildfile%
echo echo ------------------------------  ^>^> dba_notes.txt   >> %buildfile%
echo for %%%%f in (dba\*.dat) do (                           >> %buildfile%
echo echo %%%%~nf                    ^>^> dba_notes.txt   >> %buildfile%
echo )                                                       >> %buildfile%
echo.                               >> %buildfile%
echo rem Save sources               >> %buildfile%
echo.                               >> %buildfile%
echo mkdir ddl                      >> %buildfile%
echo copy dba\*.pks ddl\*.pks       >> %buildfile%
echo copy dba\*.pkb ddl\*.pkb       >> %buildfile%
echo copy dba\*.vw  ddl\*.vw         >> %buildfile%
echo copy dba\*.tab ddl\*.tab       >> %buildfile%
echo.                               >> %buildfile%
echo rem Save data              >> %buildfile%
echo mkdir dat                      >> %buildfile%
echo copy dba\*.dat dat\*(%patch_code%).dat       >> %buildfile%
echo.                                                        >> %buildfile%
echo rem Generate DBA script                                 >> %buildfile%
echo.                                                        >> %buildfile%
echo set outfiledba=..\%patch_code%.dba.sql                     >> %buildfile%
echo.                                                        >> %buildfile%
echo echo -- Release..: %patch_code%      ^>   %%outfiledba%%   >> %buildfile%
echo echo -- By.......: %developer%       ^>^> %%outfiledba%%   >> %buildfile%
echo echo -- Generated: %%date%% %%time%% ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                              ^>^> %%outfiledba%%   >> %buildfile%
rem echo echo /*                              ^>^> %%outfiledba%%   >> %buildfile%
rem echo type _releasenotes.txt               ^>^> %%outfiledba%%   >> %buildfile%
rem echo echo */                              ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                              ^>^> %%outfiledba%%   >> %buildfile%
echo echo /*                              ^>^> %%outfiledba%%   >> %buildfile%
echo type releasenotes.txt               ^>^> %%outfiledba%%   >> %buildfile%
echo echo */                              ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                              ^>^> %%outfiledba%%   >> %buildfile%
echo echo /*                              ^>^> %%outfiledba%%   >> %buildfile%
echo type dba_notes.txt               ^>^> %%outfiledba%%   >> %buildfile%
echo echo */                              ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                              ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                              ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                              ^>^> %%outfiledba%%   >> %buildfile%
echo echo WHENEVER SQLERROR CONTINUE      ^>^> %%outfiledba%%   >> %buildfile%
echo echo SET DEFINE OFF;                 ^>^> %%outfiledba%%   >> %buildfile%
echo echo set sqlblanklines on;           ^>^> %%outfiledba%%   >> %buildfile%
echo echo prompt Installing patch: %patch_code%  ^>^> %%outfiledba%%   >> %buildfile%
echo.                                                        >> %buildfile%
echo echo /*                              ^>^> %%outfiledba%%   >> %buildfile%
echo echo -- Install patch: %patch_code%  ^>^> %%outfiledba%%   >> %buildfile%
echo echo */                              ^>^> %%outfiledba%%   >> %buildfile%
echo.                                                        >> %buildfile%
echo for %%%%f in (dba\*.sql) do (                           >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo echo prompt Script: %%%%f                    ^>^> %%outfiledba%%   >> %buildfile%
echo type %%%%f                           ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo )                                                       >> %buildfile%
echo for %%%%f in (dba\*.tab) do (                           >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo echo prompt Table: %%%%~nf                    ^>^> %%outfiledba%%   >> %buildfile%
echo type %%%%f                           ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo )                                                       >> %buildfile%
echo for %%%%f in (dba\*.pks) do (                           >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo echo prompt Package Specification: %%%%~nf                    ^>^> %%outfiledba%%   >> %buildfile%
echo type %%%%f                           ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo )                                                       >> %buildfile%
echo for %%%%f in (dba\*.pkb) do (                           >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo echo prompt Package: %%%%~nf                    ^>^> %%outfiledba%%   >> %buildfile%
echo type %%%%f                           ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo )                                                       >> %buildfile%
echo for %%%%f in (dba\*.pkb) do (                           >> %buildfile%
echo do wrap iname=%%f oname=%%f.wrap                        >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo echo prompt %%%%f                    ^>^> %%outfiledba%%   >> %buildfile%
echo type %%%%f                           ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo )                                                       >> %buildfile%
echo for %%%%f in (dba\*.vw) do (                            >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo echo prompt View: %%%%~nf                    ^>^> %%outfiledba%%   >> %buildfile%
echo type %%%%f                           ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo )                                                       >> %buildfile%
echo for %%%%f in (dba\*.dat) do (                           >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo echo prompt Data: %%%%f                    ^>^> %%outfiledba%%   >> %buildfile%
echo type %%%%f                           ^>^> %%outfiledba%%   >> %buildfile%
echo echo.                                ^>^> %%outfiledba%%   >> %buildfile%
echo )                                                       >> %buildfile%
echo.                                                        >> %buildfile%
echo echo /*                              ^>^> %%outfiledba%%   >> %buildfile%
echo echo -- Post Patch Actions  ^>^> %%outfiledba%%   >> %buildfile%
echo echo */                              ^>^> %%outfiledba%%   >> %buildfile%
echo.                                                        >> %buildfile%
echo echo.                                 ^>^> %%outfiledba%%  >> %buildfile%
echo echo -- Maintain Audit Column Definitions    ^>^> %%outfiledba%%       >> %buildfile%
echo echo begin dbb_atc.gen_audit_columns; end; ^>^> %%outfiledba%%  >> %buildfile%
echo echo /                                     ^>^> %%outfiledba%%  >> %buildfile%
echo echo.                                 ^>^> %%outfiledba%%  >> %buildfile%
echo.                                                            >> %buildfile%
echo copy %%outfiledba%% ..\_patchset\dba\*.*                       >> %buildfile%
echo.                                                            >> %buildfile%
echo set outfileapex=..\%patch_code%.apex.sql                      >> %buildfile%
echo echo -- Generated: %%date%% %%time%%  ^>   %%outfileapex%%  >> %buildfile%
echo for %%%%f in (apex\*.sql) do (                              >> %buildfile%
echo type %%%%f                            ^>^> %%outfileapex%%  >> %buildfile%
echo echo.                                 ^>^> %%outfileapex%%  >> %buildfile%
echo copy %%%%f ..\_patchset\apex\*.*                            >> %buildfile%
echo )                                                           >> %buildfile%
echo.                                                            >> %buildfile%
echo copy files\*.* ..\_patchset\files\                      >> %buildfile%
echo copy ddl\*.* ..\_patchset\ddl\                      >> %buildfile%
echo copy dat\*.* ..\_patchset\dat\                      >> %buildfile%
echo.                                                            >> %buildfile%
echo type releasenotes.txt ^> ..\_patchset\releasenotes\%patch_code%.txt     >> %buildfile%
echo type apex_notes.txt ^>^> ..\_patchset\releasenotes\%patch_code%.txt     >> %buildfile%
echo type dba_notes.txt ^>^> ..\_patchset\releasenotes\%patch_code%.txt     >> %buildfile%
echo.                                                            >> %buildfile%
echo type releasenotes.txt ^> ..\%patch_code%.releasenotes.txt  >> %buildfile%
echo type apex_notes.txt ^>^> ..\%patch_code%.releasenotes.txt  >> %buildfile%
echo type dba_notes.txt ^>^> ..\%patch_code%.releasenotes.txt  >> %buildfile%
echo.                                                            >> %buildfile%


rem
rem Patch Scripts
rem
set install=%release_dir%\%patch_code%_install.sql
echo -- Generated %date% %time% > %install%
echo define owner=^&1 >> %install% >> %install%
echo define sid=^&2 >> %install% >> %install%
echo spool %patch_code%_install_log_^&^&owner._^&^&sid..log append >> %install%
echo set feedback 10 >> %install%
echo select to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') tstamp from dual; >> %install%
echo prompt Install patch: %patch_code% >> %install%
echo column pch_code format a29 >> %install%
echo column pch_build format a24 >> %install%
echo column pch_installed format a24 >> %install%
echo select pch_code, to_char(pch_build,'DD-MON-YYYY HH24:MI:SS') pch_build, to_char(pch_installed,'DD-MON-YYYY HH24:MI:SS') pch_installed from dbb_system_patches_installed_v where substr (pch_code, 1, instr (pch_code, '.', 2)) = substr (pch_code, 1, instr ('%patch_code%', '.', 2)); >> %install%
echo prompt Press any key to continue ... >> %install%
echo pause >> %install%
echo declare                                                                        >> %install%
echo   l_workspace_id number;                                                       >> %install%
echo begin                                                                          >> %install%
echo   l_workspace_id := apex_util.find_security_group_id(p_workspace =^> user);     >> %install%
echo   apex_util.set_security_group_id(p_security_group_id =^> l_workspace_id);      >> %install%
echo end;                                                                           >> %install%
echo /                                                                              >> %install%
echo .                                                                              >> %install%
echo prompt Active users >> %install%
echo column workspace_name format a30 >> %install%
echo column user_name format a30 >> %install%
echo select workspace_name,user_name,session_max_idle_sec-((session_idle_timeout_on-sysdate)*60*60*24) seconds_idle from apex_workspace_sessions where session_life_timeout_on ^> sysdate order by 3;     >> %install%
echo prompt Press any key to continue ... >> %install%
echo pause >> %install%
echo @%patch_code%.dba.sql  >>  %install%
echo update dbb_system_parameters set par_value='%patch_code%' where par_code='APPLICATION.RELEASE';  >>  %install%
echo commit; >>  %install%
echo @%patch_code%.apex.sql  >>  %install%
echo Prompt Compiling ... >>  %install%
echo exec dbms_utility.compile_schema(user,false); >>  %install%
echo exec dbms_utility.compile_schema(user,false); >>  %install%
echo exec dbms_utility.compile_schema(user,false); >>  %install%
echo select object_name from user_objects where status = 'INVALID' order by 1; >>  %install%
echo spool off >>  %install%
echo Prompt Press any key to continue ... >>  %install%
echo pause >>  %install%
echo exit  >>  %install%

rem
rem WARNING: geen spaties aanbrengen in onderstaande regels t.b.v. layout
rem          anders worden de owner en de sid niet goed bewaard in settings.bat
rem
set install_bat=%release_dir%\%patch_code%_install.bat
echo set NLS_LANG=AMERICAN_AMERICA.UTF8                             > %install_bat%
echo call settings.bat                                              >> %install_bat%
echo echo off                                                       >> %install_bat%
echo cls                                                            >> %install_bat%
echo set /p owner="Oracle Schema [%%owner%%]: ">> %install_bat%
echo.                                                        >> %install_bat%
echo rem Set Timestamp >> %install_bat%
echo set hour=%%time:~0,2%%>> %install_bat%
echo if "%%hour:~0,1%%" == " " set hour=0%%hour:~1,1%%>> %install_bat%
echo set min=%%time:~3,2%%>> %install_bat%
echo if "%%min:~0,1%%" == " " set min=0%%min:~1,1%%>> %install_bat%
echo set secs=%%time:~6,2%%>> %install_bat%
echo if "%%secs:~0,1%%" == " " set secs=0%%secs:~1,1%%>> %install_bat%
echo set timestamp=%%date:~10,4%%.%%date:~4,2%%.%%date:~7,2%%,%%hour%%:%%min%%:%%secs%%>> %install_bat%
echo.                                                        >> %install_bat%
echo rem Deployment setting >> %install_bat%
echo set /p sid="SID [%%sid%%]: ">> %install_bat%
echo echo set owner=%%owner%%^>settings.bat>>%install_bat%
echo echo set sid=%%sid%%^>^>settings.bat>>%install_bat%
echo.                                                        >> %install_bat%
echo rem Log deployment >> %install_bat%
echo echo %%timestamp%%,%application%,%application%.%version%.%release%.%patch%,%%owner%%,%%sid%% ^>^> "../_deploymentlog.csv" >>%install_bat%
echo.                                                        >> %install_bat%
echo rem Deployment Patch >> %install_bat%
echo sqlplus %%owner%%@%%sid%% @%patch_code%_install.sql %%owner%% %%sid%% >> %install_bat%












