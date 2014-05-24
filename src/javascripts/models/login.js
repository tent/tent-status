//= require ../auth
//= require ../dispatcher

(function () {
"use strict";

var USERNAME_REGEX = /^[a-z0-9]{2,30}$/;
var PASSPHRASE_REGEX = /^.{6,}$/;

var Auth = Micro.Auth;
var AppDispatcher = Micro.Dispatcher;

Micro.Models.Login = Marbles.Model.createClass({
	displayName: "Micro.Models.Login",

	mixins: [{
		ctor: {
			modelName: "login",
			cidMappingScope: ["__id"],

			findOrNew: function () {
				return this.__super__.constructor.findOrNew.call(this, { __id: "login" });
			},

			validationRequiredKeypaths: ["username", "passphrase"],

			validation: {
				"username": function (value, callback) {
					if (USERNAME_REGEX.test(value)) {
						callback(true, null);
					} else {
						callback(false, "Sorry, usernames must be alphanumeric with a length between 2 and 30.");
					}
				},

				"passphrase": function (value, callback) {
					if (PASSPHRASE_REGEX.test(value)) {
						callback(true, null);
					} else {
						callback(false, "Your passphrase must be at least 6 characters in length.");
					}
				}
			}
		}
	}, Marbles.Validation],

	didInitialize: function () {
		this.__handleAuthChange = this.__handleAuthChange.bind(this);
		Auth.addChangeListener(this.__handleAuthChange);
	},

	willDetach: function () {
		Auth.removeChangeListener(this.__handleAuthChange);
	},

	performLogin: function () {
		AppDispatcher.handleModelAction({
			name: "LOGIN",
			username: this.username,
			passphrase: this.passphrase
		});
	},

	__handleAuthChange: function () {
		var authState = Auth.state;
		switch (authState.status) {
			case "AUTHENTICATION_PENDING":
				this.__clearValidation();
			break;

			case "AUTHENTICATED":
				this.detach();
				this.remove("passphrase");
			break;

			case "AUTHENTICATION_FAILURE":
				if (authState.field) {
					this.transaction(function () {
						this.set("validation."+ authState.field +".valid", false);
						this.set("validation."+ authState.field +".msg", authState.message);
					});
				} else if (authState.xhrStatus === 401) {
					this.__clearValidation();
				}
				this.trigger("login:failure", authState.message || "Something went wrong");
			break;

			case "UNAUTHENTICATED":
				this.__clearValidation();
			break;
		}
	},

	__clearValidation: function () {
		this.transaction(function () {
			this.set("validation.username.valid", null);
			this.set("validation.username.msg", null);
			this.set("validation.passphrase.valid", null);
			this.set("validation.passphrase.msg", null);
		});
	}
});

})();
