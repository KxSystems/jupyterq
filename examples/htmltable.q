/ display a table as an html table
html:.qpk.hg
displayhtmltab:{[mcols;mrows;table]
 cs:$[ce:mcols<count cs:cols t:0!table;(mcols#cs),`...;cs];
 head:html.thead raze html.th each string cs;
 rows:raze{[rsuf;row]html.tr raze[html.td each value .Q.s each row],rsuf}[$[ce;html.td string last cs;""]]each mrows sublist sublist[mcols;cols t]#t;
 if[mrows<count t;rows,:html.tr raze html.td each string count[cs]#`...];
 (`..mime;(1#`$"text/html")!enlist html.table[head,html.tbody rows],html.p "somefooter";::)
 }

