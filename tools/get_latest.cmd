<!-- :
:: ����� 䠩� �㦨� ��� ����祭�� ९������ ᭥����� � ��� ��᫥���饣� ����������,
:: �᫨ ��� 祬-� �� ���ࠨ���� (��� �� ����㯭�) �������� "����������" � ���� ᭥�����.
@echo off
if "%1"=="proxy" (
	start "" mshta.exe "%~f0"
	exit /b
)
set curdir=%cd%
cd /d "%~dp0..\.."

if not exist data mkdir data
if not exist repo mkdir repo
if not exist data\cntlm.ini copy nul data\cntlm.ini > nul
if not exist data\proxy.cmd start "" /w mshta.exe "%~f0"
if exist data\proxy.cmd (
	call data\proxy.cmd
) else (
	copy nul data\proxy.cmd > nul
)
:: ����� � �ப�
if not "%useProxy%"=="true" goto :start
if "%proxyNtlm%"=="true" goto :ntlm
if "%proxyUser%"=="" (
	set proxyPass=
	goto :setproxy
)
set userDelim=@
set proxyUser=%proxyUser%:
if "%notStorePass%"=="false" goto :setproxy
if not exist %Windir%\System32\WindowsPowerShell\v1.0\Powershell.exe goto :vispwd
set "psCommand=powershell -Command "$pword = read-host '������ ��஫� ��� �ப�' -AsSecureString ; ^
$BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set proxyPass=%%p
goto :setproxy
:vispwd
call:echocolor Red "�� �६� ����� ��஫� �㤥� ������!!!"
set /p proxyPass=������ ��஫� ��� �ப�: 
cls
goto :setproxy
:ntlm
set CYGWIN=nodosfilewarning
if "%notStorePass%"=="true" (
	set proxyPass=-I
	<nul set /p ksksk=Enter proxy 
) else (
	if not "%proxyPass%"=="" set proxyPass=-p "%proxyPass%"
)
core\tools\cntlm\cntlm -c data\cntlm.ini -s -a %ntlmAuth% -l %ntlmPort% %proxyPass% -u "%proxyUser%" %proxyAddress%
if errorlevel 1 (
	call:echocolor Red "�� 㤠���� �������� cntlm.exe"
	goto :end
)
call:echocolor DarkYellow "����饭 cntlm �ப� ��� %proxyAddress% �� ����� %ntlmPort%"
set proxyUser=
set proxyPass=
set proxyAddress=127.0.0.1:%ntlmPort%
:setproxy
set http_proxy=http://%proxyUser%%proxyPass%%userDelim%%proxyAddress%
if not "%proxyPass%"=="" set proxyPass=******
call:echocolor DarkYellow "http_proxy = http://%proxyUser%%proxyPass%%userDelim%%proxyAddress%"

:start

if not exist repo\sn.fossil goto :getLogin
goto :cloneCore
:getLogin
set name=$$$
set /p name="������ ����� �� snegopat.ru: "
if "%name%"=="$$$" (
	call:echocolor Red "�� 㪠��� �����"
	goto :end
)

:cloneCore
if exist repo\sn.fossil goto :openCore
echo.
call:echocolor Blue "�����஢���� ९������ ᭥�����"
call:echocolor Blue "----------------------------------"
core\tools\fossil clone "http://%name%@snegopat.ru/reborn" -A %name% repo\sn.fossil
if errorlevel 1 (
	echo.
	call:echocolor Red "----------------------------------------------------"
	call:echocolor Red "!!! �� 㤠���� �����஢��� ९����਩ �������� !!!"
	call:echocolor Red "----------------------------------------------------"
	goto :end
)

:openCore
cd core
if exist _fossil_ goto :updateCore
echo.
call:echocolor Blue "����⨥ ९������"
call:echocolor Blue "--------------------"
tools\fossil open ..\repo\sn.fossil
if errorlevel 1 (
	echo.
	call:echocolor Red "-----------------------------------------------"
	call:echocolor Red "!!! �� 㤠���� ������ �᭮���� ९����਩ !!!"
	call:echocolor Red "-----------------------------------------------"
	goto :end
)

