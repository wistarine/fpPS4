unit ps4_libSceSystemService;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  windows,
  ps4_program;

implementation

uses
 sys_types,
 sys_kernel,
 sys_signal,
 sys_time;

const
 SCE_SYSTEM_SERVICE_PARAM_ID_LANG                =1;
 SCE_SYSTEM_SERVICE_PARAM_ID_DATE_FORMAT         =2;
 SCE_SYSTEM_SERVICE_PARAM_ID_TIME_FORMAT         =3;
 SCE_SYSTEM_SERVICE_PARAM_ID_TIME_ZONE           =4;
 SCE_SYSTEM_SERVICE_PARAM_ID_SUMMERTIME          =5;
 SCE_SYSTEM_SERVICE_PARAM_ID_SYSTEM_NAME         =6;
 SCE_SYSTEM_SERVICE_PARAM_ID_GAME_PARENTAL_LEVEL =7;
 SCE_SYSTEM_SERVICE_PARAM_ID_ENTER_BUTTON_ASSIGN =1000;

 SCE_SYSTEM_SERVICE_ERROR_INTERNAL                        =-2136932351;
 SCE_SYSTEM_SERVICE_ERROR_UNAVAILABLE                     =-2136932350;
 SCE_SYSTEM_SERVICE_ERROR_PARAMETER                       =-2136932349;
 SCE_SYSTEM_SERVICE_ERROR_NO_EVENT                        =-2136932348;
 SCE_SYSTEM_SERVICE_ERROR_REJECTED                        =-2136932347;
 SCE_SYSTEM_SERVICE_ERROR_NEED_DISPLAY_SAFE_AREA_SETTINGS =-2136932346;
 SCE_SYSTEM_SERVICE_ERROR_INVALID_URI_LEN                 =-2136932345;
 SCE_SYSTEM_SERVICE_ERROR_INVALID_URI_SCHEME              =-2136932344;
 SCE_SYSTEM_SERVICE_ERROR_NO_APP_INFO                     =-2136932343;
 SCE_SYSTEM_SERVICE_ERROR_NOT_FLAG_IN_PARAM_SFO           =-2136932342;

 // Language
 SCE_SYSTEM_PARAM_LANG_JAPANESE      =0;   //LANG_JAPANESE
 SCE_SYSTEM_PARAM_LANG_ENGLISH_US    =1;   //else
 SCE_SYSTEM_PARAM_LANG_FRENCH        =2;   //LANG_FRENCH      else
 SCE_SYSTEM_PARAM_LANG_SPANISH       =3;   //LANG_SPANISH     SUBLANG_SPANISH SUBLANG_SPANISH_MEXICAN SUBLANG_SPANISH_MODERN
 SCE_SYSTEM_PARAM_LANG_GERMAN        =4;   //LANG_GERMAN
 SCE_SYSTEM_PARAM_LANG_ITALIAN       =5;   //LANG_ITALIAN
 SCE_SYSTEM_PARAM_LANG_DUTCH         =6;   //LANG_DUTCH
 SCE_SYSTEM_PARAM_LANG_PORTUGUESE_PT =7;   //LANG_PORTUGUESE  SUBLANG_PORTUGUESE
 SCE_SYSTEM_PARAM_LANG_RUSSIAN       =8;   //LANG_RUSSIAN
 SCE_SYSTEM_PARAM_LANG_KOREAN        =9;   //LANG_KOREAN
 SCE_SYSTEM_PARAM_LANG_CHINESE_T     =10;  //LANG_CHINESE     else
 SCE_SYSTEM_PARAM_LANG_CHINESE_S     =11;  //LANG_CHINESE     SUBLANG_CHINESE_SIMPLIFIED
 SCE_SYSTEM_PARAM_LANG_FINNISH       =12;  //LANG_FINNISH
 SCE_SYSTEM_PARAM_LANG_SWEDISH       =13;  //LANG_SWEDISH
 SCE_SYSTEM_PARAM_LANG_DANISH        =14;  //LANG_DANISH
 SCE_SYSTEM_PARAM_LANG_NORWEGIAN     =15;  //LANG_NORWEGIAN
 SCE_SYSTEM_PARAM_LANG_POLISH        =16;  //LANG_POLISH
 SCE_SYSTEM_PARAM_LANG_PORTUGUESE_BR =17;  //LANG_PORTUGUESE  SUBLANG_PORTUGUESE_BRAZILIAN
 SCE_SYSTEM_PARAM_LANG_ENGLISH_GB    =18;  //LANG_ENGLISH     SUBLANG_ENGLISH_UK
 SCE_SYSTEM_PARAM_LANG_TURKISH       =19;  //LANG_TURKISH
 SCE_SYSTEM_PARAM_LANG_SPANISH_LA    =20;  //LANG_SPANISH     else
 SCE_SYSTEM_PARAM_LANG_ARABIC        =21;  //LANG_ARABIC
 SCE_SYSTEM_PARAM_LANG_FRENCH_CA     =22;  //LANG_FRENCH      SUBLANG_FRENCH_CANADIAN

 // Date
 SCE_SYSTEM_PARAM_DATE_FORMAT_YYYYMMDD=0;
 SCE_SYSTEM_PARAM_DATE_FORMAT_DDMMYYYY=1;
 SCE_SYSTEM_PARAM_DATE_FORMAT_MMDDYYYY=2;

 // Time
 SCE_SYSTEM_PARAM_TIME_FORMAT_12HOUR=0;
 SCE_SYSTEM_PARAM_TIME_FORMAT_24HOUR=1;

 //
 SCE_SYSTEM_SERVICE_MAX_SYSTEM_NAME_LENGTH=65;

 //
 SCE_SYSTEM_PARAM_GAME_PARENTAL_OFF    =0;
 SCE_SYSTEM_PARAM_GAME_PARENTAL_LEVEL01=1;
 SCE_SYSTEM_PARAM_GAME_PARENTAL_LEVEL02=2;
 SCE_SYSTEM_PARAM_GAME_PARENTAL_LEVEL03=3;
 SCE_SYSTEM_PARAM_GAME_PARENTAL_LEVEL04=4;
 SCE_SYSTEM_PARAM_GAME_PARENTAL_LEVEL05=5;
 SCE_SYSTEM_PARAM_GAME_PARENTAL_LEVEL06=6;
 SCE_SYSTEM_PARAM_GAME_PARENTAL_LEVEL07=7;
 SCE_SYSTEM_PARAM_GAME_PARENTAL_LEVEL08=8;
 SCE_SYSTEM_PARAM_GAME_PARENTAL_LEVEL09=9;
 SCE_SYSTEM_PARAM_GAME_PARENTAL_LEVEL10=10;
 SCE_SYSTEM_PARAM_GAME_PARENTAL_LEVEL11=11;

 //
 SCE_SYSTEM_PARAM_ENTER_BUTTON_ASSIGN_CIRCLE=0;
 SCE_SYSTEM_PARAM_ENTER_BUTTON_ASSIGN_CROSS =1;

