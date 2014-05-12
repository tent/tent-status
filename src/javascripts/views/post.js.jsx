/** @jsx React.DOM */

(function () {
"use strict";

Micro.Views.Post = React.createClass({
	displayName: "Micro.Views.Post",

	render: function () {
		var post = this.props.post;
		return (
			<section className="post">
				<pre>{JSON.stringify(post, undefined, 2)}</pre>
			</section>
		);
	}
});

})();
