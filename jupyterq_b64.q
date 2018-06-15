\d .b64
eb:`:./jupyterq 2:`b64enc,1     / encoded bytes, each byte is a (reversed bit) index into 0-64
ebra:`:./jupyterq 2:`b64encra,3 / encoded chars, given alphabet and map of bytes to bit reversed bytes
db:`:./jupyterq 2:`b64dec,1     / decode bytes (indexes into alphabet), to bit reversed original bytes
dbr:`:./jupyterq 2:`b64decr,2   / decode bytes (indexes into alphabet), to original bytes
/ reverse bits in byte (just indexed when used)
rbt:0b sv'reverse each 0b vs'"x"$til 256      
/ alphabet is standard, padding chars are "="
al:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
encq:{{(neg[x]_y),x#"="}[n]al rbt eb rbt x,(n:mod[;3]neg count[x]mod 3)#0x0} 
decq:{neg[sum"="=-2#x]_rbt db rbt "x"$al?x}
/ these versions do the alphabetising and bit reversing in c as cast seems to be costly
/ bit faster for large arrays (~5x)
enc:{{(neg[x]_y),x#"="}[n]ebra[rbt;al]x,(n:mod[;3]neg count[x]mod 3)#0x0}	
dec:{neg[sum"="=-2#x]_dbr[rbt]"x"$al?x}
