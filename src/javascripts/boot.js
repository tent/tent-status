//= require ./auth

(function () {
	"use strict";

	var Auth = Micro.Auth;

	var handleAuthChange = function () {
		var authState = Auth.state;
		if (authState.status === "AUTHENTICATED" || authState.status === "UNAUTHENTICATED") {
			Auth.removeChangeListener(handleAuthChange);
			handleConfigReady();
		}
	};

	var appNav = React.renderComponent(
		Micro.Views.AppNav({}),
		document.getElementById("app-nav")
	);

	var handleConfigReady = function () {
		Micro.run();

		appNav.setProps({
			currentPath: Marbles.history.path
		});
		Marbles.history.on("route", function () {
			appNav.setProps({
				currentPath: Marbles.history.path
			});
		});
	};

	Auth.addChangeListener(handleAuthChange);

	Micro.config.fetch();

	Micro.config.on("change:authenticated", function (authenticated) {
		appNav.setProps({
			authenticated: authenticated
		});

		if (authenticated) {
			TentContacts.daemonURL = Micro.config.CONTACTS_URL;
			TentContacts.entity = Micro.config.meta.content.entity;
			TentContacts.serverMetaPost = Micro.config.meta.toJSON();
			TentContacts.credentials = Micro.config.credentials;
			TentContacts.run();
		} else {
			TentContacts.stop(function(){});
		}
	});
})();
