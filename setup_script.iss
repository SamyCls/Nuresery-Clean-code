; Inno Setup Script for Crèche Manager
; Created for Flutter Windows Application

#define MyAppName "CrèchSoft"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "DevWorks"
#define MyAppExeName "creche_manager.exe"
#define MyAppBuildDir "build\windows\x64\runner\Release"

[Setup]
AppId={{D37D56B1-3E2A-4B69-9F2B-2A3C9E4B7A18}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=Output
OutputBaseFilename=CrecheManager_Setup
SetupIconFile=assets\images\app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Main Executable
Source: "{#MyAppBuildDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; All DLLs, Data, and dependencies inside Release directory
Source: "{#MyAppBuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Registry]
; Write initial installation timestamp into Windows Registry (createvalueifdoesntexist ensures re-installation won't reset trial date)
Root: HKCU; Subkey: "Software\CrecheSoft"; ValueName: "InstallTime"; ValueType: string; ValueData: "{code:GetInstallTimestamp}"; Flags: createvalueifdoesntexist

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
function GetInstallTimestamp(Param: String): String;
begin
  Result := GetDateTimeString('yyyy-mm-dd hh:nn:ss', #0, #0);
end;
