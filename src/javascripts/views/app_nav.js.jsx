/** @jsx React.DOM */

(function () {
"use strict";

Micro.Views.AppNav = React.createClass({
	displayName: "Micro.Views.AppNav",

	getInitialState: function () {
		return {
			navLinks: []
		};
	},

	getDefaultProps: function () {
		return {
			authenticated: false,
			searchNav: false,
			siteFeedEnabled: false
		};
	},

	componentWillMount: function () {
		this.__initNavLinks(this.props);
	},

	componentWillReceiveProps: function (props) {
		this.__initNavLinks(props);
	},

	render: function () {
		var navLinks = this.state.navLinks;
		return (
			<ul>
				{navLinks.map(function (link, i) {
					return (
						<li key={i} className={link.name === "Timeline" ? "active" : ""}>
							<NavLink link={link} />
						</li>
					);
				}.bind(this))}
			</ul>
		);
	},

	__initNavLinks: function (props) {
		var navLinks;
		if (props.searchNav) {
			navLinks = [{
				href: "/",
				name: "Global",
				iconName: "fa-globe"
			}];
		} else {
			navLinks = [{
				href: "/",
				name: "Timeline",
				iconName: "fa-list"
			},{
				href: "/",
				name: "Mentions",
				iconName: "fa-thumb-tack"
			},{
				href: "/",
				name: "Reposts",
				iconName: "fa-retweet"
			},{
				href: "/",
				name: "Profile",
				iconName: "fa-user"
			}];

			if (props.siteFeedEnabled) {
				navLinks.push({
					href: "/",
					name: "Site Feed",
					iconName: "fa-globe"
				});
			}
		}

		this.setState({
			navLinks: navLinks
		});
	}
});

var NavLink = React.createClass({
	displayName: "Micro.Views.AppNav NavLink",

	render: function () {
		var link = this.props.link;
		return (
			<a href={link.href}>
				<i className={"fa " + link.iconName} />
				{link.name}
			</a>
		);
	}
});

})();
