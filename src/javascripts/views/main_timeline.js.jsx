/** @jsx React.DOM */
//= require ./posts

(function () {
"use strict";

var TimelineStore = Micro.Stores.MainTimeline;
var Posts = Micro.Views.Posts;

function getTimelineState() {
	var page = TimelineStore.getFirstPage();
	return {
		posts: page.posts,
		profiles: page.profiles
	};
}

Micro.Views.MainTimeline = React.createClass({
	displayName: "Micro.Views.MainTimeline",

	getInitialState: function () {
		return getTimelineState();
	},

	componentDidMount: function () {
		TimelineStore.addChangeListener(this.__handleChange);
	},

	componentWillUnmount: function () {
		TimelineStore.removeChangeListener(this.__handleChange);
	},

	render: function () {
		return (
			<div>
				<Posts posts={this.state.posts} profiles={this.state.profiles} />
			</div>
		);
	},

	__handleChange: function () {
		this.setState(getTimelineState());
	}
});

})();
