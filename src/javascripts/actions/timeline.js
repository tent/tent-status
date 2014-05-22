//= require ../dispatcher

(function () {
"use strict";

var AppDispatcher = Micro.Dispatcher;

Micro.Actions.Timeline = {
	unloadPage: function (pageId) {
		AppDispatcher.handleViewAction({
			name: "unloadPage",
			pageId: pageId
		});
	},

	loadPrevPage: function () {
		AppDispatcher.handleViewAction({
			name: "loadPrevPage"
		});
	},

	loadNextPage: function () {
		AppDispatcher.handleViewAction({
			name: "loadNextPage"
		});
	}
};

})();
