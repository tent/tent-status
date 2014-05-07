//= require_self
//= require ./static_config
//= require_tree ./routers
//= require_tree ./views
//= require ./config
//= require ./boot

(function () {
"use strict";

var Micro = {};
window.Micro = Micro;

Marbles.Utils.extend(Micro, {
	Views: {},
	run: function () {
		if ( !Marbles.history || Marbles.history.started ) {
			return;
		}

		this.el = document.getElementById("main");

		Marbles.history.on('handler:before', function () {
			React.unmountComponentAtNode(this.el);
		}.bind(this));

		Marbles.history.start({
			root: (this.config.PATH_PREFIX || '') + '/'
		});
	}
}, Marbles.Events);

})();
