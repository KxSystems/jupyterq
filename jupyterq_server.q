/ execution server, code, data lives in this process
/ TODO, closed std handle?
\d .qpk
\p 0W
login:getenv`JUPYTERQ_LOGIN;                           / login details
crhp:{$[""~y;x;`$"::",string[x],":",y]}                / create handle with optional username/password
iod:{y 0x06,("x"$"QPKIO"),(0x0 vs count mcs),mcs:-8!x} / write indication of start of stdio/err during message handling
setstate:{[f;z;s;mc]F::f;Z::z;S::s;iod[MC::mc]'[1 2]}  / set latest message state 
khopen:{@[hopen;x;                                     / connect to kernel, exit if jupyter shut it down before we could connect
 {y;-2"Can't connect to kernel :",string[x],
 " jupyter may have shut it down before we could connect";
 exit 1}x]}
krnh:neg khopen crhp["J"$.z.x 0;login];                / handle to kernel
krnsi:neg khopen crhp["J"$.z.x 0;login];               / handle to kernel for stdin requests
krnsi(`.qpk.srvregsi;`)                                / register stdin handle on server
krnh(`.qpk.srvreg;crhp["j"$system"p";login]);          / register
krn:{krnh x;krnh[];}                                   / send and async flush
.z.pc:{if[x=neg krnh;exit 0]}                          / exit if lost connection to kernel
/stdout/err redirection, windows uses named pipes so not necessary
if[not .z.o like"w*";
 std:hopen'[2#crhp["J"$.z.x 0;login]];
 {y(`.qpk.regstd;x);y[]}'[1 2i;neg std];               / open and register stdout/error sockets on kernel
 redir:`:./jupyterq 2:`redir,2;                        / redirect std handle y to socket x
 revert:`:./jupyterq 2:`revert,2;                      / revert std handle y to fd x
 rfd:{if[not count r:read1 x;revert[rvfd x]x;          / read, if socket closed revert to rvfd
  rcb[x]0b;rvfd::rvfd except x;'`close]};
 rstd:{while[not 0~@[rfd;x;0];]};                      / read all available from socket, data discarded as should not have received anything
 cb:{if[x in 1 2i;rstd x]};                            / if activity on redirected socket, check it's alive
 .z.pc:{x y;if[y~neg krnh;revert'[origfd;1 2i]]}.z.pc; / redirect to original when kernel disconnects
 rvfd:redir'[std;1 2i];                                / redirect the output/error, keep fds to original streams in rvfd
 ];
krn(`.qpk.closeport;`)
\l jupyterq_execution.q

/ send request to frontend for python getpass.getpass and input functions
/ TODO readline()
p)import io
p)class stdreader(io.TextIOBase):
 def __init__(self,qfunc=None):
  import getpass
  self.qfunc=qfunc
  __builtins__.input=self.input
  getpass.getpass=self.getpass
 def input(self,prompt=None):
  return self.qfunc(prompt if prompt else "",False)
 def getpass(self,prompt=None): #TODO optional streams parameter, (should error)
  return self.qfunc(prompt if prompt else "",True)
stdreader:.p.get[`stdreader;>]
 
readstdin:{krnsi(`.qpk.srvinput;Z;S;MC;x;y);$[1~first r:neg[krnsi][];'r 1;r]}
{.p.import[`sys][:;x;stdreader y]}'[`:stdin;readstdin];

execmsg:{[f;z;s;mc]setstate[f;z;s;mc];                 / handle a request from kernel, only handle locally if not a remote request
 if[not remote[f;z;s;mc];df[h;f][z;s]mc]}

/ /%remote ... handling
remote:{[f;z;s;mc]                                     / check if request is for a remote server and forward if so
 $[0=n:sum(` vs mc .`content`code)like"/%remote*";:0b; / no remote requests, will execute locally
  1<n;snderr[f;z;s;mc;("too many /%remotes";"")];      / only one /%remote per cell allowed
  fwd[f;z;s;mc]];1b}                                   / forward to a remote server
fwd:{[f;z;s;mc]
 rdef:count[rid]_c first where(c:` vs mc .`content`code)like(rid:"/%remote"),"*";
 e:snderr[f;z;s;mc]{("invalid remote",y;` vs x)}[rdef]@;
 $[-1~remote:@[value;rdef;-1];e" definition";
   not type[remote]in -6 -7h;e", must be a handle";
   not remote>2;e", must be a handle to a remote process";
   @[neg[remote]@;(rexec;f;z;s;mc);{x": ",y,", is the remote a valid handle?"}e]]}
snderr:{[f;z;s;mc;e]                                   / send an error message to frontend and complete the request
 krn(`.qpk.srvdis;z;s;mc;(1;e;exn));krncmp[f;z;s;mc;(1;e;exn)]}

setqbackend[mpcb;sndsrvcomm;clearoutput;ipython];

