(function () {
	"use strict";

	Micro.once("config:ready", Micro.run.bind(Micro));

	Micro.config.fetch();

	React.renderComponent(
		Micro.Views.AppNav({}),
		document.getElementById("main-nav")
	);
})();
