# Configuration
$CloudHost = 'hanatrial.ondemand.com';
$database = ''; # database name
$user = ''; # sap cloud user or email
$subaccount = ''; # database sub account, usually <user>trial
$password = ''; # password 

$neo = ''; # Path to the neo SDK's neo.bat from https://tools.hana.ondemand.com/#cloud
$eclipse = ''; # Path to a compatble eclipse's version of eclipse.exe
$env:JAVA_HOME = 'C:\Program Files\Java\jdk1.8.0_201'; # Path to Java, works with Java 8, not Java 11


### Session id of cloud db tunnels
$Script:TunnelSessionId = '';
$VerbosePreference = 'Continue';


# window hiding logic
$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $t -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

function isHanaRunning(){
    $DBStateRgx = [regex]'DB State:\s+([A-Z]+)';
    $DBState = cmd /c $neo display-db-info -i $database -a $subaccount -h $CloudHost -u $user -p $password --output json | ConvertFrom-Json;
    $DBStateValue = $DBStateRgx.Match($DBState.commandOutput).Groups[1].Value;
    return $DBStateValue -ne 'STOPPED';
}

function startHanaCloudDB(){
    $StartRequest = cmd /c $neo start-db-hana  -i $database -a $subaccount -h $CloudHost -u $user -p $password --output json | ConvertFrom-Json;
    if($StartRequest.exitCode -ne 0){
        Write-Warning 'Start Request (partial) failure';
    }
}

function startHanaCloudDBTunnel(){
    $StartRequest = cmd /c $neo open-db-tunnel  -i $database -a $subaccount -h $CloudHost -u $user -p $password --output json --background | ConvertFrom-Json;
    if($StartRequest.exitCode -ne 0){
        Write-Warning 'Tunnel start (partial) failure';
    } else {
        $Script:TunnelSessionId = $StartRequest.result.sessionId;
        Write-Verbose "Tunnel connected, Host: $($StartRequest.result.host), InstanceId: $($StartRequest.result.instanceNumber), Port: $($StartRequest.result.port)";
    }
}

function closeHanaCloudDBTunnel(){
    $CloseRequest = cmd /c $neo close-db-tunnel --session-id $Script:TunnelSessionId --output json | ConvertFrom-Json;
    if($CloseRequest.exitCode -ne 0){
        Write-Warning 'Tunnel close (partial) failure';
    }
}

function stopHanaCloudDB(){
    $StopRequest = cmd /c $neo stop-db-hana  -i $database -a $subaccount -h $CloudHost -u $user -p $password --output json | ConvertFrom-Json;
    if($StopRequest.exitCode -ne 0){
        Write-Warning 'Stop Request (partial) failure';
    }
}

# main loop
if(!(isHanaRunning)){
    Write-Verbose 'Hana Cloud DB is not running, starting...';
    startHanaCloudDB;
    while($true){
        Write-Verbose 'Waiting 5 s for Hana Cloud DB to come online';
        Sleep -Seconds 5;
        if(isHanaRunning){
            Write-Verbose 'Hana Cloud DB is online, continueing...';
            break;
        }
    }
}
Write-Verbose 'Starting tunnel to Hana Cloud DB';
startHanaCloudDBTunnel;
Write-Verbose 'Starting eclipse and waiting for completion';
& $eclipse | Out-Null;
Write-Verbose 'Closing tunnel';
closeHanaCloudDBTunnel;
Write-Verbose 'Stopping Hana Cloud DB';
stopHanaCloudDB;
