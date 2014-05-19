/** @jsx React.DOM */

(function () {
"use strict";

Micro.Views.ScrollPagination = React.createClass({
	displayName: "Micro.Views.ScrollPagination",

	getDefaultProps: function () {
		return {
			pageIds: [],
			loadPrevPage: function () {},
			loadNextPage: function () {}
		};
	},

	componentWillMount: function () {
		this.__marginBottom = 0;
		this.__paddingTop = 0;
		this.__prevPageThreshold = 0;
		this.__nextPageThreshold = 0;

		var pageIds = this.props.pageIds;
		this.__renderedPageIds = [];
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

	componentWillUpdate: function (props) {
		this.__loadingPrevPage = false;
		this.__loadingNextPage = false;

		var pageIds = props.pageIds;
		var renderedPageIds = this.__renderedPageIds;

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
		} else if (pageIds.length > renderedPageIds.length) {
			throw new Error("ScrollPagination: New pages must be inserted at beginning or end!\nold("+ renderedPageIds.join(", ") +")\nnew("+ pageIds.join(", ") +")");
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

		if (unloadedPageId) {
			if (unloadedPagePosition === "top") {
				var paddingTop = this.__paddingTop;
				paddingTop += this.__pageDimentions[unloadedPageId].height;
				this.__paddingTop = paddingTop;
				renderedPageIds.shift();
			} else {
				renderedPageIds.pop();
			}
			delete this.__pageDimentions[unloadedPageId];
		}

		if (newPageId) {
			if (newPagePosition === "bottom") {
				renderedPageIds.push(newPageId);
			} else { // top
				renderedPageIds.unshift(newPageId);
			}
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

		if (newPagePosition === "top") {
			var newPageDimentions = this.__pageDimentions[newPageId];
			this.__paddingTop = Math.max(this.__paddingTop - newPageDimentions.height, 0);
			this.refs.wrapper.getDOMNode().style.paddingTop = this.__paddingTop +"px";
		}

		this.__updateRemainingScrollHeight({ init: true });
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
		if (this.__marginBottom) {
			style.marginBottom = this.__marginBottom + "px";
		}
		return (
			<div ref="wrapper" style={style}>
				{this.props.children}
			</div>
		);
	},

	__loadPrevPage: function (opts) {
		if (this.__loadingPrevPage) {
			return;
		}
		this.__loadingPrevPage = true;
		this.props.loadPrevPage(opts);
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

		var prevPageThreshold;
		var nextPageThreshold;
		var newPageId = opts.newPageId;
		var newPagePosition = opts.newPagePosition;
		if (opts.newPageId) {
			var renderedPageIds = this.__renderedPageIds;
			var pageDimentions = this.__pageDimentions;
			var paddingTop = this.__paddingTop;
			var pagesHeightAbove = paddingTop;
			var pagesHeightBelow = 0;

			var newPageIndex = renderedPageIds.indexOf(newPageId);
			renderedPageIds.slice(0, newPageIndex).forEach(function (pageId) {
				var dimentions = pageDimentions[pageId];
				pagesHeightAbove += dimentions.height;
			});
			renderedPageIds.slice(newPageIndex + 1, renderedPageIds.length).forEach(function (pageId) {
				var dimentions = pageDimentions[pageId];
				pagesHeightBelow += dimentions.height;
			});

			var newPageDimentions = {
				offsetTop: pagesHeightAbove + offsetTop,
				height: offsetHeight - pagesHeightAbove - pagesHeightBelow
			};
			pageDimentions[newPageId] = newPageDimentions;

			var offsetTopDelta = newPageDimentions.height;
			if (newPagePosition === "top") {
				offsetTopDelta = offsetTopDelta * -1;
			}
			renderedPageIds.slice(newPageIndex + 1, renderedPageIds.length).forEach(function (pageId) {
				var pageOffsetTop = pageDimentions[pageId].offsetTop;
				pageDimentions[pageId].offsetTop = Math.max(pageOffsetTop + offsetTopDelta, 0);
			});

			if (newPagePosition === "top") {
				prevPageThreshold = Math.round(newPageDimentions.height / 2);
			} else if (newPagePosition === "bottom") {
				nextPageThreshold = Math.round(newPageDimentions.height / 2);
			}
		}

		this.__viewportHeight = viewportHeight;
		this.__offsetTop = offsetTop;
		this.__offsetHeight = offsetHeight;
		this.__offsetBottom = offsetBottom;
		this.__prevPageThreshold = prevPageThreshold || this.__prevPageThreshold;
		this.__nextPageThreshold = nextPageThreshold || this.__nextPageThreshold;
	},

	__updateRemainingScrollHeight: function (opts, e) {
		opts = opts || {};
		if (this.__offsetHeight === 0) {
			return;
		}
		if (this.__loadingNextPage || this.__loadingPrevPage) {
			if (e) {
				e.preventDefault();
			}
			return;
		}

		var scrollY = window.scrollY;
		var viewportHeight = this.__viewportHeight;
		var remainingScrollBottom = this.__offsetHeight + this.__offsetBottom - scrollY - viewportHeight;

		var pageDimentions = this.__pageDimentions;
		var pageIds = this.props.pageIds;
		var pageOpts = {};

		if (remainingScrollBottom <= this.__nextPageThreshold) {
			var firstPageDimentions = pageDimentions[pageIds[0]];
			if (firstPageDimentions && scrollY > (firstPageDimentions.height + this.__paddingTop)) {
				pageOpts.unloadPageId = pageIds[0];
			}
			this.__loadNextPage(pageOpts);
		} else if (opts.init !== true) {
			var remainingScrollTop = scrollY - this.__offsetTop - this.__paddingTop;
			var lastPageDimentions = pageDimentions[pageIds[pageIds.length-1]];
			if (lastPageDimentions && remainingScrollTop <= this.__prevPageThreshold) {
				if ((scrollY + viewportHeight) < lastPageDimentions.offsetTop) {
					pageOpts.unloadPageId = pageIds[pageIds.length-1];
				}
				this.__loadPrevPage(pageOpts);
			}
		}
	},

	__handleScroll: function (e) {
		this.__updateRemainingScrollHeight({}, e);
	},

	__handleResize: function () {
		this.__updateDimensions();
		this.__updateRemainingScrollHeight();
	}
});

})();
