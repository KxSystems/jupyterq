qhome:hsym`$$[not count u:getenv`QHOME;[-2"QHOME not defined";exit 1];u];
dl:{[s;url]$[s;;`/:]system"curl -u ",getenv[`GH_APIREAD]," -s -L ",url,$[s;" -J -O";""]}
download:{
 assets:.j.k[dl[0b]"https://api.github.com/repos/KxSystems/embedPy/releases/",$[not[count x]|x~"latest";"latest";"tags/",x]]`assets;
 relurl:first exec browser_download_url from assets where name like{"*",x,"*"}(`m64`l64`w64!string`osx`linux`windows).z.o;
 $[count relurl;-1"downloading embedpy from ",relurl;'"release not found"];
 dl[1b]relurl;last ` vs hsym`$relurl}
extract:{system$[x like"*.tgz";"tar -zxf";x like"*.zip";$[.z.o~`w64;"7z x -y";"unzip"];'"not zip or tgz"]," ",string x}
install:{{(` sv qhome,x)1:read1 x}each`p.k`p.q,`${$[x~"w64";x,"/p.dll";x,"/p.so"]}string .z.o}
getembedpy:{@[x;y;{-2"ERROR: ",x;exit 1}]}{install extract download x}
