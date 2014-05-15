/** @jsx React.DOM */

(function () {
"use strict";

Micro.Views.ScrollPagination = React.createClass({
	displayName: "Micro.Views.ScrollPagination",

	getDefaultProps: function () {
		return {
			threshold: 0, // percent
			pageIds: [],
			loadPrevPage: function () {},
			loadNextPage: function () {}
		};
	},

	componentWillMount: function () {
		this.__marginBottom = 0;

		var pageIds = this.props.pageIds;
		this.__pageDimentions = {};
		if (pageIds.length > 1) {
			throw new Error("ScrollPagination: Must mount with a single page, an attempt was made to mount with "+ pageIds.length +"!");
		}
	},

	componentDidMount: function () {
		this.__updateDimensions({
			newPageId: this.props.pageIds[0],
			newPagePosition: "bottom"
		});
		this.__updateRemainingScrollHeight();
		window.addEventListener("scroll", this.__handleScroll, false);
		window.addEventListener("resize", this.__handleResize, false);
	},

	componentWillUpdate: function () {
		this.__loadingPrevPage = false;
		this.__loadingNextPage = false;
	},

	componentDidUpdate: function () {
		// TODO: when fetching prev page, send page id to be unloaded
		// TODO: when pageIds excludes a known page, fill the gap with it's height (must always be either top or bottom (start or end of array))

		var pageIds = this.props.pageIds;
		var renderedPageIds = Object.keys(this.__pageDimentions);

		// find new page id (if any)
		// must be either at beginning or end of list
		var newPageId = null;
		var newPagePosition = null;
		if (renderedPageIds.indexOf(pageIds[pageIds.length-1]) === -1) {
			newPageId = pageIds[pageIds.length-1];
			newPagePosition = "bottom";
		} else if (renderedPageIds.indexOf(pageIds[0]) === -1) {
			newPageId = pageIds[0];
			newPagePosition = "top";
		} else if (renderedPageIds.length !== pageIds.length) {
			throw new Error("ScrollPagination: New pages must be inserted at beginning or end! old("+ renderedPageIds.join(", ") +") new("+ pageIds.join(", ") +")");
		}

		// find removed page id
		// must be either at beginning or end of list
		var unloadedPageId = null;
		var unloadedPagePosition = null;
		if (newPagePosition === "bottom") {
			if (renderedPageIds[0] !== pageIds[0]) {
				unloadedPageId = renderedPageIds[0];
				unloadedPagePosition = "top";
			}
		} else if (newPagePosition === "top") {
			if (renderedPageIds[renderedPageIds.length-1] !== pageIds[pageIds.length-1]) {
				unloadedPageId = renderedPageIds[renderedPageIds.length-1];
				unloadedPagePosition = "bottom";
			}
		}

		// supply extra whitespace to prevent scroll jumping
		// while loading new page
		if (newPagePosition === "bottom") {
			var marginBottom;
			if (renderedPageIds.length > 0) {
				marginBottom = this.__pageDimentions[renderedPageIds[renderedPageIds.length-1]].offsetHeight;
			} else {
				marginBottom = 500;
			}
			this.__marginBottom = marginBottom;
			this.refs.wrapper.getDOMNode().style.setProperty("margin-bottom", marginBottom +"px");
		}

		if (unloadedPageId) {
			if (unloadedPagePosition === "top") {
				var paddingTop = this.__paddingTop || 0;
				paddingTop += this.__pageDimentions[unloadedPageId].offsetHeight;
				this.__paddingTop = paddingTop;
				this.refs.wrapper.getDOMNode().style.setProperty("padding-top", paddingTop +"px");
			} else {
				var paddingBottom = this.__paddingBottom || 0;
				paddingBottom += this.__pageDimentions[unloadedPageId].offsetHeight;
				this.__paddingBottom = paddingBottom;
				this.refs.wrapper.getDOMNode().style.setProperty("padding-bottom", paddingBottom +"px");
			}
		}

		this.__updateDimensions({
			newPageId: newPageId,
			newPagePosition: newPagePosition
		});
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

	__loadNextPage: function (opts) {
		if (this.__loadingNextPage) {
			return;
		}
		this.__loadingNextPage = true;
		this.props.loadNextPage(opts);
	},

	__updateDimensions: function (opts) {
		var documentHeight = document.body.offsetHeight;
		var viewportHeight = window.innerHeight;
		var maxHeight = Math.max(documentHeight, viewportHeight);

		var el = this.refs.wrapper.getDOMNode();
		var offsetHeight = el.offsetHeight;
		var offsetTop = 0;
		var ref = el;
		while (ref) {
			offsetTop += ref.offsetTop || 0;
			ref = ref.offsetParent;
		}
		var offsetBottom = maxHeight - offsetHeight - offsetTop - this.__marginBottom;

		if (opts.newPageId) {
			var pagesOffsetHeight = 0;
			var pageDimentions = this.__pageDimentions;
			Object.keys(pageDimentions).forEach(function (k) {
				var dimentions = pageDimentions[k];
				pagesOffsetHeight += dimentions.offsetHeight;
			});
			pageDimentions[opts.newPageId] = {
				offsetHeight: offsetHeight - pagesOffsetHeight
			};
		}

		this.__maxHeight = maxHeight;
		this.__viewportHeight = viewportHeight;
		this.__offsetTop = offsetTop;
		this.__offsetHeight = offsetHeight;
		this.__offsetBottom = offsetBottom;
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
		var pageDimentions = this.__pageDimentions;
		var pageIds = this.props.pageIds;
		var opts = {};
		if (remainingScrollPercentBottom <= this.props.threshold) {
			if (scrollY > pageDimentions[pageIds[0]].offsetHeight) {
				opts.unloadPageId = pageIds[0];
			}
			this.__loadNextPage(opts);
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
