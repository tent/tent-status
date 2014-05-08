/** @jsx React.DOM */

(function () {
"use strict";

Micro.Views.Login = React.createClass({
	displayName: "Micro.Views.Login",

	getInitialState: function () {
		return {
			alert: null
		};
	},

	componentWillMount: function () {
		this.__bindModel(this.props.model);
	},

	componentWillReceiveProps: function (props) {
		if (this.props.model !== props.model) {
			this.__unbindModel(this.props.model);
			this.__bindModel(props.model);
		}
	},

	componentWillUnmount: function () {
		this.__unbindModel(this.props.model);
	},

	__bindModel: function (model) {
		model.on("change", this.__handleModelChange, this);
		model.on("login:failure", this.__handleLoginFailure, this);
	},

	__unbindModel: function (model) {
		model.off("change", this.__handleModelChange, this);
		model.off("login:failure", this.__handleLoginFailure, this);
	},

	__handleModelChange: function () {
		if (this.isMounted()) {
			this.forceUpdate();
		}
	},

	__handleLoginFailure: function (msg) {
		if (this.isMounted()) {
			this.setState({
				alert: {
					type: "error",
					text: msg
				}
			});
		}
	},

	getValueLink: function (keypath) {
		var model = this.props.model;
		return {
			value: model.get(keypath),
			validation: model.getValidation(keypath),
			requestChange: function (newValue) {
				model.set(keypath, newValue);
			}
		};
	},

	handleSubmit: function (e) {
		e.preventDefault();
		this.refs.username.setChanging(false);
		this.refs.passphrase.setChanging(false);
		this.props.model.performLogin();
	},

	isSubmitDisabled: function () {
		return !this.props.model.isValid();
	},

	render: function () {
		var Input = Micro.Views.Input;
		return (
			<section>
				<header>
					<h2 className="page-header">Log in</h2>
				</header>

				<form className="signin-form" onSubmit={this.handleSubmit}>
					{this.state.alert ? (
						<div className={"alert alert-"+ this.state.alert.type}>{this.state.alert.text}</div>
					) : null}

					<div className="control-group">
						<Input ref="username" type="text" label="Username" valueLink={this.getValueLink("username")} />
					</div>

					<div className="control-group">
						<Input ref="passphrase" type="password" label="Passphrase" valueLink={this.getValueLink("passphrase")} />
					</div>

					<button className="btn btn-primary" type="submit" disabled={this.isSubmitDisabled()}>Log in</button>
				</form>
			</section>
		);
	}
});

})();
