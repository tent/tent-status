(function () {
"use strict";

var MainRouter = Marbles.Router.createClass({
	displayName: "MainRouter",

	routes: [
		{ path: ""       ,  handler: "timeline" },
		{ path: "login"  ,  handler: "login" },
		{ path: "logout" ,  handler: "logout" },
		{ path: "*"      ,  handler: "notFound" }
	],

	timeline: function () {
		Micro.setImmediate(function () {
			React.renderComponent(
				Micro.Views.MainTimeline({}),
				Micro.el
			);
		});

		Marbles.history.once("handler:before", function () {
			Micro.Dispatcher.handleRouterAction({
				name: "unloadMainTimeline"
			});
		});
	},

	login: function (params) {
		var performRedirect = function () {
			var redirectPath = decodeURIComponent(params[0].redirect || "");
			Marbles.history.navigate(redirectPath);
		};

		if (Micro.config.authenticated) {
			performRedirect();
			return;
		}

		Micro.Dispatcher.handleRouterAction({
			name: "LOGIN_REDIRECT_FN",
			performLoginRedirect: performRedirect
		});

		var loginModel = Micro.Models.Login.findOrNew();
		React.renderComponent(
			Micro.Views.Login({
				model: loginModel
			}),
			Micro.el
		);
	},

	logout: function () {
		if ( !Micro.config.authenticated ) {
			// already logged out
			Marbles.history.navigate("");
			return;
		}

		Micro.Dispatcher.handleRouterAction({
			name: "LOGOUT"
		});
	},

	notFound: function () {
		React.renderComponent(
			Micro.Views.NotFound({}),
			Micro.el
		);
	}
});

new MainRouter();

})();
