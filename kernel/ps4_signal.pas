unit ps4_signal;

{$mode objfpc}{$H+}

interface

uses
 Windows,
 sys_signal;

function  ps4_sigfillset(_set:P_sigset_t):Integer; SysV_ABI_CDecl;
function  ps4_sigaddset(_set:p_sigset_t;signum:Integer):Integer; SysV_ABI_CDecl;
function  ps4_sigprocmask(how:Integer;_set,oldset:P_sigset_t):Integer; SysV_ABI_CDecl;
function  ps4_pthread_sigmask(how:Integer;_set,oldset:P_sigset_t):Integer; SysV_ABI_CDecl;
function  ps4_is_signal_return(param:PQWORD):Integer; SysV_ABI_CDecl;

type
 TsceKernelExceptionHandler=procedure(signum:Integer;context:Pointer); SysV_ABI_CDecl;

function ps4_sceKernelInstallExceptionHandler(signum:Integer;callback:TsceKernelExceptionHandler):Integer; SysV_ABI_CDecl;
function ps4_sceKernelRaiseException(_pthread:Pointer;sig:Integer):Integer; SysV_ABI_CDecl;

implementation

uses
 atomic,
 sys_kernel;

function ps4_sigfillset(_set:p_sigset_t):Integer; SysV_ABI_CDecl;
begin
 if (_set=nil) then Exit(_set_errno(EINVAL));
 _set^.qwords[0]:=QWORD(-1);
 _set^.qwords[1]:=QWORD(-1);
 Result:=0;
end;

function ps4_sigaddset(_set:p_sigset_t;signum:Integer):Integer; SysV_ABI_CDecl;
begin
 Result:=_set_errno(_sigaddset(_set,signum));
end;

function ps4_sigprocmask(how:Integer;_set,oldset:p_sigset_t):Integer; SysV_ABI_CDecl;
begin
 Result:=_set_errno(__sigprocmask(how,_set,oldset));
end;

function ps4_pthread_sigmask(how:Integer;_set,oldset:p_sigset_t):Integer; SysV_ABI_CDecl;
begin
 Result:=__sigprocmask(how,_set,oldset);
end;

//wtf this do?
function ps4_is_signal_return(param:PQWORD):Integer; SysV_ABI_CDecl;
begin
 Result:=1;

 if (param[0]<>$48006a40247c8d48) or
    (param[1]<>$050f000001a1c0c7) or
    ((param[2] and $ffffff)<>$fdebf4) then
 begin
  Result:=ord((PQWORD(PByte(param)-5)^ and $ffffffffff)=$50fca8949)*2;
 end;

end;

function ps4_sigaction(signum:Integer;act,oldact:p_sigaction_t):Integer; SysV_ABI_CDecl;
begin
 Exit(_set_errno(__sigaction(signum,act,oldact)));
end;

function ps4_signal(sig:Integer;func:sig_t):sig_t; SysV_ABI_CDecl;
var
 act,old:sigaction_t;
 ret:Integer;
begin
 act:=Default(sigaction_t);
 old:=Default(sigaction_t);

 act.__sigaction_u.__sa_handler:=func;
 act.sa_flags:=SA_RESTART;

 ret:=__sigaction(sig,@act,@old);

 if (ret<>0) then
 begin
  _set_errno(ret);
  Exit(sig_t(SIG_ERR));
 end;

 Result:=old.__sigaction_u.__sa_handler;
end;

var
 EX_HANDLERS:array[0..31] of TsceKernelExceptionHandler;

procedure __ex_handler(sig,code:Integer;ctx:Pointer); SysV_ABI_CDecl;
var
 cb:TsceKernelExceptionHandler;
begin
 if not _SIG_VALID_32(sig) then Exit;
 cb:=EX_HANDLERS[_SIG_IDX(sig)];
 if (cb<>nil) then
 begin
  cb(sig,ctx);
 end;
end;

function ps4_sceKernelInstallExceptionHandler(signum:Integer;callback:TsceKernelExceptionHandler):Integer; SysV_ABI_CDecl;
var
 act:sigaction_t;
begin
 if not _SIG_VALID_32(signum) then Exit(SCE_KERNEL_ERROR_EINVAL);

 if CAS(Pointer(EX_HANDLERS[_SIG_IDX(signum)]),nil,Pointer(callback)) then
 begin

  act:=Default(sigaction_t);
  act.__sigaction_u.__sa_handler:=@__ex_handler;
  act.sa_flags:=SA_RESTART;

  Result:=px2sce(__sigaction(signum,@act,nil));
 end else
 begin
  Result:=SCE_KERNEL_ERROR_EAGAIN;
 end;

end;

function ps4_sceKernelRaiseException(_pthread:Pointer;sig:Integer):Integer; SysV_ABI_CDecl;
begin
 Result:=EINVAL;
 if (sig=SIGUSR1) then
 begin
  Result:=_pthread_kill(_pthread,SIGUSR1);
 end;
 Result:=px2sce(Result);
end;


end.






