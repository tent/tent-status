(function () {
"use strict";

Micro.Models.Meta = Marbles.Model.createClass({
	displayName: "Micro.Models.Meta",

	mixins: [{
		ctor: {
			modelName: "meta",
			cidMappingScope: ["id", "entity"]
		}
	}],

	toJSON: function () {
		return {
			id: this.id,
			version: this.version,
			type: this.type,
			published_at: this.published_at,
			received_at: this.received_at,
			app: this.app,
			attachments: this.attachments,
			content: this.content,
			entity: this.entity
		};
	}
});

})();
