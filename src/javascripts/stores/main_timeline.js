(function () {
"use strict";

Micro.Stores.MainTimeline = {
	getPage: function () {
		if (this.__cold) {
			this.__cold = false;
			this.__state = this.__getInitialState();
			this.__fetch();
		}

		var posts = [];
		this.__state.pages.forEach(function (page) {
			posts = posts.concat(page.posts);
		});

		return {
			posts: posts,
			profiles: this.__state.profiles,
			pageIds: this.__state.pageIds
		};
	},

	fetchNextPage: function (opts) {
		var params = Marbles.QueryParams.deserializeParams(this.__pageQueries.next || "");
		this.__fetch(params, opts);
	},

	setCold: function () {
		this.__cold = true;
		this.__state = this.__getInitialState();
	},

	addChangeListener: function (handler) {
		this.__changeListeners.push(handler);
	},

	removeChangeListener: function (handler) {
		this.__changeListeners = this.__changeListeners.filter(function (fn) {
			return fn !== handler;
		});
	},

	__changeListeners: [],

	__cold: true,

	__pageQueries: {},

	__pageIdAppendCounter: 0,
	__pageIdPrependCounter: 0,

	__state: {},

	__getInitialState: function () {
		return {
			profiles: {},
			pages: [],
			pageIds: []
		};
	},

	__setState: function (state) {
		var __state = this.__state;
		var __hasOwnProp = Object.hasOwnProperty;
		for (var k in state) {
			if (__hasOwnProp.call(state, k)) {
				__state[k] = state[k];
			}
		}
		this.__state = __state;
		this.__handleChange();
	},

	__handleChange: function () {
		this.__changeListeners.forEach(function (handler) {
			handler();
		});
	},

	__fetch: function (params, opts) {
		var config = Micro.config;
		params = params || [{}];
		opts = opts || {};
		params = Marbles.QueryParams.replaceParams.apply(null, [[{
			types: [
				config.POST_TYPES.STATUS,
				config.POST_TYPES.STATUS_REPLY,
				config.POST_TYPES.STATUS_REPOST
			],
			limit: Micro.config.PER_PAGE,
			profiles: "entity"
		}]].concat(params));
		Micro.client.getPostsFeed({
			params: params,
			callback: {
				success: function (res) {
					var profiles = res.profiles || {};
					Object.keys(profiles).forEach(function (entity) {
						var profile = profiles[entity];
						profile.avatarDigest = profile.avatar_digest;
						delete profile.avatar_digest;
						profile.entity = entity;
					});

					this.__pageQueries = res.pages;

					var pageIds = this.__state.pageIds;
					var pages = this.__state.pages;

					var unloadPageId = opts.unloadPageId;
					if (unloadPageId) {
						// TODO: check the other end of the pageIds array if it's a prepend operation
						if (pageIds[0] === unloadPageId) {
							pageIds.shift();
							pages.shift();
						} else {
							throw new Error("MainTimeline: Invalid unload request for page id: "+ JSON.stringify(unloadPageId) +". Only "+ JSON.stringify(pageIds[0]) +" may be removed.");
						}
					}

					var pageId = String(++this.__pageIdAppendCounter);
					pageIds.push(pageId);
					pages.push({
						id: pageId,
						posts: res.posts
					});

					this.__setState({
						profiles: profiles,
						pages: pages,
						pageIds: pageIds
					});
				}.bind(this),

				failure: function () {}
			}
		});
	}
};

})();
