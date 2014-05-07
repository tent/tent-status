(function () {
"use strict";

Micro.config.fetch = function () {
	Micro.trigger("config:ready");
};

})();
