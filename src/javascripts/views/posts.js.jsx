/** @jsx React.DOM */
//= require ./post
//= require ./repost

(function () {
"use strict";

var STATUS_REPOST = Micro.config.POST_TYPES.STATUS_REPOST;
var Post = Micro.Views.Post;
var Repost = Micro.Views.Repost;

Micro.Views.Posts = React.createClass({
	displayName: "Micro.Views.Posts",

	getDefaultProps: function () {
		return {
			posts: [],
			profiles: {}
		};
	},

	render: function () {
		var profiles = this.props.profiles;
		return (
			<section className="posts">
				<ul>
					{this.props.posts.map(function (post) {
						var postView;
						switch (post.type) {
							case STATUS_REPOST:
								postView = <Repost post={post} />;
								break;
							default:
								postView = <Post post={post} profiles={profiles} />;
						}
						return (
							<li key={post.id}>
								{postView}
							</li>
						);
					}.bind(this))}
				</ul>
			</section>
		);
	}
});

})();
