(function () {
"use strict";

var USERNAME_REGEX = /^[a-z0-9]{2,30}$/;
var PASSPHRASE_REGEX = /^.{6,}$/;

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
		Micro.on("login:success", this.__handleLoginSuccess, this);
		Micro.on("login:failure", this.__handleLoginFailure, this);
	},

	willDetach: function () {
		Micro.off("login:success", this.__handleLoginSuccess, this);
		Micro.off("login:failure", this.__handleLoginFailure, this);
	},

	performLogin: function () {
		Micro.performLogin(this.username, this.passphrase);
	},

	__handleLoginSuccess: function () {
		this.detach();
		this.remove("passphrase");
	},

	__handleLoginFailure: function (res, xhr) {
		if (res.field) {
			this.transaction(function () {
				this.set("validation."+ res.field +".valid", false);
				this.set("validation."+ res.field +".msg", res.message || res.error);
			});
		} else if (xhr.status === 401) {
			this.transaction(function () {
				this.set("validation.username.valid", null);
				this.set("validation.username.msg", null);
				this.set("validation.passphrase.valid", null);
				this.set("validation.passphrase.msg", null);
			});
		}
		this.trigger("login:failure", res.message || res.error || "Something went wrong");
	}
});

})();
