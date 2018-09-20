/ execution server, code, data lives in this process
/ TODO, closed std handle?
\d .qpk
\p 0W
iod:{y 0x06,("x"$"QPKIO"),(0x0 vs count mcs),mcs:-8!x} / write indication of start of stdio/err during message handling
setstate:{[f;z;s;mc]F::f;Z::z;S::s;iod[MC::mc]'[1 2]}  / set latest message state 
krnh:neg hopen"J"$.z.x 0;                              / handle to kernel
krnsi:neg hopen"J"$.z.x 0;                             / handle to kernel for stdin requests
krnsi(`.qpk.srvregsi;`)                                / register stdin handle on server
krnh(`.qpk.srvreg;"j"$system"p");                      / register
krn:{krnh x;krnh[];}                                   / send and async flush
.z.pc:{if[x=neg krnh;exit 0]}                          / exit if lost connection to kernel
/stdout/err redirection, windows uses named pipes so not necessary
if[not .z.o like"w*";
 std:hopen'[2#"J"$.z.x 0];
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
\l jupyterq_execution.q
/ send request to frontend for python getpass.getpass and input functions
/ TODO readline()
p)import io
p)class> stdreader(io.TextIOBase):
 def __init__(self,qfunc=None):
  import getpass
  self.qfunc=qfunc
  __builtins__.input=self.input
  getpass.getpass=self.getpass
 def input(self,prompt=None):
  return self.qfunc(prompt if prompt else "",False)
 def getpass(self,prompt=None): #TODO optional streams parameter, (should error)
  return self.qfunc(prompt if prompt else "",True)
 
readstdin:{krnsi(`.qpk.srvinput;Z;S;MC;x;y);$[1~first r:neg[krnsi][];'r 1;r]}
{.p.import[`sys][:;x;stdreader y]}'[`:stdin;readstdin];

execmsg:{[f;z;s;mc]setstate[f;z;s;mc];                 / handle a request from kernel, only handle locally if not a remote request
 if[not remote[f;z;s;mc];df[h;f][z;s]mc]}
//execmsg:{[f;z;s;mc]setstate[f;z;s;mc];df[h;f][z;s]mc}
remote:{[f;z;s;mc]                                     / check if request is for a remote server and forward if so
 remote:sum(c:` vs mc .`content`code)like"/%remote*";
 $[0=remote;:0b;
   1<remote;snderr[f;z;s;mc;("too many /%remotes";"")];
   fwd[f;z;s;mc]];1b}    / check if is single remote call and fwd if so, otherwise execute locally or error
fwd:{[f;z;s;mc]
 remote:@[value;rdef:count[rid]_c first where(c:` vs mc .`content`code)like(rid:"/%remote"),"*";-1];
 $[-1~remote;snderr[f;z;s;mc;("invalid remote";` vs rdef)];
   neg[remote](rexec;f;z;s;mc)]}
snderr:{[f;z;s;mc;e]krn(`.qpk.srvres;z;s;mc;(1;e;exn));krncmp[f;z;s;mc;(1;e;exn)]}

/
   
   / else check remote capability ... sync possibility to block, i.e. what we want, probably not, ok to block from UI perspective, but not server...
 
fwd:{[f;z;s;mc] / TODO error handling
 remote:@[value;count[rid]_c first where(c:` vs mc .`content`code)like(rid:"/%remote"),"*";-1];
 neg[remote](`.qpk.execmsg;f;z;s;mc);
 } / forward message for execution on remote server
\
setqbackend[mpcb;sndsrvcomm;clearoutput;ipython];

