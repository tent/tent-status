//= require es6promise
//= require_self
//= require ./set_immediate
//= require ./static_config
//= require_tree ./routers
//= require ./dispatcher
//= require ./auth
//= require_tree ./stores
//= require ./view_helpers
//= require_tree ./views
//= require_tree ./models
//= require ./config
//= require ./boot

(function () {
"use strict";

var Micro = {};
window.Micro = Micro;

Marbles.Utils.extend(Micro, {
	Views: {},
	Actions: {},
	Models: {}, // TODO: replace these with Stores
	Stores: {},
	run: function () {
		if ( !Marbles.history || Marbles.history.started ) {
			return;
		}

		this.__handleChangeAuthenticated();
		this.config.on("change:authenticated", this.__handleChangeAuthenticated, this);

		this.el = document.getElementById("main");

		Marbles.history.on("handler:before", function (handler, path, params, abortFn) {
			if ( !this.config.authenticated && !this.isLoginPath(path) ) {
				abortFn();
				this.redirectToLogin();
				return;
			}
			React.unmountComponentAtNode(this.el);
		}.bind(this));

		Marbles.history.start({
			root: (this.config.PATH_PREFIX || '') + '/'
		});
	},

	isLoginPath: function (path) {
		if ( path === "" ) {
			return false;
		}
		return path.substr(0, 5) === "login";
	},

	isLogoutPath: function (path) {
		if (path === "") {
			return false;
		}
		return path.substr(0, 6) === "logout";
	},

	redirectToLogin: function () {
		var path = Marbles.history.path;
		var redirectParam = "";
		if (path && !this.isLogoutPath(path)) {
			redirectParam = Marbles.history.path ? "?redirect="+ encodeURIComponent(Marbles.history.path) : "";
		}
		Marbles.history.navigate("login"+ redirectParam);
	},

	__handleChangeAuthenticated: function () {
		if (this.config.authenticated) {
			this.client = new TentClient(this.config.meta.get("content.entity"), {
				credentials: this.config.credentials,
				serverMetaPost: this.config.meta
			});
		} else {
			this.client = null;
			var path = Marbles.history.path;
			if (path && !this.isLoginPath(path)) {
				this.redirectToLogin();
			}
		}
	}
}, Marbles.Events);

})();
