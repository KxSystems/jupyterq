\d .matplotlib
isroutine:.p.import[`inspect;`:isroutine];
getmembers:.p.qcallable .p.import[`inspect;`:getmembers];
wrapm:{[x]
 names:getmembers[x;isroutine];
 res:``_pyobj!((::);x);
 res,:(`$names[;0])!{.p.pycallable y 1}[x]each names;
 res}
pyplot:{wrapm .p.import`matplotlib.pyplot}

\d .
