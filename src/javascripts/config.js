//= require ./dispatcher

(function () {
"use strict";

var AppDispatcher = Micro.Dispatcher;

Micro.config.fetch = function () {
	Marbles.HTTP({
		method: "GET",
		url: Micro.config.JSON_CONFIG_URL,
		middleware: [
			Marbles.HTTP.Middleware.WithCredentials,
			Marbles.HTTP.Middleware.SerializeJSON
		],
		headers: {
			"Content-Type": "application/json"
		},
		callback: function (res, xhr) {
			if (xhr.status !== 200) {
				Micro.config.set("authenticated", false);
				AppDispatcher.handleServerAction({
					name: "CONFIG_READY",
					authenticated: false
				});
				return;
			}

			Marbles.Transaction.transaction.call(Micro.config, function () {
				this.set("authenticated", true);

				for (var k in res) {
					if (res.hasOwnProperty(k)) {
						switch (k) {
							case "meta":
								this.set(k, Micro.Models.Meta.findOrNew(res[k]));
								break;

							default:
								this.set(k, res[k]);
						}
					}
				}
			});

			AppDispatcher.handleServerAction({
				name: "CONFIG_READY",
				authenticated: true
			});
		}
	});
};

})();
