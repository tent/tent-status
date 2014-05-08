/** @jsx React.DOM */

(function () {

"use strict";

Micro.Views.Input = React.createClass({
	displayName: "Micro.Views.Input",

	getInitialState: function () {
		return {
			changing: false
		};
	},

	handleInputChange: function () {
		this.setState({
			changing: true
		});
		this.props.valueLink.requestChange(this.refs.input.getDOMNode().value);
	},

	handleInputBlur: function () {
		this.setState({
			changing: false
		});
	},

	// called from the outside world
	setChanging: function (changing) {
		this.setState({
			changing: changing
		});
	},

	// called from the outside world
	focus: function () {
		this.refs.input.getDOMNode().focus();
	},

	render: function () {
		var valid = this.props.valueLink.validation.valid;
		var msg = this.props.valueLink.validation.msg;

		if (this.state.changing && valid === false) {
			valid = null;
			msg = null;
		}

		if (valid === false && this.props.required !== true && !this.props.valueLink.value) {
			valid = null;
			msg = null;
		}

		return (
			<label>
				{this.props.label ? (
					<span className="text">
						{this.props.label}
					</span>
				) : null}
				<div className={"input-append"+ (valid === true ? " has-success" : (valid === false ? " has-error" : ""))}>
					<input
						ref="input"
						type={this.props.type}
						value={this.props.valueLink.value}
						size={this.props.size}
						disabled={this.props.disabled}
						onChange={this.handleInputChange}
						onBlur={this.handleInputBlur} />
					<span className="add-on" title={msg}><i /></span>
					{this.props.children}
				</div>
				{msg ? (
					<div className="info">{msg}</div>
				) : null}
			</label>
		);
	}
});

})();
