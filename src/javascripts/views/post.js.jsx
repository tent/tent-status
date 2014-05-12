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

	render: function () {
		var post = this.props.post;
		return (
			<section className="post">
				<Avatar entity={post.entity} />
				<header>
					<h2>
						<Name entity={post.entity} />
					</h2>
				</header>

				<p dangerouslySetInnerHTML={{ __html: markdownToHTML(String(post.content.text), post.mentions || []) }} />
			</section>
		);
	}
});

})();
