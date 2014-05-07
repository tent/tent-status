(function () {
"use strict";

var MainRouter = Marbles.Router.createClass({
	displayName: "MainRouter",

	routes: [
		{ path: "", handler: "root" }
	],

	root: function () {
		console.log("TODO: Do something");
	}
});

new MainRouter();

})();
