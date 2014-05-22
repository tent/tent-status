(function () {
"use strict";

Micro.Dispatcher = Marbles.Utils.extend({
	handleViewAction: function (action) {
		this.dispatch(Marbles.Utils.extend({
			source: "VIEW_ACTION"
		}, action));
	}
}, Marbles.Dispatcher);

})();
