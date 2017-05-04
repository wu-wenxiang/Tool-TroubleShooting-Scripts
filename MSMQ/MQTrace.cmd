@echo off
if "%_echo%"=="" (
echo off
) else (
echo on
)


setlocal 


@rem
@rem Manage MSMQ Release Bits Tracing
@rem
@rem Revision History:
@rem      1.1   Shai Kariv (shaik)     05-Apr-2001
@rem      1.2   Conrad Chang (conradc) 05-Feb-2002
@rem      1.3   Conrad Chang (conradc) 31-July-2002
@rem              (Changed to use logman and use names instead of GUIDs)
@rem      1.4   Conrad Chang (conradc) 22-March-2004
@rem              (Added support for XP)
@rem      1.5   Conrad Chang (conradc) 19-Oct-2005
@rem              - Added flushing so that you don't need to stop the trace
@rem              - remove indigo on XP check
@rem              - remove filtering of unable to decode entries in trace file
@rem

echo mqtrace 1.5 - Manage MSMQ Release Bits Tracing.

set mqBinaryLog=%windir%\debug\msmqlog.bin
set mqTextLog=%windir%\debug\msmqlog.txt
set log_session_name=msmq
set msmqtracecfgfile=%windir%\debug\msmqtrc.ini
set msmqtracesessionlog=%windir%\debug\msmqtrc.log
set loggingrunning=
set mqRealTime=
set tracecommand=start
set tracefilemodeoptions=-f bincirc -max 200
set tracefilepathcommand=-o %mqBinaryLog%
set IsWinXP=0
set TmpVerFile=%tmp%\osver.txt
if not exist %windir%\system32\msmqpub.mof (
set MSMQSchemeFile=.\msmqpub.mof
) else (
set MSMQSchemeFile=%windir%\system32\msmqpub.mof
)

rem
rem XP is version 5.1
rem 
ver > %TmpVerFile%
findstr /i /c:"5.1" %TmpVerFile%
if %ERRORLEVEL% == 0 set IsWinXP=1
del %TmpVerFile%




@rem
@rem Jump to where we handle usage
@rem 
if /I "%1" == "help" goto Usage
if /I "%1" == "-help" goto Usage
if /I "%1" == "/help" goto Usage
if /I "%1" == "-h" goto Usage
if /I "%1" == "/h" goto Usage
if /I "%1" == "-?" goto Usage
if /I "%1" == "/?" goto Usage

@rem
@rem Set TraceFormat environment variable
@rem
if /I "%1" == "-path" shift&goto SetPath
if /I "%1" == "/path" shift&goto SetPath
goto EndSetPath
:SetPath
if /I not "%1" == "" goto DoSetPath
echo ERROR: Argument '-path' specified without argument for TraceFormat folder.
echo Usage example: mqtrace -path x:\symbols.pri\TraceFormat
goto :eof
:DoSetPath
echo Setting TRACE_FORMAT_SEARCH_PATH to '%1'
endlocal
set TRACE_FORMAT_SEARCH_PATH=%1&shift
goto :eof
:EndSetPath

@rem
@rem Format binary log file to text file
@rem
if /I "%1" == "-format" shift&goto FormatFile
if /I "%1" == "/format" shift&goto FormatFile
goto EndFormatFile
:FormatFile
if /I not "%TRACE_FORMAT_SEARCH_PATH%" == "" goto DoFormatFile

REM 
REM  LH doesn't need TMF file
REM
if %IsWinXP% == 0 goto DoFormatFile

echo ERROR: Argument '-format' specified without running 'mqtrace -path' first.
echo Usage example: mqtrace -path x:\symbols.pri\TraceFormat
echo                mqtrace -format ('%mqBinaryLog%' to text file '%mqTextLog%')
goto :eof
:DoFormatFile
if /I not "%1" == "" set mqBinaryLog=%1&shift
echo Formatting binary log file '%mqBinaryLog%' to '%mqTextLog%'.
call tracefmt %mqBinaryLog% -o %mqTextLog% -tmf %MSMQSchemeFile%
echo  Please view Trace File at %mqTextLog%

