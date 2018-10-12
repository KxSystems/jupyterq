/ to be loaded into any kdb+ process 
\d .qpk
if[@[{value x;0};"p)1";{1}];'"embedPy is required"];
\l jupyterq_execution.q
setstate:{[f;z;s;mc]F::f;Z::z;S::s;MC::mc;krnh::neg .z.w}     / set latest message state
krn:{krnh(`.qpk.krn;x);krnh[];}                               / send and async flush
execmsg:{[f;z;s;mc]setstate[f;z;s;mc];df[h;f][z;s]mc}         / handle a request from kernel
/ stdout is not redirected in remotes, messages can be logged from remotes to jupyter frontend with these, e.g. .qpk.stdout"hello remote"
stdlog:{[h;x]krnh({[f;z;s;mc;h;x].qpk.setstate[f;z;s;mc];h x;};F;Z;S;MC;h;x)}
stdout:stdlog 1;stderr:stdlog 2
quiet:@[value;`.qpk.quiet;0b];
if[0b~@[value;`.qpk.loaded;0b];
 .Q.trp[{setqbackend . x;loaded::1b};(mpcb;sndsrvcomm;clearoutput;ipython);
  {$[quiet;;-2]
     "ERROR: couldn't use kxpy/kx_backend_inline for matplotlib, are embedPy and matplotlib installed?\n",
     "JupyterQ will work this server, but matplotlib will not be functional\n",
     "to suppress this message set .qpk.quiet:1b before loading jupyterq_remote.q\n\n",
     .Q.sbt y}];
 ];