:updateCore
echo.
call:echocolor Blue "���������� �᭮����� ९������"
call:echocolor Blue "--------------------------------"
tools\fossil set autosync off
:: ��� ��室���� ��������. Fossil � ��砥 �訡�� ������ � �ࢥ஬ �� �뤠�� �訡��� ��� �����襭��
:: � ������ ᮮ�饭�� � stderr. ���⮬� �� ⠪�� ���� ��ࠧ�� ����᪠�� fossil, �����뢠� �뢮� � ��६�����,
:: �� ����� ���⠬� ��� stdout � stderr, ������ � �⮣� � ��६����� stderr
for /f "tokens=*" %%a in ('tools\fossil pull ^3^>^&1 ^1^>^&2 ^2^>^&3') do set pullErrors=%%a
if not "%pullErrors%"=="" (
	echo.
	call:echocolor Red "%pullErrors%"
	echo.
	call:echocolor Red "--------------------------------------------------------------"
	call:echocolor Red "!!! �� 㤠���� ������� ���������� �� ���譥�� ९������ !!!"
	call:echocolor Red "--------------------------------------------------------------"
	tools\fossil set autosync on
	goto :end
)
echo.
tools\fossil update
if errorlevel 1 (
	echo.
	call:echocolor Red "---------------------------------------------------"
	call:echocolor Red "!!! �� 㤠���� �믮����� ���������� ९������ !!!"
	call:echocolor Red "---------------------------------------------------"
) else (
	echo.
	call:echocolor Green "--------------------------"
	call:echocolor Green "!!! �� ��諮 �ᯥ譮 !!!"
	call:echocolor Green "--------------------------"
)
tools\fossil set autosync on

:end
cd /d "%curdir%"
if "%proxyNtlm%"=="true" (
	taskkill /F /IM cntlm.exe >nul 2>&1
	call:echocolor DarkYellow "��⠭����� cntlm �ப�"
)
pause
exit /b

:echocolor
if exist %Windir%\System32\WindowsPowerShell\v1.0\Powershell.exe (
	%Windir%\System32\WindowsPowerShell\v1.0\Powershell.exe write-host -foregroundcolor %1 %2
) else (
	echo %2
)
goto:eof
-->
<html>
<head>
<meta charset="cp866">
<title>����ன�� �ப� �ࢥ� ��� fossil</title>
<HTA:APPLICATION ID="myapp"
     APPLICATIONNAME="get_latest"
     BORDER="thick"
     BORDERSTYLE="normal"
     CAPTION="yes"
     ICON=""
     contextmenu="no"
     scroll="auto"
     MAXIMIZEBUTTON="no"
     MINIMIZEBUTTON="no"
     SHOWINTASKBAR="no"
     SINGLEINSTANCE="no"
     SYSMENU="yes"
     VERSION="20160707"
     WINDOWSTATE="normal"/>