set mqBinaryLog=
goto :eof
:EndFormatFile


@rem
@rem Format binary log file to text file
@rem
if /I "%1" == "-flush" shift&goto FlushTrace
if /I "%1" == "/flush" shift&goto FlushTrace
goto EndFlushTrace
:FlushTrace
logman update msmq -fd -ets
goto :eof
:EndFlushTrace




@rem
@rem Handle the -stop argument
@rem 
if /I "%1" == "-stop" shift& goto HandleStopCommand
if /I "%1" == "/stop" shift& goto HandleStopCommand
goto EndHandleStopCommand
:HandleStopCommand
echo Stopping %log_session_name% trace session...
logman stop %log_session_name% -ets
goto :eof
:EndHandleStopCommand


@rem
@rem Handle the -query argument
@rem 
if /I "%1" == "-query" shift& goto HandleQueryCommand
if /I "%1" == "/query" shift& goto HandleQueryCommand
goto EndHandleQueryCommand
:HandleQueryCommand
echo Querying %log_session_name% trace session...
logman query %log_session_name% -ets 
goto :eof
:EndHandleQueryCommand


@rem
@rem Process the tracing change
@rem 
if /I "%1" == "-change" shift&goto ChangeTrace
if /I "%1" == "/change" shift&goto ChangeTrace
goto EndChangeTrace


:ChangeTrace
@rem
@rem Process the module
@rem 
if %IsWinXP% == 0 (
set Module=""
if /I "%1" == "AC" set Module="MSMQ: AC" & goto ProcessChangeLevel
if /I "%1" == "DS" set Module="MSMQ: DS" & goto ProcessChangeLevel
if /I "%1" == "GENERAL" set Module="MSMQ: General" & goto ProcessChangeLevel
if /I "%1" == "LOG" set Module="MSMQ: Log" & goto ProcessChangeLevel
if /I "%1" == "PROFILING" set Module="MSMQ: Profiling" & goto ProcessChangeLevel
if /I "%1" == "NETWORKING" set Module="MSMQ: Networking" & goto ProcessChangeLevel
if /I "%1" == "ROUTING" set Module="MSMQ: Routing"& goto ProcessChangeLevel
if /I "%1" == "RPC" set Module="MSMQ: RPC" & goto ProcessChangeLevel
if /I "%1" == "SECURITY" set Module="MSMQ: Security" & goto ProcessChangeLevel
if /I "%1" == "SRMP" set Module="MSMQ: SRMP" & goto ProcessChangeLevel
if /I "%1" == "XACT_GENERAL" set Module="MSMQ: XACT_General" & goto ProcessChangeLevel
if /I "%1" == "XACT_LOG" set Module="MSMQ: XACT_Log" & goto ProcessChangeLevel
if /I "%1" == "XACT_RCV" set Module="MSMQ: XACT_Receive" & goto ProcessChangeLevel
if /I "%1" == "XACT_SEND" set Module="MSMQ: XACT_Send" & goto ProcessChangeLevel


REM
REM For Indigo interop
REM 
REM if /I "%1" == "WS" set Module="MSMQ: WS" & goto ProcessChangeLevel
)

goto usage

:ProcessChangeLevel
shift 
set TraceLevel=
if /I "%1" == "none" set TraceLevel=() & goto UpdateTraceLevel
if /I "%1" == "error" set TraceLevel=(error) & goto UpdateTraceLevel
if %MODULE% == "MSMQ: ERRORLOGGING" goto usage 
if /I "%1" == "warning" set TraceLevel=(error,warning) & goto UpdateTraceLevel
if /I "%1" == "info" set TraceLevel=(error,warning,info) & goto UpdateTraceLevel
if /i "%TraceLevel%"=="" goto usage

