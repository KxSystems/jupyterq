#include "k.h"
/* for fifo out/err redirect */
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

#define TC(x,T) P(x->t!=T,krr("type")) // return on unexpected type
// assumes bytes in q are stored little endian
#define EB(x) ((G)((0x0000003f&x)<<2))
/* callback function and methods to add and remove from q for zeromq */
K cb(I fd){r0(k(0,".qpk.cb",ki(fd),(K)0));R (K)0;}
K1(acb){TC(x,-KI);sd1(xi,cb);R (K)0;}
K1(rcb){TC(x,-KI);sd0(xi);R (K)0;}
K2(rcb0x){TC(x,-KI);TC(y,-KB);sd0x(xi,y->g);R (K)0;}

/* for stdout/err redirection */
Z K fifobuf; //=ktn(KG,0x00010000);
Z int fifoinit=0;
K fifocb(I x){
 int n,no;
 K fd=ki(x);
 no=fifobuf->n;
 while((n=read(x,kG(fifobuf),fifobuf->n))){
  P((-1==n)&&((errno==EAGAIN)||(errno==EWOULDBLOCK)),(K)0);  /* done, x is non-blocking */
  P(-1==n,krr(strerror(errno)));                             /* something unexpected */
  fifobuf->n=n;
  r0(k(0,".qpk.fifocb",r1(fd),r1(fifobuf),(K)0));
  fifobuf->n=no;
 }
 R (K)0;
 }
Z void ififo(){if(!fifoinit)fifobuf=ktn(KG,0x00010000);}
/* open and put callback on q select loop */
K1(ofifo){
 TC(x,-KS);
 ififo();
 int fd=open(xs, O_RDWR|O_NONBLOCK);
 P(-1==fd,krr(strerror(errno)));
 sd1(fd,fifocb);
 R ki(fd);
 }
// debug
//void printbits(unsigned int v){int i;for(i = 31; i >= 0; i--) putchar('0' + ((v >> i) & 1));}
/* base 64 enc/dec, bytes only
 * assumes bytes have been bit reversed s.t. most significant of prev is just prior to least of next 
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
//0b sv'8 cut raze 2_'x
// have 4 bytes, don't care about first 2 bits of each (they're zero)
// so get 3 bytes from this
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
/* indexes the reverse bit map and alphabet with bytes not cast to long */
K b64encra(K rbt,K al,K x){
 TC(rbt,KG);TC(al,KC);TC(x,KG);
 P(rbt->n!=256,krr("length")); // reverse bit map should have entry for every possible byte
 K rx=ktn(KG,xn);
 J i;
 for(i=0;i<xn;i++)kG(rx)[i]=kG(rbt)[kG(x)[i]];
 K res=b64enc(rx);
 r0(rx);
 for(i=0;i<res->n;i++)kG(res)[i]=kG(al)[kG(rbt)[kG(res)[i]]];
 res->t=KC;
 R res; 
 }
/* indexes the reverse bit map with bytes not cast to long */
K b64decr(K rbt,K x){
 TC(rbt,KG);TC(x,KG);
 P(rbt->n!=256,krr("length")); // reverse bit map should have entry for every possible byte
 K rx=ktn(KG,xn);
 J i;
 for(i=0;i<xn;i++)kG(rx)[i]=kG(rbt)[kG(x)[i]];
 K res=b64dec(rx);
 r0(rx);
 for(i=0;i<res->n;i++)kG(res)[i]=kG(rbt)[kG(res)[i]];
 R res; 
 }
 
