"""A matplotlib backend for publishing figures via display_data"""
# This file is a modified version of backend_inline.py from the IPython development team

# Copyright (c) IPython Development Team.
# Distributed under the terms of the Modified BSD License.

from __future__ import print_function

import matplotlib
from matplotlib.backends.backend_agg import new_figure_manager, FigureCanvasAgg # analysis: ignore
from matplotlib._pylab_helpers import Gcf

from ipykernel.pylab.config import InlineBackend
from IPython.core.formatters import DisplayFormatter 
from IPython.core.pylabtools import select_figure_formats
import IPython
import IPython.display
import IPython.core.display
df=DisplayFormatter()
# fake thing which select_figure_formats will work on
class qshell():
 def __init__(self,df=None):
  self.display_formatter=df
qpubcallback=None
qclearcallback=None
qipythoncallback=None
shell=qshell(df)
select_figure_formats(shell,{'png'}) #,'svg','jpeg','pdf','retina'}) /more means multiple output mime types?

def initialise(qpubfunc,qcommfunc,qclearfunc,qipythonfunc):
 """Initialise the backend, the function given will be 
 called with (imagedata;metadata) on show"""
 import traceback
 global qpubcallback
 global qclearcallback
 global qipythoncallback
 qpubcallback=qpubfunc
 qclearcallback=qclearfunc
 qipythoncallback=qipythonfunc
 try:
  import matplotlib.pyplot as plt
  plt.switch_backend('module://kxpy.kx_backend_inline')
  plt.ion()
  plt.uninstall_repl_displayhook()
 except:
  print("couldn't switch matplotlib backend to kx_backend_inline")
  traceback.print_exc()
 try:
  from matplotlib import rc
  rc('figure',facecolor=(1,1,1,0),edgecolor=(1,1,1,0),dpi=72)
  rc('figure.subplot',bottom=.125)
  rc('font',size=10)
 except:
  print("couldn't set matplotlib rcParams")
  traceback.print_exc()
 try:
  from kxpy.kx_comm import Comm as KxComm
  KxComm.qfunc=qcommfunc
  IPython.display.clear_output=clear_output
  IPython.core.display.clear_output=clear_output
  IPython.display.display=display
  IPython.core.display.display=display
  IPython.display.publish_display_data=qpub
  IPython.core.display.publish_display_data=qpub
  IPython.get_ipython=get_ipython
  from ipywidgets.widgets import widget
  from matplotlib.backends import backend_nbagg
  from ipykernel import comm
  #monkey patch the Comm class for ipywidget
  widget.Comm=KxComm 
  widget.clear_output=clear_output
  backend_nbagg.Comm=KxComm
  comm.Comm=KxComm 
 except:
  print("ipywidgets not imported, ipywidgets will not be functional")
  traceback.print_exc()
  
 
def show(close=None, block=None):
    """Show all figures as SVG/PNG payloads sent to the IPython clients.

    Parameters
    ----------
    close : bool, optional
      If true, a ``plt.close('all')`` call is automatically issued after
      sending all the figures. If this is set, the figures will entirely
      removed from the internal list of figures.
    block : Not used.
      The `block` parameter is a Matplotlib experimental parameter.
      We accept it in the function signature for compatibility with other
      backends.
    """
    if close is None:
        close = InlineBackend.instance().close_figures
    try:
        for figure_manager in Gcf.get_all_fig_managers():
            display(figure_manager.canvas.figure)
    finally:
        show._to_draw = []
        # only call close('all') if any to close
        # close triggers gc.collect, which can be slow
        if close and Gcf.get_all_fig_managers():
            matplotlib.pyplot.close('all')


# This flag will be reset by draw_if_interactive when called
show._draw_called = False
# list of figures to draw when flush_figures is called
show._to_draw = []