:UpdateTraceLevel

logman update msmq -p %Module% %TraceLevel% -ets

goto :eof

:EndChangeTrace




@rem
@rem Consume the "-start" argument if it exists. Default is to start.
@rem 
echo Starting %log_session_name% trace logging to '%mqBinaryLog%'...
if /I "%1" == "-start" shift& goto HandleStart 
if /I "%1" == "/start" shift& goto HandleStart 
goto EndStart

:HandleStart
set tracecommand=start
set tracefilepathcommand=-o %mqBinaryLog%

:EndStart

@rem
@rem Consume the "-update" argument if it exists. Default is to start.
@rem 
echo Updating %log_session_name% trace logging to '%mqBinaryLog%'...
if /I "%1" == "-update" shift& set tracecommand=update
if /I "%1" == "/update" shift& set tracecommand=update


@rem
@rem Consume the -rt argument
@rem
if /I "%1" == "-rt" shift&goto ConsumeRealTimeArgument
if /I "%1" == "/rt" shift&goto ConsumeRealTimeArgument
goto EndConsumeRealTimeArgument
:ConsumeRealTimeArgument
if /I not "%TRACE_FORMAT_SEARCH_PATH%" == "" goto DoConsumeRealTimeArgument
echo ERROR: Argument '-rt' specified without running 'mqtrace -path' first.
echo Usage example: mqtrace -path x:\symbols.pri\TraceFormat
echo                mqtrace -rt (start RealTime logging/formatting at Error level)
goto :eof
:DoConsumeRealTimeArgument
echo Running %log_session_name% trace in Real Time mode...
set mqRealTime=-rt -ft 1
set tracecommand=start
:EndConsumeRealTimeArgument





@rem
@rem Process the noise level argument if it exists. Default is error level.
@rem 

if /I "%1" == "-info" shift&goto ConsumeInfoArgument
if /I "%1" == "/info" shift&goto ConsumeInfoArgument
goto EndConsumeInfoArgument
:ConsumeInfoArgument
echo %log_session_name% trace noise level is INFORMATION...
if %IsWinXP% == 0 (
Call :FSETUPTRCINIFILE "(error,warning,info)"
) else (
Call :FSETUPTRCINIFILE "0x7" 
)
goto EndConsumeNoiseLevelArgument
:EndConsumeInfoArgument

if /I "%1" == "-warning" shift&goto ConsumeWarningArgument
if /I "%1" == "/warning" shift&goto ConsumeWarningArgument
goto EndConsumeWarningArgument
:ConsumeWarningArgument
echo %log_session_name% trace noise level is WARNING...
if %IsWinXP% == 0  (
Call :FSETUPTRCINIFILE "(error,warning)"
) else (
Call :FSETUPTRCINIFILE "0x3"
)
goto EndConsumeNoiseLevelArgument
:EndConsumeWarningArgument

echo %log_session_name% trace noise level is ERROR...
IF %IsWinXP% == 0 (
Call :FSETUPTRCINIFILE "(error)"
) Else (
Call :FSETUPTRCINIFILE "0x1"
)

if /I "%1" == "-error" shift
if /I "%1" == "/error" shift
:EndConsumeNoiseLevelArgument




@rem
@rem At this point if we have any argument it's an error
@rem 
if /I not "%1" == "" goto Usage

@rem
@rem Query if %log_session_name% logger is running. If so only update the flags and append to logfile.
@rem
@rem  XP - always return 0 (success or fail)
@rem  W2K3 -  0 success
@rem          4029 fail
@rem  LH   -  0 success
@rem          -2147020695 (< 0) fail
@rem 
echo Querying if %log_session_name% logger is currently running...
logman query %log_session_name% -ets   > %msmqtracesessionlog%
if %ERRORLEVEL% NEQ 0 goto settrace


