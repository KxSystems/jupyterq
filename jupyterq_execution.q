/ execution server, code, data lives in this process
/ TODO, closed std handle?
\d .qpk

show "1";

.pykx.enabled:0b;
@[{system"l ",x;.pykx.enabled:1b};
  "pykx.q";
  {show "PyKX failed to initialise with error", x;system"l p.q"}
  ]

if[.pykx.enabled;.p:.pykx];

\l jupyterq_b64.q
\l jupyterq_help.q
setdef:{x set @[value;x;{x}y]}                         / set x to default value y if not already set
setdef[;(::)]each`F`Z`S`MC;                            / latest exec request from kernel,zmqid,socket and message
setdef[`exn;0];                                        / execution count
fexists:{x~key x:hsym`$sstring x}                      / file exists, (used for /%loadscript and /%savescript)
df:{x k?[;y]k:key x}                                   / helper, return entry at ` for a dict of funcs if y not present 

jloads:{@[x;y;{y;x}y]}.p.import[`json;`:loads][>]      / get python object from json
jconv:{jloads .j.j x}                                  / convert q to json then load as python object

comms:(`u#enlist"")!enlist`targ`data`py!3#()           / currently open comms, comm_id!info

/ response formatting
md:{(1#x)!1#y}                                         / make one item dict
mime:{$[`..mime~first x;                               / dict of mime type to data
  {$[x~(::);()!();k!mc'[k:key x;value x]]}each 1_x;    
  (md[`$"text/plain"]enlist .Q.s x;()!())]}
mc:{[mt;d]$[(.[{.b64.decq x;0b};enlist -1_d;1b])&(mt like"image/*")&not mt like"*svg+xml";  / mime content, just encodes non svg images for now
  .b64.enc"x"$d;d]}

