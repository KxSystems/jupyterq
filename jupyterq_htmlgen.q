/ utils
/ compose with enlist (for composition trick used for 'variadic functions')
k)hg.ce:{'[y;x]}/enlist,|:
hg.sstring:{$[10=type x;;string]x} 
hg.def:(0#`)!()
/ build a function that takes (optional) attribute dict attrs as first arg required val as second
hg.bt:{ value"hg.ce{` sv raze(enlist\"<",x," \",(\" \"sv hg.pattr hg.def,first -1_x),\">\";` vs last x;enlist\"</",x,">\")}"}
/ same as above for empty tags
hg.bet:{value"{` sv enlist \"<",x," \",(\" \"sv hg.pattr hg.def,x),\"/>\"}"}
/ these are example tags, we can define our own taglist and emptytag list and call bts and bets on these respectively 
hg.taglist :`a`abbr`acronym`address`area`b`bdo`big`blockquote`body`button`caption`cite`code`colgroup   
hg.taglist,:`dd`del`div`dfn`dl`dt`em`fieldset`form`frameset`h1`h2`h3`h4`h5`h6`head`html`i`iframe`ins    
hg.taglist,:`kbd`label`legend`li`map`meta`noframes`noscript`object`ol`optgroup`option`p`pre`q`samp
hg.taglist,:`script`select`small`span`strong`style`sub`sup`table`tbody`td`textarea`tfoot`th`thead`title`tr`tt`ul`var 
/ empty html tags
hg.etaglist:(),`base`bri`col`frame`hr`img`input`link`param 						  
/ builds functions for each tag
(hg.bts:{(` sv `hg,x)set hg.bt string x})each hg.taglist;
/ builds functions for each e(mpty)tag
(hg.bets:{(` sv `hg,x)set hg.bet string x})each hg.etaglist;
// parse attribute list
hg.pattr:{{hg.attrs[$[null hg.attrs[x];`;x]][x;y]}'[key x;value x]}
/ function dict parse attribute list
hg.attrs:(`s#())!()
hg.attrs[`]:{string[x],"=\"",hg.sstring[y],"\""}
/ css class
/attrs[`class]:{"class=\"",hg.sstring[x],"\""}
/ inline style
/ hyperlink
/attrs[`href]:{"href=\"",string[x],"\""}
