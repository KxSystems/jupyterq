import setuptools

with open("README.md", "r") as fh:
	long_description = fh.read()

setuptools.setup(
	name="jupyterq_licensemgr",
	version="0.0.2",
	author="Geo Carncross",
	author_email="gcarncross@kx.com",
	description="Jupyterq licensing server extensions",
	long_description=long_description,
	long_description_content_type="text/markdown",
	url="https://github.com/KxSystems/jupyterq",
	packages=setuptools.find_packages(),
	include_package_data=True,
	data_files=[
		# like `jupyter nbextension install --sys-prefix`
		("share/jupyter/nbextensions/jupyterq_licensemgr", [ "jupyterq_licensemgr/index.js" ]),

		# like `jupyter nbextension enable --sys-prefix`
		("etc/jupyter/nbconfig/notebook.d", [ "jupyterq_licensemgr/jupyterq_licensemgr.json" ]),

		# like `jupyter serverextension enable --sys-prefix`
		("etc/jupyter/jupyter_notebook_config.d", [ "jupyterq_licensemgr/jupyterq_licensemgr_config.json" ])
	],
	zip_safe=False,
	classifiers=[
		"Programming Language :: Python :: 3",
		"License :: OSI Approved :: Apache License",
		"Operating System :: OS Independent",
	],
)
