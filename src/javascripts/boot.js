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

		if (authenticated) {
			TentContacts.workerURL = Micro.config.CONTACTS_WORKER_URL;
			TentContacts.daemonURL = Micro.config.CONTACTS_URL;
			TentContacts.entity = Micro.config.meta.content.entity;
			TentContacts.serverMetaPost = Micro.config.meta.toJSON();
			TentContacts.credentials = Micro.config.credentials;
			TentContacts.run();
		} else {
			TentContacts.stop(null);
		}
	});
})();
