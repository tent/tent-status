(function () {
	"use strict";

	var __events = {};
	var __eventIDCounter = 1;

	var origin = window.location.protocol +"//"+ window.location.host;

	window.addEventListener("message", function (e) {
		if (e.origin.substr(0, origin.length) !== origin) {
			return;
		}
		if (e.data && e.data.name === "setImmediate") {
			var id = e.data.id;
			var callback = __events[id];
			delete __events[id];
			callback();
		}
	}, false);

	Micro.setImmediate = function (callback) {
		var id = __eventIDCounter++;
		var promise = new Promise(function (resolve) {
			__events[id] = resolve;
		}).then(callback, callback);
		window.postMessage({
			name: "setImmediate",
			id: id
		}, origin);
		return promise;
	};

})();
