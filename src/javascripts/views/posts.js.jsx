/** @jsx React.DOM */
//= require ./post

(function () {
"use strict";

var Post = Micro.Views.Post;

Micro.Views.Posts = React.createClass({
	displayName: "Micro.Views.Posts",

	getDefaultProps: function () {
		return {
			posts: []
		};
	},

	render: function () {
		return (
			<section className="posts">
				<ul>
					{this.props.posts.map(function (post) {
						return (
							<li key={post.id}>
								<Post post={post} />
							</li>
						);
					}.bind(this))}
				</ul>
			</section>
		);
	}
});

})();
