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
			} else {
				Micro.config.set("authenticated", true);
			}
			Micro.trigger("config:ready");
		}
	});
};

})();