@rem
@rem logman.exe on XP is always return success so we need to look at the output to find MSMQ
@rem 
if %IsWinXP% == 1 (
findstr /i msmq %msmqtracesessionlog%
if ERRORLEVEL 1 goto settrace
)

echo %log_session_name% logger is currently running, changing existing trace settings...
set tracecommand=update
set tracefilepathcommand=
set tracefilemodeoptions=


:settrace
if /I "%mqRealTime%"=="" goto settracecontinue
set tracefilepathcommand=
set tracefilemodeoptions=
:settracecontinue
logman %tracecommand% %log_session_name% %mqRealTime% -pf %msmqtracecfgfile%  %tracefilepathcommand% %tracefilemodeoptions% -ets 



@rem
@rem In real time mode, start formatting
@rem 
if /I "%mqRealTime%" == "" goto EndRealTimeFormat
echo Starting %log_session_name% real time formatting...
if defined mqBinaryLog goto NormalRealTimeStart
logman update %log_session_name% -rt -ets
:NormalRealTimeStart
call tracefmt -display -rt %log_session_name% -o %mqTextLog%
:EndRealTimeFormat
set mqRealTime=
goto :eof


:FSETUPTRCINIFILE
set TEST=%1
if %IsWinXP% == 0 goto :nonxpsetup
goto :xpsetup

:nonxpsetup
@echo "MSMQ: AC" %TEST:~1,-1% > %msmqtracecfgfile%
@echo "MSMQ: Networking" %TEST:~1,-1%  >> %msmqtracecfgfile%
@echo "MSMQ: SRMP" %TEST:~1,-1% 	>> %msmqtracecfgfile%
@echo "MSMQ: XACT_General" %TEST:~1,-1% >> %msmqtracecfgfile%
@echo "MSMQ: RPC" %TEST:~1,-1% >> %msmqtracecfgfile%
@echo "MSMQ: DS" %TEST:~1,-1% >> %msmqtracecfgfile%
@echo "MSMQ: Security" %TEST:~1,-1% >> %msmqtracecfgfile%
@echo "MSMQ: Routing" %TEST:~1,-1% >> %msmqtracecfgfile%
@echo "MSMQ: General" %TEST:~1,-1% >> %msmqtracecfgfile%
@echo "MSMQ: XACT_Send" %TEST:~1,-1% >> %msmqtracecfgfile%
@echo "MSMQ: XACT_Receive" %TEST:~1,-1% >> %msmqtracecfgfile%
@echo "MSMQ: XACT_Log" %TEST:~1,-1% >> %msmqtracecfgfile%
@echo "MSMQ: Log" %TEST:~1,-1% >> %msmqtracecfgfile% 

REM
REM Hardcoded ERRORLOGGING TO ERROR flag
REM 
@echo "MSMQ: ERRORLOGGING" (error) >> %msmqtracecfgfile% 
goto :eof

:xpsetup
@echo {24b9a175-8716-40e0-9b2b-785de75b1e67} %TEST:~1,-1% > %msmqtracecfgfile% 
goto :eof


:Usage
if %IsWinXP% == 1 goto WinXPUsage 

