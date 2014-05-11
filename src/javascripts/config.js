(function () {
"use strict";

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
				Micro.trigger("config:ready");
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

			Micro.trigger("config:ready");
		}
	});
};

})();