<style>
body, input, table {
	font-family: Helvetica, arial, freesans, clean, sans-serif;
	font-size: 14px;
	line-height: 1.6;
	background-color: #FFF;
}
table {
	width: 100%;
}
.lbl {
	text-align:right;
	width: 50%;
}
input {
	height: 20pt;
	border-radius: 5px;
}
</style>
</head>
<body scroll="auto">
	<script language='javascript' >
	(function() {
		var w = 700, h = 500;
		window.moveTo((window.screen.width - w) / 2, (window.screen.height - h) / 2);
		window.resizeTo(w, h);
	})();
	
	function $(id) { return document.getElementById(id);}
	</script>
	<div>
		<input type="checkbox" name="useProxy"
			title="������, �᫨ �� 室�� � ���୥� �१ �ப�-�ࢥ�.">�ᯮ�짮���� �ப�-�ࢥ�</input>
	</div>
	<table cellspacing="2px" cellpadding="3px">
		<tr>
			<td class="lbl">���� �ப�-�ࢥ�</td>
			<td><input type="text" name="proxyAddress" size="30" title="���� �ப� �ࢥ� � ���� ����ࢥ�:����. �� ����⨨ ��⠥��� ������� �� ॥���."/></td>
		</tr>
		<tr>
			<td class="lbl">&nbsp;</td>
			<td><input type="button" value="�஢����" size="30" onclick="testProxy()"
				title="��⠥��� �易���� � �ࢥ஬ ᭥����� �१ 㪧���� �ப� ��� ���ਧ�樨. ��।����, �⢥砥� �� ����� �ப�, �ॡ�� �� ���ਧ�樨, ����� ��⮤� ���ਧ�樨 �����ন����."/>
			</td>
		</tr>
		<tr>
			<td class="lbl">��� ���짮��⥫� �� �ப�</td>
			<td>
				<input type="text" name="proxyUser" size="30"
				title="�᫨ �ப� �ॡ�� ���ਧ�樨, 㪠��� ����� ��� ���짮��⥫� ��� �ப�. �᫨ �ப� �ॡ�� NTLM-���ਧ���, � �� ����室����� 㪠����� ������, ��� ���짮��⥫� 㪠�뢠���� � ���� ��ﯮ�짮��⥫�@�����"/>
			</td>
		</tr>
		<tr>
			<td class="lbl">��஫� �� �ப�</td>
			<td><input type="password" name="proxyPass" size="30"/ title="����� �������� ��஫� ��� ���ਧ�樨 �� �ப�."></td>
		</tr>
		<tr>
			<td class="lbl">�� �࠭��� ��஫�, � ����訢��� �� ����</td>
			<td><input type="checkbox" name="notStorePass"
				title="������, �᫨ �� ��� ��࠭��� ��஫� � 䠩�� ����஥�. ����� �� �㤥� ����訢����� �� ������ ����᪥."/>
			</td>
		</tr>
		<tr>
			<td class="lbl">��ࢥ� �ᯮ���� NTLM-���ਧ���</td>
			<td><input type="checkbox" name="proxyNtlm"
				title="�᫨ ��� �ப� �ॡ�� ��易⥫��� NTLM (Windows) ���ਧ���, � ������ ��� ����. ����� ��� fossil �㤥� ����饭 �஬������ �ப� 'cntlm', ����� �㤥� ���ਧ������� ����� ���� �� �⮬ �ப�."/>
			</td>
		</tr>
		<tr>
			<td class="lbl">��� NTLM-���ਧ�樨</td>
			<td><input type="text" name="ntlmAuth" size="30" title="������ NTLM-���ਧ�樨 �� ��襬 �ப�. ��� ���᭥��� ������ ������ '��।�����'"/></td>
		</tr>
		<tr>
			<td class="lbl">&nbsp;</td>
			<td><input type="button" value="��।�����" size="30" onclick="detectNtlm()" title="����᪠�� ��।������ ������� NTLM-���ਧ�樨. ��� �믮������ ������ ���� ������� ���� ��� � ��஫� �� �ப�."/></td>
		</tr>
		<tr>
			<td class="lbl">������� ���� ��� NTLM-�ப�</td>
			<td><input type="number" name="ntlmPort" value="3129" title="����� �����쭮�� ����, �� ���஬ �㤥� ࠡ���� �஬������ �ப� cntlm. Fossil �㤥� �������� � �⮬� �����. ������ �� ᢮����� ����."/></td>
		</tr>
	</table>
	<hr>
	<div style="float:right">
		<button onclick='storeSettings()' title="���࠭�� ����ன�� � 䠩� data\proxy.cmd">���࠭���</button>
	</div>
	<script>
	var myFolder = myapp.commandLine.replace(/\\[^\\]+$/, "").replace('"', "") + '\\';
	var wsh = new ActiveXObject("WScript.Shell");
	var env = wsh.Environment("Process");
	var fso = new ActiveXObject('Scripting.FileSystemObject');
	var remoteUrl = "http://snegopat.ru/reborn/";
	
	(function(){
		var pathToSettings = myFolder + "..\\..\\data\\proxy.cmd";
		if (fso.FileExists(pathToSettings)) {
			var file = fso.OpenTextFile(pathToSettings, 1);
			var lines = file.ReadAll().replace(/\r\n/g,'\n').split('\n');
			file.Close();
			for (var k in lines) {
				var m = lines[k].match(/^set\s+([^=]+)=(.*)/i)
				if (m) {
					var field = $(m[1]);
					if (field) {
						if (field.type == 'checkbox') {
							field.checked = m[2]=='true';
						} else
							field.value = m[2];
					}
				}
			}
		}
	})();
	
	(function(){
		var directTestSuccess = false;
		// �஢�ਬ ��אַ� �����
		try {
			var http = new ActiveXObject('MSXML2.ServerXMLHTTP.6.0');
		} catch(e) {
			alert("�� 㤠���� ᮧ���� ��ꥪ� MSXML2.ServerXMLHTTP.6.0 ��� �஢�ન �ப�-�ࢥ�");
		}
		http.setProxy(1);	// ��� �ப�
		http.open('get', remoteUrl);
		http.onreadystatechange = function() {
			if (http.readyState == 4 && http.status == 200) {
				directTestSuccess = true;
				alert("���譨� ᠩ� ����㯥� ��� �ப�");
				$('useProxy').checked = false;
			}
		}
		try {
			http.send(null);
		} catch(e) {
			alert("�� 㤠���� �஢���� ��אַ� ᮥ�������: " + e.description);
		}

		var key = wsh.RegRead("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\ProxyServer");
		if (key.length) {
			var keys = key.split(';');
			key = '';
			for (var i = 0; i < keys.length ; i++) {
				var tt = keys[i].match(/^(?:https?:\/\/|)([A-Za-z0-9_\.\-]+:\d+)$/);
				if (tt) {
					key = tt[1];
					break;
				}
			}
		}
		if (key.length) {
			$('proxyAddress').value = key;
			if (!directTestSuccess)
				$('useProxy').checked = true;
		}
	})();
	function testProxy() {
		try {
			var http = new ActiveXObject('MSXML2.ServerXMLHTTP.6.0');
		} catch(e) {
			alert("�� 㤠���� ᮧ���� ��ꥪ� MSXML2.ServerXMLHTTP.6.0 ��� �஢�ન �ப�-�ࢥ�");
		}
		http.setProxy(2, $('proxyAddress').value);
		http.open('get', remoteUrl);
		http.onreadystatechange = function() {
			if (http.readyState == 4) {
				if (http.status == 200) {
					alert("�ப�-�ࢥ� �⢥⨫, ���ਧ�樨 �� �ॡ��");
				} else if (http.status == 407) {
					var authMetods = [];
					var headers = http.getAllResponseHeaders().split('\n');
					for (var i in headers) {
						var h = headers[i].match(/^Proxy-Authenticate:\s+(\S+)/i);
						if (h)
							authMetods.push(h[1]);
					}
					alert("�ப�-�ࢥ� �⢥⨫, �ॡ�� ���ਧ�樨, �����ন���� " + authMetods.join(', '));
				} else {
					alert("�ப�-�ࢥ� �⢥⨫ " + http.status + ": " + http.statusText);
				}
			}
		}
		try {
			http.send(null);
		} catch(e) {
			alert("�� 㤠���� �஢���� �ப�-�ࢥ�: " + e.description);
		}
	}
	
	function detectNtlm() {
		var proxyAddress = $('proxyAddress').value;
		if (!proxyAddress) {
			alert("�� ����� ���� �ப� �ࢥ�");
			return;
		}
		var proxyUser = $("proxyUser").value;
		if (!proxyUser) {
			alert("�� ������ ��� ���짮��⥫�");
			return;
		}
		var proxyPass = $("proxyPass").value;
		if (!proxyPass) {
			alert("�� 㪠��� ��஫� ���짮��⥫�");
			return;
		}
		var pathToCntlmIni = myFolder + "..\\..\\data\\cntlm.ini";
		if (!fso.FileExists(pathToCntlmIni)) {
			var file = fso.CreateTextFile(pathToCntlmIni);
			file.Close();
		}
		env('CYGWIN') = 'nodosfilewarning';
		var run = '"' + myFolder + 'cntlm\\cntlm.exe" -c "' + pathToCntlmIni + '" -I -M ' + remoteUrl + ' -u "' + proxyUser + '" ' + proxyAddress;
		var exec = wsh.Exec(run);
		exec.StdIn.Write(proxyPass + '\n');
		var out = exec.StdOut;
		var text = '';
		while(!out.atEndOfStream)
			text += out.ReadAll();
		var found = text.match(/Config profile\s+\d\/\d... OK \(.+\)\n-{3,}.+\n([\s\S]+)\n-{3,}/);
		if (found) {
			text = found[1];
			found = text.match(/^Auth\s+(.+)$/m);
			if (found) {
				var file = fso.CreateTextFile(pathToCntlmIni);
				file.Write(text);
				file.Close();
				$('ntlmAuth').value = found[1];
				alert("����� �ப�-�ࢥ� ��।��� ��� " + found[1]+ '.\n��� ��஫� ��࠭��� � 䠩� ����஥� cntlm.ini');
				$('proxyPass').value = '';
				$('notStorePass').checked = false;
				return;
			}
		}
		alert("�� 㤠���� ��।����� ०�� �ࢥ�. �ணࠬ�� �뤠��:\n" + text + '\n��������, �ப�-�ࢥ� �� ����饭 ��� �� ����� ������ ���/��஫�');
	}
	function storeSettings() {
		var file = fso.CreateTextFile(myFolder + "..\\..\\data\\proxy.cmd", true);
		var fields = ['useProxy', 'notStorePass', 'proxyAddress', 'proxyUser', 'proxyNtlm', 'ntlmAuth', 'ntlmPort'];
		if (!$('notStorePass').checked)
			fields.push('proxyPass');
		for (var k in fields) {
			var f = $(fields[k]);
			var v = f.type == "checkbox" ? f.checked : f.value;
			file.WriteLine("set " + fields[k] + "=" + v);
		}
		file.Close();
		close(0);
	}
	</script>
</body>
</html>
