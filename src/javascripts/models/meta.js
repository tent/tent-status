(function () {
"use strict";

Micro.Models.Meta = Marbles.Model.createClass({
	displayName: "Micro.Models.Meta",

	mixins: [{
		ctor: {
			modelName: "meta",
			cidMappingScope: ["id", "entity"]
		}
	}]
});

})();
