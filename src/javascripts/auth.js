//= require ./dispatcher

(function () {
"use strict";

Micro.Auth = {};

Marbles.Utils.extend(Micro.Auth, Marbles.State, {
	dispatcherIndex: Micro.Dispatcher.register(function (event) {
		switch (event.name) {
			case "LOGIN":
				this.performLogin(event.username, event.passphrase);
			break;

			case "LOGOUT":
				this.performLogout();
			break;

			case "LOGIN_REDIRECT_FN":
				this.__performLoginRedirect = event.performLoginRedirect;
			break;

			case "CONFIG_READY":
				if (event.authenticated) {
					this.replaceState({
						status: "AUTHENTICATED"
					});
					if (this.__performLoginRedirect) {
						this.__performLoginRedirect();
						delete this.__performLoginRedirect;
					}
				} else {
					this.replaceState({
						status: "UNAUTHENTICATED"
					});
				}
			break;
		}
	}.bind(Micro.Auth)),

	getInitialState: function () {
		return {
			status: "AUTHENTICATION_PENDING"
		};
	},

	performLogin: function (username, passphrase) {
		Marbles.HTTP({
			method: "POST",
			url: Micro.config.LOGIN_URL,
			body: {
				username: username,
				passphrase: passphrase
			},
			middleware: [
				Marbles.HTTP.Middleware.WithCredentials,
				Marbles.HTTP.Middleware.FormEncoded,
				Marbles.HTTP.Middleware.SerializeJSON
			],
			headers: {
				"Content-Type": "application/x-www-form-urlencoded"
			},
			callback: function (res, xhr) {
				if (xhr.status === 200) {
					Micro.config.fetch();
				} else {
					this.replaceState({
						status: "AUTHENTICATION_FAILURE",
						xhrStatus: xhr.status,
						field: res.field || null,
						message: res.message || res.error
					});
				}
			}.bind(this)
		});
	},

	performLogout: function () {
		Marbles.HTTP({
			method: "POST",
			url: Micro.config.LOGOUT_URL,
			middleware: [
				Marbles.HTTP.Middleware.WithCredentials
			],
			callback: function (res, xhr) {
				if (xhr.status === 200) {
					this.replaceState({
						status: "AUTHENTICATION_PENDING"
					});
					if (Micro.config.LOGOUT_REDIRECT_URL) {
						window.location.href = Micro.config.LOGOUT_REDIRECT_URL;
						return;
					}
				}
				Micro.config.fetch();
			}.bind(this)
		});
	},

	__changeListeners: []

});

Micro.Auth.state = Micro.Auth.getInitialState();

})();
