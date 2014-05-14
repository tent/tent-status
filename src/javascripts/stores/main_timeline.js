(function () {
"use strict";

Micro.Stores.MainTimeline = {
	getFirstPage: function () {
		if (this.__cold) {
			this.__cold = false;
			this.__fetch();
		}

		return {
			posts: this.__state.posts,
			profiles: this.__state.profiles
		};
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

	__state: {
		posts: [],
		profiles: {}
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

	__fetch: function () {
		var config = Micro.config;
		Micro.client.getPostsFeed({
			params: [{
				types: [
					config.POST_TYPES.STATUS,
					config.POST_TYPES.STATUS_REPLY,
					config.POST_TYPES.STATUS_REPOST
				],
				limit: config.PER_PAGE,
				profiles: "entity"
			}],
			callback: {
				success: function (res) {
					var profiles = res.profiles || {};
					Object.keys(profiles).forEach(function (entity) {
						var profile = profiles[entity];
						profile.avatarDigest = profile.avatar_digest;
						delete profile.avatar_digest;
						profile.entity = entity;
					});

					this.__setState({
						posts: res.posts,
						profiles: profiles
					});
				}.bind(this),

				failure: function () {}
			}
		});
	}
};

})();
