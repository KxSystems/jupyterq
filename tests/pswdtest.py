import os
import platform

plsys = platform.system()
nerr = 0
def geterr(f,e,l):
    global nerr
    if plsys == 'Windows':
        arg = "tests\kernelspec"+f+" > NUL 2>&1"
        os.system("cp tests\kernelspec"+f+"\winkernel.json tests\kernelspec"+f+"\kernel.json")
    else:
        arg = "tests/kernelspec"+f+" > /dev/null 2>&1"
    os.system("jupyter kernelspec install --user --name=qpk " + arg)
    if l != "":
        os.environ['JUPYTERQ_LOGIN'] = l
    err = os.popen("jupyter-run --kernel=qpk --RunApp.kernel_timeout=3 2>&1").read()
    if err.find(e)==-1:
        print("ERROR: "+e)
        nerr += 1
	
folders = ("/ku","/su","/nku","/nsu","","","")
errors = ("-u not supported, only -U",
	  "-u not supported, only -U",
	  "kernel must use -U if server does",
	  "server must use -U if kernel does",
	  "Missing JUPYTERQ_LOGIN",
	  "JUPYTERQ_LOGIN should be user:pass",
          "Wrong user:password in JUPYTERQ_LOGIN")
logins = ("","","","","","user-password","user2:password")

for f,e,l in zip(folders,errors,logins):
    geterr(f,e,l)

print("The number of errors is: {}".format(nerr))