function ps4_sceSystemServiceParamGetInt(paramId:Integer;value:Pinteger):Integer; SysV_ABI_CDecl;
var
 info:DWORD;
 Format:array[0..0] of AnsiChar;
 z:timezone;
begin
 Writeln('ParamGetInt:',paramId);
 Result:=SCE_SYSTEM_SERVICE_ERROR_PARAMETER;
 if (value=nil) then Exit;
 value^:=0;

 Case paramId of
  SCE_SYSTEM_SERVICE_PARAM_ID_LANG,
  SCE_SYSTEM_SERVICE_PARAM_ID_GAME_PARENTAL_LEVEL,
  SCE_SYSTEM_SERVICE_PARAM_ID_ENTER_BUTTON_ASSIGN:Result:=0;
  else
    Exit;
 end;

 Case paramId of
  SCE_SYSTEM_SERVICE_PARAM_ID_LANG:
   begin
    _sig_lock;
    info:=GetThreadLocale;
    _sig_unlock;
    info:=info and $FFFF;

    Case (info and $3FF) of //LANG_*
     LANG_JAPANESE  :value^:=SCE_SYSTEM_PARAM_LANG_JAPANESE;

     LANG_ENGLISH   :
      Case (info shr 10) of //SUBLANG_*
       SUBLANG_ENGLISH_UK:value^:=SCE_SYSTEM_PARAM_LANG_ENGLISH_GB;
       else               value^:=SCE_SYSTEM_PARAM_LANG_ENGLISH_US;
      end;

     LANG_FRENCH    :
      Case (info shr 10) of //SUBLANG_*
       SUBLANG_FRENCH_CANADIAN:value^:=SCE_SYSTEM_PARAM_LANG_FRENCH_CA;
       else                    value^:=SCE_SYSTEM_PARAM_LANG_FRENCH;
      end;

     LANG_SPANISH   :
      Case (info shr 10) of //SUBLANG_*
       SUBLANG_SPANISH,
       SUBLANG_SPANISH_MEXICAN,
       SUBLANG_SPANISH_MODERN:value^:=SCE_SYSTEM_PARAM_LANG_SPANISH;
       else
                              value^:=SCE_SYSTEM_PARAM_LANG_SPANISH_LA;
      end;

     LANG_GERMAN    :value^:=SCE_SYSTEM_PARAM_LANG_GERMAN;
     LANG_ITALIAN   :value^:=SCE_SYSTEM_PARAM_LANG_ITALIAN;
     LANG_DUTCH     :value^:=SCE_SYSTEM_PARAM_LANG_DUTCH;

     LANG_PORTUGUESE:
      Case (info shr 10) of //SUBLANG_*
       SUBLANG_PORTUGUESE:value^:=SCE_SYSTEM_PARAM_LANG_PORTUGUESE_PT;
       else               value^:=SCE_SYSTEM_PARAM_LANG_PORTUGUESE_BR;
      end;

     LANG_RUSSIAN   :value^:=SCE_SYSTEM_PARAM_LANG_RUSSIAN;
     LANG_KOREAN    :value^:=SCE_SYSTEM_PARAM_LANG_KOREAN;

     LANG_CHINESE   :
      Case (info shr 10) of //SUBLANG_*
       SUBLANG_CHINESE_SIMPLIFIED:value^:=SCE_SYSTEM_PARAM_LANG_CHINESE_S;
       else                       value^:=SCE_SYSTEM_PARAM_LANG_CHINESE_T;
      end;

     LANG_FINNISH   :value^:=SCE_SYSTEM_PARAM_LANG_FINNISH;
     LANG_SWEDISH   :value^:=SCE_SYSTEM_PARAM_LANG_SWEDISH;
     LANG_DANISH    :value^:=SCE_SYSTEM_PARAM_LANG_DANISH;
     LANG_NORWEGIAN :value^:=SCE_SYSTEM_PARAM_LANG_NORWEGIAN;
     LANG_POLISH    :value^:=SCE_SYSTEM_PARAM_LANG_POLISH;
     LANG_TURKISH   :value^:=SCE_SYSTEM_PARAM_LANG_TURKISH;
     LANG_ARABIC    :value^:=SCE_SYSTEM_PARAM_LANG_ARABIC;

     else
      value^:=SCE_SYSTEM_PARAM_LANG_ENGLISH_US;
    end;

   end;

  SCE_SYSTEM_SERVICE_PARAM_ID_DATE_FORMAT:
   begin
    Format[0]:=#0;
    _sig_lock;
    GetLocaleInfo(LOCALE_USER_DEFAULT,LOCALE_ILDATE,@Format,1);
    _sig_unlock;

    Case Format[0] of
     '0':value^:=SCE_SYSTEM_PARAM_DATE_FORMAT_MMDDYYYY;
     '1':value^:=SCE_SYSTEM_PARAM_DATE_FORMAT_DDMMYYYY;
     '2':value^:=SCE_SYSTEM_PARAM_DATE_FORMAT_YYYYMMDD;
    end;
   end;

  SCE_SYSTEM_SERVICE_PARAM_ID_TIME_FORMAT:
   begin
    Format[0]:=#0;
    _sig_lock;
    GetLocaleInfo(LOCALE_USER_DEFAULT,LOCALE_ILDATE,@Format,1);
    _sig_unlock;

    Case Format[0] of
     '0':value^:=SCE_SYSTEM_PARAM_TIME_FORMAT_12HOUR;
     '1':value^:=SCE_SYSTEM_PARAM_TIME_FORMAT_24HOUR;
    end;
   end;

  SCE_SYSTEM_SERVICE_PARAM_ID_TIME_ZONE:
   begin
    Swgettimezone(@z);
    value^:=z.tz_minuteswest;
   end;

  SCE_SYSTEM_SERVICE_PARAM_ID_SUMMERTIME:
   begin
    Swgettimezone(@z);
    value^:=z.tz_dsttime;
   end;

  SCE_SYSTEM_SERVICE_PARAM_ID_SYSTEM_NAME:;
  SCE_SYSTEM_SERVICE_PARAM_ID_GAME_PARENTAL_LEVEL:value^:=SCE_SYSTEM_PARAM_GAME_PARENTAL_OFF;
  SCE_SYSTEM_SERVICE_PARAM_ID_ENTER_BUTTON_ASSIGN:value^:=SCE_SYSTEM_PARAM_ENTER_BUTTON_ASSIGN_CIRCLE;
 end;
