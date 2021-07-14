@ECHO OFF

SET nicClassGuid={4D36E972-E325-11CE-BFC1-08002be10318}
SET regKey=HKLM\SYSTEM\CurrentControlSet\Services\TCPIP\Linkage
SET regValue=Bind
SET regData=
FOR /F "tokens=3" %%i IN ('reg.exe QUERY %regKey% /v %regValue% ^| findstr.exe "Bind"') DO SET regData=%%i
IF NOT DEFINED regData GOTO :EndBindingOrder
SET regData=%regData:\Device\=%
SET regData=%regData:\0= %

SET /A count = 0

ECHO NIC binding order:
ECHO ------------------------------------------------------------------------
CALL :ForEachNic %regData%
GOTO :EndBindingOrder

:ForEachNic
  SET _NicGuid=%1
  IF NOT DEFINED _NicGuid GOTO :EOF
  SET /A count += 1
  SET _regKey1=HKLM\SYSTEM\Currentcontrolset\Control\Network\%nicClassGuid%\%_NicGuid%\Connection
  SET _regValue1=Name
  FOR /F "tokens=2*" %%i IN ('reg.exe QUERY %_regKey1% /v %_regValue1% ^| findstr.exe "Name"') DO SET _regData1=%%j
  SET _regKey2=HKLM\SYSTEM\Currentcontrolset\Services\TCPIP\Parameters\Interfaces\%_NicGuid%
  SET _regValue2=IPAddress
  FOR /F "tokens=3" %%i IN ('reg.exe QUERY %_regKey2% /v %_regValue2% 2^>NUL ^| findstr.exe "IPAddress"') DO SET _regData2=%%i
  IF NOT DEFINED _regData2 SET _regData2=no IP address
  ECHO Adapter #%count%: %_NicGuid% - %_regData1% - %_regData2:\0=, %
  FOR %%i IN (_regKey1 _regValue1 _regData1 _regKey2 _regValue2 _regData2) DO SET %%i=
  SHIFT
GOTO :ForEachNic

:EndBindingOrder
