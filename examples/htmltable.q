/ display a table as an html table
html:.qpk.hg
/ list of selectors, each element is (selector, symbol;declarations, ((key1, string;val1, string);...;(keyn, string;valn, string)))
style:()
style,:enlist(`col.jupyterqkeycol;enlist("background-color";"#ccffff"))
style,:enlist(`col.jupyterqvalcol;(("background-color";"#ffffcc");("foreground-color";"red")))

selector:{string[x 0]," {\n\t",("\n\t"sv{x,":",y,";"}.'x 1),"\n}\n"}
tabstyle:raze selector each style;

displayhtmltab:{[mrows;mcols;table]
 e:"type: only displays tables";$[98=t:type table;;not 99=t;'e;not all 98=(type key@;type value@)@\:table;'e;];
 tddot:html.td"..";
 / key and value column count
 vc:count[cols table]-kc:count keys table;
 colgroup:html.colgroup raze{$[x;html.col`span`class!(x;y);""]}.'(kc,`jupyterqkeycol;vc,`jupyterqvalcol);

 cs:$[ce:mcols<count cso:cols t:0!table;(mcols#cso),`..;cso];
 head:html.thead raze html.th each string cs; /header

 rows:raze{[suf;row]html.tr raze[{html.td .Q.s x}each value row],suf}[("";tddot)ce]each mrows sublist(mcols sublist cso)#t;
 if[mrows<count t;rows,:html.tr raze count[cs]#enlist tddot];

 footer:html.p` sv {": "sv html.sstring x}each
  ((`Rows:;count table);
   (`Columns:;count cols table)
  );

 (`..mime;(1#`$"text/html")!enlist html.style[tabstyle],html.table[colgroup,head,html.tbody rows],footer;::)
 }

