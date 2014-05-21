/** @jsx React.DOM */

(function () {
"use strict";

Micro.Views.Avatar = React.createClass({
	displayName: "Micro.Views.Avatar",

	getInitialState: function () {
		return {
			avatarURL: null,
			name: null
		};
	},

	getDefaultProps: function () {
		return {
			profiles: {}
		};
	},

	componentWillMount: function () {
		var profile = this.props.profiles[this.props.entity];
		if (profile) {
			this.__handleChange(profile);
		} else {
			TentContacts.find(this.props.entity, this.__handleChange);
		}
		TentContacts.onChange(this.props.entity, this.__handleChange);
	},

	componentWillUnmount: function () {
		TentContacts.offChange(this.props.entity, this.__handleChange);
	},

	render: function () {
		return (
			<img className="avatar" src={this.state.avatarURL} title={this.state.name} />
		);
	},

	__handleChange: function (profile) {
		var avatarDigest = profile.avatarDigest;
		this.setState({
			avatarURL: avatarDigest ? Micro.client.getSignedURL("attachment", [{ entity: profile.entity, digest: avatarDigest }]) : null,
			name: profile.name
		});
	}
});

})();
