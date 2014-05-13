(function () {
"use strict";

function entityProfileUrl(entity) {
	return "#TODO:profile:" + encodeURIComponent(entity);
}

function isExternalURL(url) {
	// TODO: improve check
	return !/^\//.test(url);
}

function markdownToHTML(text, mentions) {
	var inlineMentionURLs = mentions.map(function (m) {
		return entityProfileUrl(m.entity);
	});

	var preprocessors = [];

	var parsePara = function (para, callback) {
		var newPara = para.map(function (item) {
			if (Array.isArray(item) && ["para", "strong", "em", "del"].indexOf(item[0]) !== -1) {
				parsePara(item, callback);
			} else if (typeof item === "string") {
				callback(item);
			} else {
				return item;
			}
		}.bind(this));
		return newPara;
	};

	var externalLinkPreprocessor = function (jsonml) {
		if (jsonml[0] !== "link") {
			return jsonml;
		}
		if ( !jsonml[1] || !isExternalURL(jsonml[1].href) ) {
			return jsonml;
		}

		// TODO: ensure href has scheme

		// TODO: Convert into React component
		// target="_blank" is depricated
		jsonml[1].target = "_blank";

		return jsonml;
	};
	preprocessors.push(externalLinkPreprocessor);

	// Disable hastag autolinking when search isn't enabled
	if ( !Micro.config.SEARCH_ENABLED ) {
		preprocessors.push(function (jsonml) {
			if (jsonml[0] !== "link") {
				return jsonml;
			}
			if ( !jsonml[1] || jsonml[1].rel !== "hashtag") {
				return jsonml;
			}

			return ["span", jsonml[2]];
		});
	}

	// TODO: Get jsonml instead and convert into React components
	return markdown.toHTML(text, "Tent", {
		footnotes: inlineMentionURLs,
		hashtagURITemplate: "#TODO:search:?q=%23{hashtag}",
		preprocessors: preprocessors
	});
}

Micro.ViewHelpers = {
	markdownToHTML: markdownToHTML
};

})();
