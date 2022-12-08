from notebook.base.handlers import IPythonHandler
from os import path, getenv, popen
from urllib.parse import parse_qs, urlparse
from socket import gethostname
from base64 import b64decode
from json import dumps
from getpass import getuser
from sys import stderr, exit

QHOME = getenv('QHOME', path.join(path.expanduser("~"),"q"))
if not QHOME or not path.isdir(QHOME):
  print('QHOME env is not set to a directory', file=stderr)
  exit(2)

QLIC = getenv('QLIC', QHOME)
if not path.isdir(QLIC):
  print('QLIC env is not set to a directory for storing the license', file=stderr)
  exit(2)

QLIC_KC = path.join(QLIC, 'kc.lic')
QLIC_K4 = path.join(QLIC, 'k4.lic')

# kc.lic.py compatibility
for el, ln in [('QLIC_K4', 'k4.lic'), ('QLIC_KC', 'kc.lic')]:
	lic = getenv(el)
	if lic:
		with open(path.join(QLIC, ln), 'wb') as file:
			file.write(b64decode(lic))

def _jupyter_server_extension_paths():
	return [{
		"module": "jupyterq_licensemgr"
	}]

def _jupyter_nbextension_paths():
	return [dict(
		section="notebook",
		src=".",
		dest="jupyterq_licensemgr",
		require="jupyterq_licensemgr/index")]

def load_jupyter_server_extension(nb):
	class LicenseCheckHandler(IPythonHandler):
		def get(self):
			result = {"action": None, "info": None, "ok": False, "hostname": gethostname(), "user": getuser() }
			status = ' '.join(popen('q "' + path.join(path.dirname(path.realpath(__file__)), 'check_q.q') + '" -q 2>&1').read().replace("\t",' ').splitlines()[0].split(" ")[1:])
			if status == "license daemon returned: 'blocked -- please confirm your email":
				result['action'] = "dialog"
				result['info'] = "Email address unconfirmed"
				result['description'] = "Check your email for a request from Kx to verify your license."
			elif status == "license daemon returned: 'blocked -- please contact ondemand@kx.com":
				result['action'] = "dialog"
				result['info'] = "Revoked license"
				result['description'] = "This license has been revoked. If you did not do this, please contact ondemand@kx.com"
			elif status == "host":
				result['action'] = "license"
				result['info'] = "Wrong hostname on license"
			elif status == "kc.lic" or status == "k4.lic" or status == 'detected and no license found.' or status == 'licence error: kc.lic' or status == 'licence error: k4.lic': # no license, or corrupt license
				result['action'] = "license"
				result['info'] = "Unlicensed workstation"
			elif status == "ok":
				result['action'] = "ready"
				result['ok'] = True
			else:
				# possible: new q error message?, someone messed with q binary?
				nb.log.error("jupyterq_licensemgr issue: " + status)
				result['action'] = "dialog"
				result['info'] = "License check failed"
				result['description'] = "There's an issue with the license manager. Check your installation carefully and/or reinstall your application"
			self.add_header("Content-Type", "application/json")
			nb.log.info("jupyterq_licensemgr check request")
			self.finish(dumps(result).encode())

	class LicenseSubmitHandler(IPythonHandler):
		def get(self):
			d = self.get_arguments("d")
			if d != []:
				with open(QLIC_KC, "wb") as file:
					file.write(b64decode(d[0].replace(' ','+')))
			self.add_header("Content-Type", "image/gif")
			nb.log.info("jupyterq_licensemgr submitted from client")
			for x in nb.kernel_manager.list_kernels():
				nb.log.info("jupyterq_licensemgr restarting " + x['id'])
				nb.kernel_manager.restart_kernel(x['id'])
			self.finish(b64decode("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"))

	wa = nb.web_app
	wa.add_handlers('.*$', [
		('/kx/license_check.json', LicenseCheckHandler),
		('/kx/license_submit.py',  LicenseSubmitHandler)
	])
	nb.log.info("jupyterq_licensemgr module enabled")
