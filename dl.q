\l jupyterq_b64.q
dl:{[b;url]$[b;.b64.dec first@;`/:]system"curl -s -L ",url,$[b;"|base64 -w0";""]}     
dlep:{
 relurl:first exec browser_download_url from
  .j.k[dl[0b]"https://api.github.com/repos/KxSystems/embedPy/releases/",$[not[count x]|x~"latest";"latest";"tags/",x]][`assets] where
   name like{"*",x,"*"}(`m64`l64`w64!string`osx`linux`windows).z.o;
 $[not count relurl;'"release not found";-1"downloading embedpy from ",relurl];
 (last ` vs hsym`$relurl)1:dl[1b]relurl;
 }
