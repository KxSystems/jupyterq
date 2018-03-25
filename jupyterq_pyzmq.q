/ pyzmq instead of qzmq for zero mq messaging
pypop:.p.eval["list.pop"][;0]
pylen:.p.eval["len"][<]

ctx:(pyzmq:.p.import`zmq)[`:Context;`:instance][]                                               / initialise pyzmq
pyzframe:pyzmq[`:Frame;>]                                                                       / create a zmq.Frame to be added to a message
NOBLOCK:pyzmq[`:NOBLOCK]`.                                                                      / socket options from pyzmq
ROUTER:pyzmq[`:ROUTER]`.
PUB:pyzmq[`:PUB]`.
pyzmqmap:`new_router`new_pub!ROUTER,PUB
zsock.new:{ctx[`:socket]pyzmqmap x}                                                             / create new zmq socket
zsock.new_router:{(s:zsock.new`new_router)[`:bind]x;addzsock s}
zsock.new_pub:{(s:zsock.new`new_pub)[`:bind]x;addzsock s}
zsocks:(0#0)!()                                                                                 / id->socket
addzsock:{zsocks[k:1+max -1,key zsocks]:x;k}                                                    / keep track of zmq sockets
zsock.destroy:{zsocks[x][`:close][]}                                                            / close a socket
zsock.fd:$[17<="I"${(x?".")#x}pyzmq[`:pyzmq_version][]`;                                        / file descriptor for zeromq socke, need v>=17 for fileno
 {"i"$zsocks[x][`:fileno][]`};
 {"i"$zsocks[x][`:FD]`}]
zmsgs:(0#0)!()                                                                                  / pending messages sent or received
zmsg.new:{zmsgs[k:1+max -1,key zmsgs]:();k}                                                     / create a new message to be sent
zmsg.size:{$[1=count m:zmsgs x;$[.p.i.isw m;pylen m;1];count m]}                                / size of multipart message
zmsg.destroy:{zmsgs::enlist[x]_zmsgs}                                                           / drop a message, done with it
zmsg.addC:{zmsgs[x],:enlist pyzframe"x"$y}                                                      / add string to message, convert to bytes in case contains control characters
zmsg.popC:{"c"$pypop[zmsgs x]`}                                                                 / read and pop string from multipart message
zmsg.send:{zsocks[y][`:send_multipart][zmsgs x;`flags pykw NOBLOCK]}                            / send a multipart message

/trap EAGAIN error on non-blocking read in python so no error message is displayed
p)import zmq
p)def* zmqcall(func,*args,**kwargs):
 try:
  return func(*args,**kwargs)
 except zmq.error.Again as e:
  return 0
zmsg.recvnowait:{                                                                               / non blocking read from zmq socket, returns identity if nothing available
 msg:zmqcall[zsocks[x][`:recv_multipart];`flags pykw NOBLOCK];if[0~msg`;:(::)];
 zmsgs[m:zmsg.new[]]:msg;m}

