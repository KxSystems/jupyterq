#ifndef _WIN32
#include <unistd.h>
#else
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#pragma comment(lib,"Ws2_32.lib")
#include <ws2tcpip.h>
#endif
#include "k.h"

#define TC(x,T) P(x->t!=T,krr("type")) // return on unexpected type
// assumes bytes in q are stored little endian
#define EB(x) ((G)((0x0000003f&x)<<2))
/* callback functions and methods to add and remove from q for zeromq */
K cb(I fd){r0(k(0,".qpk.cb",ki(fd),(K)0));R (K)0;}
K1(acb){TC(x,-KI);sd1(xi,cb);R (K)0;}
K2(rcb0x){TC(x,-KI);TC(y,-KB);sd0x(xi,y->g);R (K)0;}
K1(npcreate){
#ifdef _WIN32
 TC(x,-KS);
 HANDLE hPipe=CreateNamedPipe(xs,PIPE_ACCESS_INBOUND|FILE_FLAG_WRITE_THROUGH,
                                    PIPE_TYPE_BYTE|PIPE_READMODE_BYTE|PIPE_NOWAIT|PIPE_REJECT_REMOTE_CLIENTS,
                                    1,
                                    65536,
                                    65536,
                                    0,
                                    0);
 ConnectNamedPipe(hPipe,0);
 R ki((I)hPipe);
#else
 R krr("windows only");
#endif
}
K2(revert){
 TC(x,-KI);TC(y,-KI);
 I rfd=dup2(xi,y->i);
 if(-1==rfd)R krr("could not redirect");
 /* done with original socket descriptor, remove from q select loop and close so it can be reused */
 sd0x(xi,0);close(xi);R (K)0;}
K2(redir){
 TC(x,-KI);TC(y,-KI);
 /* dup the original descriptor so the redirection can be reverted later */
 I rfd=dup(y->i);
 if(-1==rfd)R krr("could not duplicate");
 K r=ki(rfd);
 revert(x,y);
 R r;
 }
/* b64 encoding/decoding */
// debug
//void printbits(unsigned int v){int i;for(i = 31; i >= 0; i--) putchar('0' + ((v >> i) & 1));}
/* assumes bytes have been bit reversed s.t. most significant of prev is just prior to least of next 
 * alphabet and padding done elsewhere  */
K1(b64enc){
 TC(x,KG);
 P(xn!=3*(xn/3),krr("length")); // must get triples
 J i,j=0;
 K res=ktn(KG,4*xn/3);
 I bai;
 for(i=0;i<-2+xn;i+=3){ // jump to next triple (which gives an encoded quadruple)
  bai=*(I*)&kG(x)[i];
  kG(res)[j++]=EB(bai);	   
  kG(res)[j++]=EB(bai>>6);  // 6 bits from each byte
  kG(res)[j++]=EB(bai>>12);
  kG(res)[j++]=EB(bai>>18);
 }
 R res;
 }
/* q)0b sv'8 cut raze 2_'x
 * have 4 bytes, don't care about first 2 bits of each (they're zero), so get 3 bytes from this */
K1(b64dec){
 TC(x,KG);
 P(xn!=4*(xn/4),krr("length")); // must have multiple of 4 encoded
 J i,j=0;
 I bai;
 K res=ktn(KG,3*xn/4);
 for(i=0;i<-3+xn;i+=4){ // jump to next quadruple (which gives a decoded triple)
  bai=*(I*)&kG(x)[i];
  kG(res)[j++]=(G)((0x0000003f&bai>>2)|(0x000000c0&bai>>4));   //6 bits from current 2 bits from next
  kG(res)[j++]=(G)((0x0000000f&bai>>12)|(0x000000f0&bai>>14)); //4 bits from current 4 bits from next
  kG(res)[j++]=(G)((0x00000003&bai>>22)|(0x000000fc&bai>>24)); //2 bits from current 6 bits from next
 }
 R res;
 }
#define result(f,l,z) K res=f(rx);r0(rx);DO(res->n,kG(res)[i]=l);z;R res;
Z K reverse(K rbt,K x){
 TC(rbt,KG);TC(x,KG);
 P(rbt->n!=256,krr("length"));
 K rx=ktn(KG,xn);
 J i;
 for(i=0;i<xn;i++)kG(rx)[i]=kG(rbt)[kG(x)[i]];
 R rx;}
/* indexes the reverse bit map and alphabet casting bytes to long */
K b64encra(K rbt,K al,K x){
 TC(al,KC);
 K rx=reverse(rbt,x);P(!rx,rx);
 result(b64enc,kG(al)[kG(rbt)[kG(res)[i]]],res->t=KC);
 }
K b64decr(K rbt,K x){
 K rx=reverse(rbt,x);P(!rx,rx);
 result(b64dec,kG(rbt)[kG(res)[i]],);
 }
 