end;

procedure ps4_sceSystemServiceHideSplashScreen; assembler; nostackframe;
asm
 xor %rax,%rax
end;

type
 PSceSystemServiceDisplaySafeAreaInfo=^SceSystemServiceDisplaySafeAreaInfo;
 SceSystemServiceDisplaySafeAreaInfo=packed record
  ratio:Single; //Ratio of the safe area (0.9 or more, 1.0 or less)
  reserved:array[0..127] of Byte;
 end;

function ps4_sceSystemServiceGetDisplaySafeAreaInfo(info:PSceSystemServiceDisplaySafeAreaInfo):Integer; SysV_ABI_CDecl;
begin
 Result:=SCE_KERNEL_ERROR_UNKNOWN;
 if (info=nil) then Exit(SCE_SYSTEM_SERVICE_ERROR_PARAMETER);
 info^.ratio:=1.0;
 Result:=0;
end;

type
 PSceSystemServiceStatus=^SceSystemServiceStatus;
 SceSystemServiceStatus=packed record
  eventNum:Integer;
  isSystemUiOverlaid,
  isInBackgroundExecution,
  isCpuMode7CpuNormal,
  isGameLiveStreamingOnAir,
  isOutOfVrPlayArea:Boolean;
  reserved:array[0..124] of Byte;
 end;

