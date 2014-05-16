/** @jsx React.DOM */

(function () {
"use strict";

Micro.Views.ScrollPagination = React.createClass({
	displayName: "Micro.Views.ScrollPagination",

	getDefaultProps: function () {
		return {
			threshold: 60,
			pageIds: [],
			loadPrevPage: function () {},
			loadNextPage: function () {}
		};
	},

	componentWillMount: function () {
		this.__marginBottom = 0;
		this.__paddingTop = 0;

		var pageIds = this.props.pageIds;
		this.__pageDimentions = {};
		this.__unloadedPageDimentions = {};
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

	componentWillUpdate: function (props) {
		this.__loadingPrevPage = false;
		this.__loadingNextPage = false;

		// TODO: when fetching prev page, send page id to be unloaded
		// TODO: when pageIds excludes a known page, fill the gap with it's height (must always be either top or bottom (start or end of array))

		var pageIds = props.pageIds;
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
		}

		if (unloadedPageId) {
			if (unloadedPagePosition === "top") {
				var paddingTop = this.__paddingTop || 0;
				paddingTop += this.__pageDimentions[unloadedPageId].offsetHeight;
				this.__paddingTop = paddingTop;
			} else {
				var paddingBottom = this.__paddingBottom || 0;
				paddingBottom += this.__pageDimentions[unloadedPageId].offsetHeight;
				this.__paddingBottom = paddingBottom;
			}

			this.__unloadedPageDimentions[unloadedPageId] = this.__pageDimentions[unloadedPageId];
			delete this.__pageDimentions[unloadedPageId];
		}

		this.__newPageId = newPageId;
		this.__newPagePosition = newPagePosition;
	},

	componentDidUpdate: function () {
		var newPageId = this.__newPageId;
		var newPagePosition = this.__newPagePosition;
		delete this.__newPageId;
		delete this.__newPagePosition;

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
		var style = {};
		if (this.__paddingTop) {
			style.paddingTop = this.__paddingTop + "px";
		}
		if (this.__paddingBottom) {
			style.paddingBottom = this.__paddingBottom + "px";
		}
		if (this.__marginBottom) {
			style.marginBottom = this.__marginBottom + "px";
		}
		return (
			<div ref="wrapper" style={style}>
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
		opts = opts || {};
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
			var unloadedPageDimentions = this.__unloadedPageDimentions;
			Object.keys(pageDimentions).forEach(function (k) {
				var dimentions = pageDimentions[k];
				pagesOffsetHeight += dimentions.offsetHeight;
			});
			Object.keys(unloadedPageDimentions).forEach(function (k) {
				var dimentions = unloadedPageDimentions[k];
				pagesOffsetHeight += dimentions.offsetHeight;
			});
			pageDimentions[opts.newPageId] = {
				offsetHeight: offsetHeight - pagesOffsetHeight + offsetTop
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
		if (this.__loadingNextPage) {
			return;
		}
		var scrollY = window.scrollY;
		var remainingScrollBottom = this.__offsetHeight + this.__offsetBottom - scrollY - this.__viewportHeight;
		var pageDimentions = this.__pageDimentions;
		var pageIds = this.props.pageIds;
		var opts = {};
		if (remainingScrollBottom <= this.props.threshold) {
			if (scrollY > (pageDimentions[pageIds[0]].offsetHeight + this.__paddingTop)) {
				opts.unloadPageId = pageIds[0];
			}
			this.__loadNextPage(opts);
		} else {
			// TODO: determine prev page load point
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
