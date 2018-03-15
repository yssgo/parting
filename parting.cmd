@echo off
:: parting.cmd
setlocal enableDelayedExpansion
if "%1"=="" (
	call :help
	endlocal
	exit /b
)
if "%1"=="/?" (
	call :help
	endlocal
	exit /b

)

set print_header=1
if "%1" == "/n" (	
	set print_header=0
	shift
)
set nparts=8
if not "%2"=="" if "%2" geq "2" set nparts=%2
set lines=0
for /f "usebackq tokens=1,* delims=]" %%i in (`type "%~1"^|find /v /n ""`) do @set /a lines=!lines!+1
set /a padded_lines=!lines!
set /a quotient=!padded_lines!/nparts
set /a remainder=!padded_lines! %% !nparts!
set /a padded_lines=!lines!
if %remainder% neq 0 set /a padded_lines+=(!nparts!-!remainder!)
set /a blocksize=!padded_lines!/!nparts!
set /a lastpart_no=!nparts!-1
for /l %%a in (0,1,!lastpart_no!) do (
	set /a start=%%a*!blocksize!
	set /a end=%%a+1
	set /a end=!end!*!blocksize!
	set /a end=!end!-1
	if !end! geq !lines! set /a end=!lines!-1
	call :partwrite "%~1" "%%a"
)
endlocal
exit /b
:partwrite
set /a part_no=1+%~2
set fname=%~n1 - part!part_no!%~x1
set /a start_line=!start!+1
set /a end_line=!end!+1
echo Writing part !part_no! of !nparts! (!start_line!-!end_line!) to "!fname!" 
set /a curline=-1
set withinlimit=1
set line_content=
for /f "usebackq tokens=1,* delims=]" %%i in (`type "%~1"^|find /v /n ""`) do (
	set /a curline=!curline!+1
	set withinlimit=1
	set line_content=
	if !curline! lss !start! set withinlimit=0
	if !curline! gtr !end! 	set withinlimit=0	
	if !withinlimit! equ 1 set line_content=%%j
	if !withinlimit! equ 1 	call :writeline
)
exit /b
:writeline
if "!print_header!" equ "1" (
	call :writeline_with_header
) else (
	call :writeline_without_header
)
exit /b

:writeline_with_header
if "!curline!" equ "!start!" ( 
	call :header_line_one
) else (
	call :out_nextlines
)
exit /b

:writeline_without_header
if "!curline!" equ "!start!" (
	call :out_firstline
) else (
	call :out_nextlines
)
exit /b

:header_line_one
echo %~n1 !part_no! of !nparts! : !start_line!-!end_line!
echo %~n1 !part_no! of !nparts! : !start_line!-!end_line!>"!fname!"	
echo.!line_content!>>"!fname!"
exit /b

:out_nextlines
echo.!line_content!>>"!fname!"
exit /b

:out_firstline
echo.!line_content!>"!fname!"
exit /b

:help
echo.
echo "%~n0" "입력 파일" 파트수
echo "%~n0" /n "입력 파일" 파트수
echo.
echo "입력 파일"을 파트수 개로 나누어 파일로 저장합니다.
echo 파트 수를 생략하면 8을 사용합니다.
echo /n (Noheader)이 있으면 파트 번호 및 포함된 줄을 표시하는 헤더 라인을 적지 않습니다.
exit /b
