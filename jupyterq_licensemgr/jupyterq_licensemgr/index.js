define(['jquery', 'base/js/namespace', 'base/js/dialog'], function($, J, D){

// [name] is the name of the event "click", "mouseover", ..
// same as you'd pass it to bind()
// [fn] is the handler function
$.fn.bindFirst = function(name, fn) {
    // bind as you normally would
    // don't want to miss out on any jQuery magic
    this.on(name, fn);

    // Thanks to a comment by @Martin, adding support for
    // namespaced events too.
    this.each(function() {
        var handlers = $._data(this, 'events')[name.split('.')[0]];
        // take out the handler we just inserted from the end
        var handler = handlers.pop();
        // move it at the beginning
        handlers.splice(0, 0, handler);
    });
};

	var IFRAME = null
	var DIALOG = null;
	var NEEDLICENSE = false;

	var BASE = location.protocol + "//" + location.host;
	function close() {
		if(DIALOG != null) DIALOG.remove();
		$('.modal-backdrop').remove()
		DIALOG = IFRAME = null;
	}
window.J=J;

	var actions = {
		"license": function(text) {
			if(IFRAME != null) return;
			NEEDLICENSE=true;

			close();

			IFRAME = $('<iframe style="margin:0;padding:0;width:100%;height:70vh;">').attr("src", "https://ondemand.kx.com/licensemgr/");
			DIALOG = D.kernel_modal({ title: text, body: IFRAME, notebook: J.notebook });
		},
		"dialog": function(text, extra) {
			if(DIALOG != null)return;
			DIALOG = D.kernel_modal({
				title: text,
				body: extra.description,
				buttons: { "Continue": close } });
		},

		"ready": function() {
			if(NEEDLICENSE) {
				J.notebook.session.restart()
				NEEDLICENSE = false;
				close();
			}
		}
	}

	function check_kdb() {
		if(J.notebook.kernel_selector.current_selection != 'qpk') return;

		var xh = new XMLHttpRequest();
		xh.onreadystatechange = function() {
			if(xh.readyState != 4)  return;

			var result = JSON.parse(xh.responseText);
			actions[ result.action ](result.info, result);
		};
		xh.open("GET", BASE + "/kx/license_check.json?_=" + Date.now(), true);
		xh.send(null);
	}

	function then_check_kdb() {
		setTimeout(check_kdb, 0);
	}

	function suppress(evt,info) {
		if(J.notebook.kernel_selector.current_selection == 'qpk') {
			info.attempt=69;

			then_check_kdb();
			evt.stopImmediatePropagation();
			evt.preventDefault();
		}

		return true;
	}

	window.addEventListener("message", function(x) {
		if(IFRAME != null){
			console.log(x.source);
			console.log(IFRAME.get(0).contentWindow);
		}

		if(IFRAME != null && x.source == IFRAME.get(0).contentWindow) {
			if(typeof x.data == 'string') x= JSON.parse(x.data); else x=x.data;
			var h = new Image();
			h.onload = function() { check_kdb() };
			h.src = BASE + "/kx/license_submit.py?d=" + x.klic;
		}
	});

	function bind() {
		if(J.notebook.kernel == null) return setTimeout(bind,0);
		J.notebook.kernel.events.bindFirst("kernel_dead.Kernel",           suppress);
		J.notebook.kernel.events.bindFirst("kernel_autorestarting.Kernel", suppress);
		J.notebook.kernel.events.bindFirst("notebook_loaded.Notebook",     then_check_kdb);
		J.notebook.kernel.events.bindFirst("kernel_starting.Kernel",       then_check_kdb);
		J.notebook.kernel.events.bindFirst("kernel_created.Session",       then_check_kdb);
	}

	return {
		load_ipython_extension: function() {
			console.log("jupyerq_licensemgr loaded");

			then_check_kdb();
			bind();
		}
	};
});
