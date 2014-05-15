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
			Micro.Stores.MainTimeline.setCold();
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

		var loginModel = Micro.Models.Login.findOrNew();
		React.renderComponent(
			Micro.Views.Login({
				model: loginModel
			}),
			Micro.el
		);

		Micro.on("login:success", performRedirect);
		Marbles.history.once("handler:before", function () {
			Micro.off("login:success", performRedirect);
		});
	},

	logout: function () {
		if ( !Micro.config.authenticated ) {
			// already logged out
			Marbles.history.navigate("");
			return;
		}

		Micro.performLogout();
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
