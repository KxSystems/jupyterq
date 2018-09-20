/ to be loaded into any kdb+ process 
\d .qpk
if[not system"p";'"must be listening on a port"]
if[1b~@[value;`.qpk.loaded;0b];'"already loaded"];
\l jupyterq_execution.q
loaded:1b
setstate:{[f;z;s;mc]F::f;Z::z;S::s;MC::mc;krnh::neg .z.w}     / set latest message state
krn:{krnh(`.qpk.krn;x);krnh[];}                               / send and async flush
execmsg:{[f;z;s;mc]setstate[f;z;s;mc];df[h;f][z;s]mc}  / handle a request from kernel
setqbackend[mpcb;sndsrvcomm;clearoutput;ipython];
