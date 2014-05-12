(function () {
"use strict";

var MainRouter = Marbles.Router.createClass({
	displayName: "MainRouter",

	routes: [
		{ path: "", handler: "timeline" },
		{ path: "login", handler: "login" }
	],

	timeline: function () {
		React.renderComponent(
			Micro.Views.MainTimeline({}),
			Micro.el
		);
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
	}
});

new MainRouter();

})();
