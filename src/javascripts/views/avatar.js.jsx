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

	componentWillMount: function () {
		TentContacts.find(this.props.entity, this.__handleChange);
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
		this.setState({
			avatarURL: profile.avatarDigest ? Micro.client.getNamedURL("attachment", [{ entity: profile.entity, digest: profile.avatarDigest }]) : null,
			name: profile.name
		});
	}
});

})();
