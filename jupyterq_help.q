/ parses code.kx ref card to find link in documentation on code.kx for 
/ names of keywords, .Q,.z and .h variables and functions
/ notebooks don't support text/html in tooltips, so a plain text mime bundle is returned along
/ with the text/html one (which can be displayed in a pager by notebooks)
\l jupyterq_htmlgen.q
p)def< findkw(soup,kw):
 tag=soup.find('a',text=kw)
 if tag==None:
  return tag
 href=tag.get('href',default='https://code.kx.com')
 title=tag.get('title',default=kw)
 #title might be peer to the tag
 if title==kw:
  links=soup.findAll('a',attrs={'href':href})
  for link in links:
   if link.get_text()!=kw:
    title=link.get_text()
 return kw,title,href
bs:.p.import[`bs4;`:BeautifulSoup;>]
refcard:@[.Q.hg;`:http://code.kx.com/q/ref/card/;{0}]; / .Q.hg doesn't support https?
offline:0~refcard; 
if[not offline;
 s:bs[refcard;`html.parser];
 / find the link and title for a name as string or symbol
 find:findkw[s;];
 ];
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
 l:"https://code.kx.com/q/ref/datatypes/";
 html:hg.div hg.h4[sstring x],raze hg.p each(tc;hg.pre hg.code[(1#`class)!1#`q;.Q.s v];hg.a[`href`target!(l;"_blank");"Datatypes"]);
 text:"\n\n"sv (sstring x;tc;.Q.s v);
 mt'[`plain`html]!(text;html)}

help:{
 if[offline;:mb"Sorry no help is available, as the kernel did not have access to code.kx.com when it was started"];
 / hack as .z.t/T/d/D have different links
 if[u:(`$sstring ox:x)in` sv'`.z,'`d`D`t`T;x:"time/date shortcuts"];
 if[(::)~info:find x;
  :$[first v:@[(0;)@value@;x;{(1;x)}];
    mb"Sorry no help available for:\n\n ",sstring x;
   "no help available"~ph:@[value;`.p.helpstr;{{""}}]v 1;
    mbud[x;v 1];
    mb ph]
 ];
 if[u;info[0]:sstring ox]; / replace the original name if .z.t/T/d/D
 if[info[2]like"http*";:mb info]; / in case links are absolute?
 if[".."~2#info 2;:mb("";"";"https://code.kx.com/q/ref/card/"),'info];
 :mb"Sorry no help available for:\n\n ",sstring x; / default
 }

 