def draw_if_interactive():
    """
    Is called after every pylab drawing command
    """
    # signal that the current active figure should be sent at the end of
    # execution.  Also sets the _draw_called flag, signaling that there will be
    # something to send.  At the end of the code execution, a separate call to
    # flush_figures() will act upon these values
    manager = Gcf.get_active()
    if manager is None:
        return
    fig = manager.canvas.figure

    # Hack: matplotlib FigureManager objects in interacive backends (at least
    # in some of them) monkeypatch the figure object and add a .show() method
    # to it.  This applies the same monkeypatch in order to support user code
    # that might expect `.show()` to be part of the official API of figure
    # objects.
    # For further reference:
    # https://github.com/ipython/ipython/issues/1612
    # https://github.com/matplotlib/matplotlib/issues/835

    def display_interactive(*args):
        display(fig)
        #clear up figure so it isn't displayed at end of execution
        try:
            show._to_draw.remove(fig)
        except ValueError:
            pass
        show._draw_called=False
        matplotlib.pyplot.close(fig)
        return
    fig.show = display_interactive
    return
  #  fig.show = lambda *a: a #display(fig)

    # If matplotlib was manually set to non-interactive mode, this function
    # should be a no-op (otherwise we'll generate duplicate plots, since a user
    # who set ioff() manually expects to make separate draw/show calls).
    if not matplotlib.is_interactive():
        return

    # ensure current figure will be drawn, and each subsequent call
    # of draw_if_interactive() moves the active figure to ensure it is
    # drawn last
    try:
        show._to_draw.remove(fig)
    except ValueError:
        # ensure it only appears in the draw list once
        pass
    # Queue up the figure for drawing in next show() call
    show._to_draw.append(fig)
    show._draw_called = True

# is called by jupyterq at the end of execution of any cell
def flush_figures():
    """Send all figures that changed

    This is meant to be called automatically and will call show() if, during
    prior code execution, there had been any calls to draw_if_interactive.

    """
    if not show._draw_called:
        return

    if InlineBackend.instance().close_figures:
        # ignore the tracking, just draw and close all figures
        return show(True)      
    try:
        # exclude any figures that were closed:
        active = set([fm.canvas.figure for fm in Gcf.get_all_fig_managers()])
        for fig in [ fig for fig in show._to_draw if fig in active ]:
            display(fig)
    finally:
        # clear flags for next round
        show._to_draw = []
        show._draw_called = False



# Changes to matplotlib in version 1.2 requires a mpl backend to supply a default
# figurecanvas. This is set here to a Agg canvas
# See https://github.com/matplotlib/matplotlib/pull/1125
FigureCanvas = FigureCanvasAgg

def display(*objs, **kwargs):
    """Display a Python object in all frontends.

    By default all representations will be computed and sent to the frontends.
    Frontends can decide which representation is used and how.

    Parameters
    ----------
    objs : tuple of objects
        The Python objects to display.
    raw : bool, optional
        Are the objects to be displayed already mimetype-keyed dicts of raw display data,
        or Python objects that need to be formatted before display? [default: False]
    include : list or tuple, optional
        A list of format type strings (MIME types) to include in the
        format data dict. If this is set *only* the format types included
        in this list will be computed.
    exclude : list or tuple, optional
        A list of format type strings (MIME types) to exclude in the format
        data dict. If this is set all format types will be computed,
        except for those included in this argument.
    metadata : dict, optional
        A dictionary of metadata to associate with the output.
        mime-type keys in this dictionary will be associated with the individual
        representation formats, if they exist.
    """
    raw = kwargs.get('raw', False)
    include = kwargs.get('include')
    exclude = kwargs.get('exclude')
    metadata = kwargs.get('metadata')
    if not raw:
        format = shell.display_formatter.format 

    for obj in objs:
        if raw:
            qpub(data=obj, metadata=metadata)
        else:
            format_dict, md_dict = format(obj, include=include, exclude=exclude)
            if not format_dict:
                continue
            if metadata:
                # kwarg-specified metadata gets precedence
                _merge(md_dict, metadata)
            qpub(data=format_dict, metadata=md_dict)
def clear_output(wait=False):
    """Clear the output of the current cell receiving output.

    Parameters
    ----------
    wait : bool [default: false]
        Wait to clear the output until new output is available to replace it."""
    if qclearcallback:
        qclearcallback(wait)
    else:
        print("in clear_output,qclearcallback not defined")
from collections import namedtuple
def get_ipython():
    """Return a dictionary having attributes like IPython"""
    if qipythoncallback:
        return qipythoncallback(None) # q funcs need at least one arg
    else:
        print("in get_ipython, qipythoncallback not defined")
        return None

def qpub(data,metadata={},**kwargs):
 if not metadata:
  metadata={}
 if not data:
  data={}
 if qpubcallback:
  qpubcallback([data,metadata]) 
 else:
  print("in qpub, qpubcallback not defined")
 return