echo
echo
echo Usage: mqtrace [^<Action^>] [^<Level^>]
echo        mqtrace -?
echo.
echo Advance Usage: mqtrace -path ^<TraceFormat folder^>
echo                mqtrace -rt [^<Action^>] [^<Level^>]
echo                mqtrace -format [^<Binary log file^>]
echo                mqtrace -change [^<Module^>] [^<Level^>]
echo                mqtrace -update [-rt] [^<Level^>]
echo                mqtrace -query
echo.
echo ^<Action^> - Optional trace action:
echo     -start   - start/update trace logging to '%mqBinaryLog%' (default). 
echo     -stop    - stop trace logging.
echo.
echo ^<Level^>  - Optional trace level (overrides current trace level):
echo     -error   - trace error messages only (default).
echo     -warning - trace warning and error messages.
echo     -info    - trace information, warning and error messages.
echo.
echo -?      - Display this usage message.
echo.
echo -path   - Set environment variable for TraceFormat folder. 
echo           This variable is necessary for later use of -rt or -format
echo           and needs to be set once (per command-line box).
echo.
echo -rt     - Start trace logger and formatter in Real Time mode.
echo           Environment variable must be set first, see '-path'.
echo           In addition, binary log is kept in '%mqBinaryLog%'.
echo.
echo -format - Format binary log file to text file '%mqTextLog%'.
echo           Environment variable must be set first, see '-path'.
echo
echo.
echo -change - Change the trace level for each module
echo
echo.
echo -update - Update the trace level for all modules
echo
echo.
echo ^<Binary log file^> - Optional binary log file. Default is '%mqBinaryLog%'.
echo
echo.
echo ^<Module^>: The module for which to change the debug level
echo     modules are: AC, DS, GENERAL, LOG, PROFILING, NETWORKING, ROUTING, 
echo                  RPC, SECURITY, SRMP, XACT_GENERAL, XACT_LOG, 
echo                  XACT_RCV, and XACT_SEND.
echo
echo.
echo ^<Level^>  - Trace level (overrides current trace level):
echo     none    - shut down debug from this module
echo     error   - trace error messages only (default).
echo     warning - trace warning and error messages.
echo     info    - trace information, warning and error messages.
echo.
echo.
echo Example 1: mqtrace (start/update logging to '%mqBinaryLog%' at Error level)
echo Example 2: mqtrace -path x:\Symbols.pri\TraceFormat
echo Example 3: mqtrace -rt -info (start real time logging at Info level)
echo Example 4: mqtrace -format (format '%mqBinaryLog%' to '%mqTextLog%')
echo Example 5: mqtrace -stop (stop logging)
echo Example 6: mqtrace -query (query current MSMQ current trace settings)
echo Example 7: mqtrace -change AC warning
echo Example 8: mqtrace -update -rt -info 
goto :eof


:WinXPUsage
echo
echo Usage: mqtrace [^<Action^>] [^<Level^>]
echo        mqtrace -?
echo.
echo Advance Usage: mqtrace -path ^<TraceFormat folder^>
echo                mqtrace -rt [^<Action^>] [^<Level^>]
echo                mqtrace -format [^<Binary log file^>]
echo.
echo ^<Action^> - Optional trace action:
echo     -start   - start/update trace logging to 'msmqlog.bin' (default). 
echo     -stop    - stop trace logging.
echo.
echo ^<Level^>  - Optional trace level (overrides current trace level):
echo     -error   - trace error messages only (default).
echo     -warning - trace warning and error messages.
echo     -info    - trace information, warning and error messages.
echo.
echo -?      - Display this usage message.
echo.
echo -path   - Set environment variable for TraceFormat folder. 
echo           This variable is necessary for later use of -rt or -format
echo           and needs to be set once (per command-line box).
echo.
echo -rt     - Start trace logger and formatter in Real Time mode.
echo           Environment variable must be set first, see '-path'.
echo           In addition, binary log is kept in 'msmqlog.bin'.
echo.
echo -format - Format binary log file to text file 'msmqlog.txt'.
echo           Environment variable must be set first, see '-path'.
echo.
echo -flush  - Flush all the trace buffer to disk
echo.
echo ^<Binary log file^> - Optional binary log file. Default is 'msmqlog.bin'.
echo.
echo Example 1: mqtrace (start/update logging to 'msmqlog.bin' at Error level)
echo Example 2: mqtrace -path x:\Symbols.pri\TraceFormat
echo Example 3: mqtrace -rt -info (start real time logging at Info level)
echo Example 4: mqtrace -format (format 'msmqlog.bin' to 'msmqlog.txt')
echo Example 5: mqtrace -stop (stop logging)
echo Example 6: mqtrace -flush
