(function () {
"use strict";

Micro.Collections.Posts = Marbles.Collection.createClass({
	displayName: "Micro.Collections.Posts",

	mixins: [{
		ctor: {
			cidMappingScope: ["name"]
		}
	}],

	willInitialize: function (options) {
		options.unique = true;
	},

	didInitialize: function (options) {
		this.set("name", options.name);
		this.options.params = options.params || [{}];
		this.options.client = options.client || Micro.client;
		this.options.defaultParams = options.defaultParams || [{
			limit: Micro.config.PER_PAGE
		}];
	},

	fetch: function (params) {
		params = Marbles.QueryParams.replaceParams.apply(this,
			[this.options.defaultParams].concat(this.options.params).concat(params || [{}])
		);

		this.options.client.getPostsFeed({
			params: params
		});
	}
});

})();