/ code evaluation
/ return (1;(error string;backtrace frames)) only return user backtrace and adjust the frame numbers
ef:{
 $[y~();
   (1;(x;()));  / if empty backtrace just return
  1=count y;    / it's a naked q statement stack frame number will be wrong
   (1;(x;.Q.pl each .[y;(0;3);:;0])); 
  /else
   (1;(x;.Q.pl each .[;(::;3);-;count[y]-u](u:y[;1;0]?".Q.trp")#y))]} 
/ this is 'script like' execution of code x by function y
k)l:{r@&~(::)~'r:y{x y}'"\n"/:'x(&|1^\|0N 0 1"/ "?*:'x[i],'"/")_i:&~|':(b?-1)#b:+\-/(x:$[@x;`\:;]x)~\:/:+,"/\\"}

trp:{.Q.trp[(0;)@ev@;` vs x;ef]}                       / wrap .Q.trp to return (0;result)|(1;error(from ef))
ev:l[;{krnsnd[`.qpk.srvres].Q.trp[(0;)@"q"@;x;ef]}]    / evaluate and send each result to kernel

krnsnd:{[f;x]                                          / send result to kernel 
 if[x~(0;::);:()];                                     / nothing to send if no output of statement
 krn(f;Z;S;MC;(x 0;$[x 0;;mime]x 1;exn+1));            / exn+1 because not yet incremented, want +1 per *client* request
 if[1=x 0;exfinalise[];'`err];                         / any cleanup then signal an error so we don't execute remainder of request
 }
krncmp:{[f;z;s;mc;res]krn(`.qpk.srvcmp;f;z;s;mc;res)}  / complete request on kernel
execmsg:{[f;z;s;mc]setstate[f;z;s;mc];df[h;f][z;s]mc}  / handle a request from kernel
rexec:{[f;z;s;mc]$[`execmsg in key`.qpk;               / sent and executed on remote process to check it's capability
 .qpk.execmsg[f;z;s;mc];
 neg[.z.w](`.qpk.snderr;f;z;s;mc;("unsupported server";` vs"remote does not support jupyterq, load jupyterq_remote.q in server"))]}

h.execute:{[z;s;mc]                                    / execute code
 if[first u:pmagic[z;s;mc];:()];                       / pmagic gives (1;mc) if already completed, o/w (0;modified message content)
 mcn:u 1; / updated commands if any
 err:first res:trp mcn .`content`code;
 if[not[err]and mcn .`content`store_history;exn+:1];
 exfinalise[];
 krncmp[`execute;z;s;mc;(res 0;res 1;exn)];
 }
exfinalise:{[]value each excallbacks}                  / evaluate and cleanup required after execution
excallbacks:()

h.complete:{[z;s;mc]                                   / code completion
 krncmp[`complete;z;s;mc]match[p#c;c:mcc`code;p:"j"$(mcc:mc`content)`cursor_pos]; 
 }
h.inspect:{[z;s;mc]                                    / code introspection (help)
 if[(p:"j"$mcc`cursor_pos)>count c:(mcc:mc`content)`code;p:count c]; / jupyter notebook has bug where with a selection only selected text is sent but cursor_pos refers to position in cell
 krncmp[`inspect;z;s;mc]inspt[p#c;c;p;"j"$mcc`detail_level];
 }
/ comm handling frontend -> server
h.comm_info:{[z;s;mc]krncmp[`comm_info;z;s;mc;enlist[`comms]!enlist enlist[""]_comms@\:`targ]}    
h.comm_open:{[z;s;mc]krncmp[`commdef;z;s;mc;`]}  
h.comm_close:{[z;s;mc]krncmp[`commdef;z;s;mc;`]}  
h.comm_msg:{[z;s;mc]
 id:mc . `content`comm_id;
 $[(id:mc . `content`comm_id)in key comms; 
  .p.call[.p.getattr[comms[id]`py;`handle_msg];enlist .p.q2py @[mc;key[mc]except`buffers;jconv];()!()]; 
  0N!"pyobj not found for comm_id ",mc .`content`comm_id];
 krncmp[`commdef;z;s;mc;`]}
h[`]:{[z;s;mc]                                         / default print an error message in kernel if unrecognised handler
 krn({-2"unrecognised .qpk.exec request function:",string x};F)}

/ comm handling server -> frontend
sndsrvcomm:{[py;mt;c;m;b]                              / comm messages from python callback, manage if open or close then send via kernel
 df[mcomm;mt:`$5_mt][py;c;m;b];
 krn(`.qpk.sndcomm;mt;Z;MC;c;m;b);}
mcomm.open:{[py;c;m;b]                                 / keep track of the comm being opened 
 comms[c`comm_id]:`targ`data`py!(c`target_name;c`data;py)}
mcomm.close:{[py;c;m;b]                                / drop reference to comm  
 comms::{(`u#key x)!value x}enlist[c`comm_id]_comms}
mcomm[`]:{[py;c;m;b]}                                  / default do nothing

/ magic command processing, only /%loadscript and /%savescript supported for now (TODO more)
magic.loadscript:{[z;s;c;mc;p]
 arg:(1+c[p]?" ")_c p;
 if[not fexists arg;
  krncmp[`loadscript;z;s;MC;(1;("File doesn't exist";trim arg);exn)];  / return error to client
  :(1;mc); / stop processing
 ];
 cc:(0,p)cut c;
 nc:read0`$arg;
 mc[`content;`code]:` sv cc[0],enlist["/begin ",c p],nc,@[cc 1;0;{"/end ",x}];
 krncmp[`loadscript;z;s;MC;(0;mc;exn)];
 :(1;mc);
 }
magic.savescript:{[z;s;c;mc;p]
 arg:(ssr[;"  ";" "]/)ssr[;"\t";" "](1+c[p]?" ")_c p;
 f:hsym`$sf:first u:("*B";" ")0:arg;
 o:last u;
 if[not[o]&fexists f; / don't overwrite unless requested
  krncmp[`savescript;z;s;MC;(1;("File exists, use /%savescript filename 1 to overwrite existing file";trim arg);exn)];
  :(1;mc)]; / stop processing
 if[not f~r:@[f 0:;c _p;{x}];
  krncmp[`savescript;z;s;MC;(1;("File ",sf," couldn't be written, error was: ",r;trim arg);exn)];
  :(1;mc)];
 -1 sf," saved";
 krncmp[`savescript;z;s;MC;(0;mc;exn)];
 :(1;mc);
 }
/ treat code cell as containing python code, prepend p) to everything not indented
magic.python:{[z;s;c;mc;p]mc[`content;`code]:` sv l[;{"p)",$["/%"~2#x;"#",;]x}]c _ p;(0;mc)}
 
magics:enlist["/%loadscript*"]!enlist magic.loadscript
magics[enlist"/%savescript*"]:enlist magic.savescript
magics[enlist"/%python*"]:enlist magic.python
pmagic:{[z;s;mc]
 c:` vs mc .`content`code;
 if[not any any c like/:key magics;:(0;mc)]; / skip search if no magics
 r:(0;mc){[z;s;c;x;y]$[last x 0;x;any u:c[y]like/:key magics;value[magics][first where u][z;s;c;x 1]y;x]}[z;s;c]/til count c;
 :r / has (0;modified message content) if execution should continue (1;mc) if not
 }
  
/ q tokenisation rules, k ignored for now, note this is only to find the token if any
/ not parsing (although parse is used internally to find strings
Q:"\""
kw:.Q.res,key`.q;
/ add .z manually, can't find a reference variable for these
kw,:` sv'`.z,'kz:`a`ac`b`bm`c`d`D`e`exit`f`h`i`k`K`l`n`N`o`p`P`pc`pd`pg`ph`pi`pm`po`pp`ps`pw`q`s`t`T`ts`u`vs`w`W`wc`wo`ws`x`X`z`Z`zd
bcs:" ~!@#$%^&*()-+=[]{}\\|;:',<>/?\r\n\t",Q; /chars which break a token, `. handled separately
bscs:bcs except":" / chars which break symbols, leading _ handled separately
/ find last token given x a string
/ nothing if 'in' a char[] literal or symbol
token:{[e;x;c;p] / x code to be completed,c full code,p cursor_pos,e extend token for possible matches (0 for completion 1 for help)
 / inside string at the end, no matches, use parse as a shortcut
 if[@[{.q.parse x;0b};x;{x~1#Q}];:()];
 / reduce x to tail outside string
 x:{neg[reverse[x]?Q]#x}x;
 /now find if we're in a symbol at end, quotes are gone
 insym:{0<0{$["`"~y;1;x;$[(y in bscs)|(y="_")&1=x;0;1+x];x]}\x};
 if[last is:insym x;:()];  
 / tail to give us just what's not in symbol
 x:{neg[reverse[x]?1b]#y}[is;x]; 
 /  now we have no quotations or symbols to deal with
 if["_"=rx bi:min(rx:reverse x)?bcs,"._";
  f:{[rx;bi]u:min((1+bi)_rx)?bcs,"._";nbi:bi+1+u;$[parse[u]~`$u:reverse nbi#rx;nbi&count rx;bi]};
  bi:f[rx]/[bi];
  ]; 
 / not dot notation return
 if[rx[bi]in bcs,"_";u:etoken[c;p;r:neg[bi]#x];:(0;r,$[e;u;""];p+0,count[u])];
 / otherwise it's dot notation,get the last dotted token
 u:etoken[c;p;r:neg[min reverse[x]?bcs]#x];
 x:r,$[e;u;""];
 / exclude float literals .12, otherwise return any possible keys
 :$[all null[path]|vname each path:` vs`$x;(1;path;p+0,count[u]);()];
 }
etoken:{[c;p;r]min[u?bcs,".`"]#u:p _c}                  / extend a token for midword introspection/completion
spath:{sx:string last x;
 f:{(y[0]-count x;y 1;srt z where z like x,"*")}[sx;y]; / (length of replace text;end position of replace text;possible matches)
 $[0=count p:-1_x;();      / nothing left, no matches
  11=type k:key` sv p;f k; / matches in containing namespace/dict
  ``z~p;f kz;              / .z namespace doesn't actually exist but want to complete in it
  ()]}                     / else no matches
/ valid token, only needs to handle possible inputs as alphanumeric and _
vname:{lower[string[x]0]in .Q.a}
/ matches in q keywords and current namespace 
cmp:{(y[0]-count[x];y 1;srt v where(v:distinct kw,key system"d")like x,"*")}
srt:{x iasc lower x:asc x}                             / sort alphabetically 
/ find possible completions
match:{[x;c;p]$[()~t:token[0;x;c;p];();t 0;spath . 1_t;cmp . 1_t]}
/ provide introspection on a string, instrospection level not used by notebooks
inspt:{[x;c;p;l]$[()~t:token[1;x;c;p];();itoken t 1]}
itoken:{help$[11=type x;sv[`];]x}

/ interface with python for inline display of plots, widgets etc 
setqbackend:{[x;y;z;w]                                 / matplotlib and ipywidgets inline display
 backend:.p.import[`kxpy.kx_backend_inline];
 backend[`:initialise;x;y;z;w];
 excallbacks,:enlist(backend`:flush_figures;::);       / flush all undisplayed figures at the end of cell execution, same as ipython
 }
mpcb:{krnsnd[`.qpk.srvdis](0;(`..mime;x 0;x 1));}      / callback for backend displays for matplotlib, ipywidgets, etc. x 1 is metadata, be sure to return (::)
clearoutput:{krn(`.qpk.srvclear;Z;S;MC;x);}            / clear output of current cell on notebook
pyident:.p.pyeval"lambda *x,**y:None"                  / function which does nothing and can be called with any args in python
/ python object with access to members with obj['name']
p)class> qipython():
 def __init__(self):
  pass
 def __getitem__(self,item):
  return self.__dict__[item]
d2o:{                                                  / convert q dictionary (can have nested dicts) to python object with fields named for keys of dict
 $[99=type x;[.p.setattr[o:qipython[]]'[key x;.z.s each value x];o];x]} 

ipython:{d2o                                           / return fake ipython instance for places that need it in python TODO do we nee anything else here?
  `kernel`showtraceback`register_post_execute!((`$"_parent_header";`comm_manager)!(MC;md[`register_target]pyident);pyident;pyident)}

