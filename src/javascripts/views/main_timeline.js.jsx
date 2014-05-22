/** @jsx React.DOM */
//= require ./scroll_pagination
//= require ./posts
//= require ../actions/timeline

(function () {
"use strict";

var TimelineStore = Micro.Stores.MainTimeline;
var ScrollPagination = Micro.Views.ScrollPagination;
var Posts = Micro.Views.Posts;
var TimelineActions = Micro.Actions.Timeline;

function getTimelineState() {
	var res = TimelineStore.getPage();
	return {
		posts: res.posts,
		profiles: res.profiles,
		pageIds: res.pageIds
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
			<ScrollPagination
				pageIds={this.state.pageIds}
				unloadPage={TimelineActions.unloadPage}
				loadPrevPage={TimelineActions.loadPrevPage}
				loadNextPage={TimelineActions.loadNextPage}>

				<Posts posts={this.state.posts} profiles={this.state.profiles} />
			</ScrollPagination>
		);
	},

	__handleChange: function () {
		this.setState(getTimelineState());
	}
});

})();
