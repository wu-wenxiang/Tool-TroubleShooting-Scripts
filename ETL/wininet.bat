@echo off
ECHO These commands will enable tracing:
@echo on

logman create trace "minkernel_manifests" -ow -o c:\minkernel_manifests.etl -p "Microsoft-Windows-Kernel-Network" 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets
logman update trace "minkernel_manifests" -p "Microsoft-Windows-TCPIP" 0xffffffffffffffff 0xff -ets
logman update trace "minkernel_manifests" -p "Microsoft-Windows-WinINet" 0xffffffffffffffff 0xff -ets
@echo off
echo
ECHO Reproduce your issue and enter any key to stop tracing
@echo on
pause
logman stop "minkernel_manifests" -ets

@echo off
echo Tracing has been captured and saved successfully at c:\minkernel_manifests.etl
pause