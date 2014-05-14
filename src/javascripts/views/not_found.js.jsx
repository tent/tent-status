/** @jsx React.DOM */

(function () {
"use strict";

Micro.Views.NotFound = React.createClass({
	displayName: "Micro.Views.NotFound",

	render: function () {
		return (
			<section className="not-found">
				<header>
					<h1>
						<small>404</small> Not Found
					</h1>
				</header>

				<p>{"The page you are looking for doesn't exist."}</p>
			</section>
		);
	}
});

})();