function ps4_sceSystemServiceGetStatus(status:PSceSystemServiceStatus):Integer; SysV_ABI_CDecl;
begin
 if status=nil then Exit(SCE_SYSTEM_SERVICE_ERROR_PARAMETER);
 status^.eventNum:=0;
 status^.isSystemUiOverlaid:=false;
 status^.isInBackgroundExecution:=false;
 status^.isCpuMode7CpuNormal:=true;
 status^.isGameLiveStreamingOnAir:=false;
 status^.isOutOfVrPlayArea:=false;
 Result:=0;
end;

function Load_libSceSystemService(Const name:RawByteString):TElf_node;
var
 lib:PLIBRARY;
begin
 Result:=TElf_node.Create;
 Result.pFileName:=name;
 lib:=Result._add_lib('libSceSystemService');
 lib^.set_proc($7D9A38F2E9FB2CAE,@ps4_sceSystemServiceParamGetInt);
 lib^.set_proc($568E55F0A0300A69,@ps4_sceSystemServiceHideSplashScreen);
 lib^.set_proc($D67DFBAB506F7396,@ps4_sceSystemServiceGetDisplaySafeAreaInfo);
 lib^.set_proc($ACFA3AB55F03F5B3,@ps4_sceSystemServiceGetStatus);
end;

initialization
 ps4_app.RegistredPreLoad('libSceSystemService.prx',@Load_libSceSystemService);

end.

