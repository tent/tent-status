/** @jsx React.DOM */
//= require ./posts

(function () {
"use strict";

var TimelineStore = Micro.Stores.MainTimeline;
var Posts = Micro.Views.Posts;

function getTimelineState() {
	return {
		posts: TimelineStore.getFirstPage()
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
				<Posts posts={this.state.posts} />
			</div>
		);
	},

	__handleChange: function () {
		this.setState(getTimelineState());
	}
});

})();
