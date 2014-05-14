/** @jsx React.DOM */
//= require ./avatar
//= require ./name

(function () {
"use strict";

var Avatar = Micro.Views.Avatar;
var Name = Micro.Views.Name;
var markdownToHTML = Micro.ViewHelpers.markdownToHTML;

Micro.Views.Post = React.createClass({
	displayName: "Micro.Views.Post",

	getDefaultProps: function () {
		return {
			profiles: {}
		};
	},

	render: function () {
		var post = this.props.post;
		var profiles = this.props.profiles;
		return (
			<section className="post">
				<Avatar entity={post.entity} profiles={profiles} />
				<header>
					<h2>
						<Name entity={post.entity} profiles={profiles} />
					</h2>
				</header>

				<div className="content">
					<p dangerouslySetInnerHTML={{ __html: markdownToHTML(String(post.content.text), post.mentions || []) }} />
				</div>
			</section>
		);
	}
});

})();
