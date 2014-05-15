/** @jsx React.DOM */

(function () {
"use strict";

Micro.Views.ScrollPagination = React.createClass({
	displayName: "Micro.Views.ScrollPagination",

	getDefaultProps: function () {
		return {
			threshold: 0, // percent
			loadPrevPage: function () {},
			loadNextPage: function () {}
		};
	},

	componentDidMount: function () {
		this.__updateDimensions();
		this.__updateRemainingScrollHeight();
		window.addEventListener("scroll", this.__handleScroll, false);
		window.addEventListener("resize", this.__handleResize, false);
	},

	componentWillUpdate: function () {
		this.__loadingPrevPage = false;
		this.__loadingNextPage = false;
	},

	componentDidUpdate: function () {
		this.refs.wrapper.getDOMNode().style.setProperty("padding-top", this.__offset +"px");
		this.__updateDimensions();
		this.__updateRemainingScrollHeight();
	},

	componentWillUnmount: function () {
		window.removeEventListener("scroll", this.__handleScroll, false);
		window.removeEventListener("resize", this.__handleResize, false);
	},

	render: function () {
		return (
			<div ref="wrapper">
				{this.props.children}
			</div>
		);
	},

	__loadPrevPage: function () {
		if (this.__loadingPrevPage) {
			return;
		}
		this.__loadingPrevPage = true;
		this.props.loadPrevPage();
	},

	__loadNextPage: function () {
		if (this.__loadingNextPage) {
			return;
		}
		this.__loadingNextPage = true;
		this.__offset = this.__offsetHeight;
		this.props.loadNextPage();
	},

	__updateDimensions: function () {
		var el = this.refs.wrapper.getDOMNode();
		var offsetTop = 0;
		var ref = el;
		while (ref) {
			offsetTop += ref.offsetTop || 0;
			ref = ref.offsetParent;
		}
		var offsetHeight = el.offsetHeight;

		var documentHeight = document.body.offsetHeight;
		var viewportHeight = window.innerHeight;
		var maxHeight = Math.max(documentHeight, viewportHeight);
		var offsetBottom = maxHeight - offsetHeight - offsetTop;

		this.__maxHeight = maxHeight;
		this.__offsetHeight = offsetHeight;
		this.__offsetTop = offsetTop;
		this.__offsetBottom = offsetBottom;
		this.__viewportHeight = viewportHeight;
	},

	__updateRemainingScrollHeight: function () {
		if (this.__offsetHeight === 0) {
			return;
		}
		var scrollY = window.scrollY;
		var scrollHeight = this.__offsetTop + this.__offsetHeight + this.__offsetBottom;
		var remainingScrollBottom = this.__offsetHeight + this.__offsetBottom - scrollY - this.__viewportHeight;
		var remainingScrollPercentBottom = 100 - Math.round(((scrollY + this.__viewportHeight) / scrollHeight) * 100);
		if (remainingScrollBottom < -400) {
			return;
		}
		if (remainingScrollPercentBottom <= this.props.threshold) {
			this.__loadNextPage();
		} else {
			var remainingScrollPercentTop = Math.round((scrollY / scrollHeight) * 100);
			if (remainingScrollPercentTop <= this.props.threshold) {
				this.__loadPrevPage();
			}
		}
	},

	__handleScroll: function () {
		this.__updateRemainingScrollHeight();
	},

	__handleResize: function () {
		this.__updateDimensions();
		this.__updateRemainingScrollHeight();
	}
});

})();
