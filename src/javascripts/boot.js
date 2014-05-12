(function () {
	"use strict";

	Micro.once("config:ready", Micro.run.bind(Micro));

	Micro.config.fetch();

	var appNav = React.renderComponent(
		Micro.Views.AppNav({}),
		document.getElementById("app-nav")
	);

	Micro.config.on("change:authenticated", function (authenticated) {
		appNav.setProps({
			authenticated: authenticated
		});
	});
})();
