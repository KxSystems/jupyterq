/ parses code.kx ref card to find link in documentation on code.kx for 
/ names of keywords, .Q,.z and .h variables and functions
/ notebooks don't support text/html in tooltips, so a plain text mime bundle is returned along
/ with the text/html one (which can be displayed in a pager by notebooks)
\l jupyterq_htmlgen.q
/ find the link and title for a name as string or symbol
p)def< findkw(soup,kw):
 okw=kw
 if not isinstance(kw,str): return None
 kw = kw[3:] if '.q.' == kw[:3] else '' if kw == '.q' else kw
 if not len(kw): return okw,'Reference card',''
 namespace=False
 if '.'==kw[0] and 2==len(kw): # might be a namespace
  namespace=True
  tag=soup.find('a',attrs={'class':'headerlink','href':'#'+kw[1:].lower()})
 else:
  tag=soup.find('a',text=kw)
 if tag==None:
   return tag
 href=tag.get('href',default='https://code.kx.com/v2/ref/')
 title= tag.parent.fetchNextSiblings('p')[0].text if namespace else tag.get('title',default=kw)
 #title might be peer to the tag
 if title==kw:
  links=soup.findAll('a',attrs={'href':href})
  for link in links:
   if link.get_text()!=kw:
    title=link.get_text()
 return okw,title,href
bs:.p.import[`bs4;`:BeautifulSoup;>]
timeout:$[`timeout in key argDict:.Q.opt .z.x;"J"$first argDict`timeout;5]
if[timeout<0;-1"Invalid timeout input, reverting to default value of 5";timeout:5]
refcard:@[req:{"c"$.p.import[`urllib.request][`:urlopen][x;`timeout pykw y][`:read][]`}[;timeout];(hb:"https://code.kx.com/v2/"),"ref";{0}];
offline:0~refcard; 
if[not offline;findkw:findkw[bs[refcard;`html.parser];]];
find:{$[offline&kw:(x:`$sstring x)in qkw;"Sorry no help is available, as the kernel did not have access to code.kx.com when it was started";kw;findkw x;0]}

sstring:{$[10=type x;;string]x}
/ currently jupyter only supports text/plain tooltips, html content is only shown in pager (SHIFT+TAB 4 times)
mt:{`$"text/",sstring x} / for text types only
/ mime bundle
mb:{ / x can be string or keyword, title and link to code.kx.com
 if[10=type x;:(1#mt`plain)!enlist x];
 html:hg.div hg.h4[x 0],raze[hg.p'[3_x]],hg.p hg.a[`href`target!(x 2;`$"_blank");x 1];
 :mt'[`plain`html]!("\n\n"sv x;html)}
mbud:{[x;v]
 tc:csv sv ("type: ";"count: "),'-3!'(type;count)@\:v;
 l:hb,"basics/datatypes/";
 html:hg.div hg.h4[sstring x],raze hg.p each(tc;hg.pre hg.code[(1#`class)!1#`q;.Q.s v];hg.a[`href`target!(l;"_blank");"Datatypes"]);
 text:"\n\n"sv (sstring x;tc;.Q.s v);
 mt'[`plain`html]!(text;html)}
mbpy:{[x;v;ph]
 tc:("embedPy";"foreign")[.p.i.isf v];
 l:hb,"ml/embedPy";
 html:hg.div hg.h4[sstring x],raze hg.p each(tc," object, help for embedPy is ",hg.a[`href`target!(l;"_blank");"here"];hg.pre hg.code ph);
 text:"\n\n" sv(sstring x;tc," object, for help with embedPy go to: ",l;ph);
 mt'[`plain`html]!(text;html)}
qkw:.Q.res,key`.q;qkw,:` sv'`.q,'key`.q / keywords and .q.contents
/ add .z manually, can't find a neference variable for these
qkw,:` sv'`.z,'`a`ac`b`bm`c`d`D`e`exit`f`h`i`k`K`l`n`N`o`p`P`pc`pd`pg`ph`pi`pm`po`pp`ps`pw`q`s`t`T`ts`u`vs`w`W`wc`wo`ws`x`X`z`Z`zd
qkw,:` sv'`.Q,'key .Q
qkw,:` sv'`.h,'key .h
qkw,:`.j.k`.j.j
qkw,:`.q`.z`.Q`.h`.j / namespaces
qkw@:where not null qkw
help:{
 / hack as .z.t/T/d/D have different links
 if[u:(`$sstring ox:x)in` sv'`.z,'`d`D`t`T;x:".z.T"]; //"time/date shortcuts"];
 $[10=t:type info:find x;:mb info;0=t;;                                            / keyword and offline (return text error) or online continue
   first v:@[(0;)@value@;x;(1;)];:mb"Sorry no help available for:\n\n ",sstring x; / something unknown
   "no help available"~ph:@[value;`.p.helpstr;{{""}}]v 1;:mbud[x;v 1];             / user defined, but not embedPy or foreign python object
    :mbpy[x;v 1]ph];                                                               / python/embedPy object
 if[u;info[0]:sstring x:ox];                                                       / replace the original name if .z.t/T/d/D   
 if[info[2]like"http*";:mb info];                                                  / in case links returned are absolute
 :mb("";"";hb,"ref/"),'info;
 }
   

        

 
