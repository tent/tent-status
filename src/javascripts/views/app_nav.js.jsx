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
			currentPath: null,
			authenticated: false,
			searchNav: false,
			siteFeedEnabled: false,
			showAuth: true
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
		var authenticated = this.props.authenticated;
		var currentPath = this.props.currentPath;
		var isPathActive = this.__isPathActive;
		return (
			<ul className={authenticated ? null : "disabled"}>
				{navLinks.map(function (link, i) {
					return (
						<li key={i} className={isPathActive(link.path) ? "active" : null}>
							<NavLink disabled={ !authenticated } currentPath={currentPath} link={link} />
						</li>
					);
				}.bind(this))}
			</ul>
		);
	},

	__initNavLinks: function (props) {
		var navLinks;
		var authenticated = props.authenticated;

		if (props.searchNav) {
			navLinks = [{
				path: "search",
				name: "Global",
				iconName: "fa-globe"
			}];
		} else {
			navLinks = [{
				path: "",
				name: "Timeline",
				iconName: "fa-list"
			},{
				path: "mentions",
				name: "Mentions",
				iconName: "fa-thumb-tack"
			},{
				path: "reposts",
				name: "Reposts",
				iconName: "fa-retweet"
			},{
				path: "profile",
				name: "Profile",
				iconName: "fa-user"
			}];

			if (props.siteFeedEnabled) {
				navLinks.push({
					path: "site-feed",
					name: "Site Feed",
					iconName: "fa-globe"
				});
			}
		}

		if (props.showAuth) {
			if (authenticated) {
				navLinks.push({
					path: "logout",
					name: "Log out",
					iconName: "fa-power-off"
				});
			} else {
				navLinks.push({
					path: "login",
					name: "Log in",
					iconName: "fa-power-off"
				});
			}
		}

		this.setState({
			navLinks: navLinks
		});
	},

	__isPathActive: function (path) {
		var currentPath = this.props.currentPath;
		if ( typeof currentPath !== "string" ) {
			return false;
		}
		if (currentPath.substr(0, path.length) !== path) {
			return false;
		}
		var after = currentPath.substr(path.length, 1);
		if (after && !(after === "?" || after === "/")) {
			return false;
		}
		return true;
	}
});

var NavLink = React.createClass({
	displayName: "Micro.Views.AppNav NavLink",

	render: function () {
		var link = this.props.link;
		var fullPath = Marbles.history.pathWithRoot.bind(Marbles.history);
		var currentPath = this.props.currentPath;
		return (
			<a href={typeof currentPath === "string" ? fullPath(link.path) : null} onClick={this.__handleClick}>
				<i className={"fa " + link.iconName} />
				{link.name}
			</a>
		);
	},

	__handleClick: function (e) {
		e.preventDefault();
		if (this.props.disabled) {
			return;
		}
		var link = this.props.link;
		Marbles.history.navigate(link.path);
	}
});

})();
