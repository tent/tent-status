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
		this.__paddingBottom = 0;
		this.__prevPageThreshold = 0;
		this.__nextPageThreshold = 0;

		var pageIds = this.props.pageIds;
		this.__renderedPageIds = [];
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

		if (newPagePosition === "bottom") {
			// supply extra whitespace to prevent scroll jumping
			// while loading new page
			var marginBottom;
			if (renderedPageIds.length > 0) {
				marginBottom = this.__pageDimentions[renderedPageIds[renderedPageIds.length-1]].offsetHeight;
			} else {
				marginBottom = 500;
			}
			this.__marginBottom = marginBottom;
		} else if (newPagePosition === "top") {
				var newPageHeight = this.__unloadedPageDimentions[newPageId];
				if (newPageHeight) {
					delete this.__unloadedPageDimentions[newPageId];
					this.__paddingTop = this.__paddingTop - newPageHeight.offsetHeight;
				} else {
					// TODO: cause page not to jump while inserting new page
				}
		}

		if (unloadedPageId) {
			if (unloadedPagePosition === "top") {
				var paddingTop = this.__paddingTop;
				paddingTop += this.__pageDimentions[unloadedPageId].offsetHeight;
				this.__paddingBottom = Math.max(this.__paddingBottom - this.__pageDimentions[unloadedPageId].offsetHeight, 0);
				this.__paddingTop = paddingTop;
				renderedPageIds.shift();
			} else {
				var paddingBottom = this.__paddingBottom || 0;
				paddingBottom += this.__pageDimentions[unloadedPageId].offsetHeight;
				this.__paddingBottom = paddingBottom;
				renderedPageIds.pop();
			}

			this.__unloadedPageDimentions[unloadedPageId] = this.__pageDimentions[unloadedPageId];
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
			var renderedPageIds = this.__renderedPageIds;
			var pageOffsetTop = this.__paddingTop;
			var newPageIndex = -1;
			for (var i = 0, len = renderedPageIds.length; i < len; i++) {
				if (renderedPageIds[i] === opts.newPageId) {
					newPageIndex = i;
					break;
				}
				pageOffsetTop += pageDimentions[renderedPageIds[i]].offsetHeight;
			}
			pageDimentions[opts.newPageId] = {
				offsetTop: pageOffsetTop,
				offsetHeight: offsetHeight - pagesOffsetHeight + offsetTop
			};
			if (newPageIndex < renderedPageIds.length) {
				// recalculate offsetTop when page inserted above other pages
				for (i = newPageIndex + 1, len = renderedPageIds.length; i < len; i++) {
					pageDimentions[renderedPageIds[i]].offsetTop += pageDimentions[opts.newPageId].offsetHeight;
				}
			}
			if (opts.newPagePosition === "top") {
				prevPageThreshold = Math.round(pageDimentions[opts.newPageId].offsetHeight / 2);
			} else if (opts.newPagePosition === "bottom") {
				nextPageThreshold = Math.round(pageDimentions[opts.newPageId].offsetHeight / 2);
			}
		}

		this.__maxHeight = maxHeight;
		this.__viewportHeight = viewportHeight;
		this.__offsetTop = offsetTop;
		this.__offsetHeight = offsetHeight;
		this.__offsetBottom = offsetBottom;
		this.__prevPageThreshold = prevPageThreshold || this.__prevPageThreshold;
		this.__nextPageThreshold = nextPageThreshold || this.__nextPageThreshold;
	},

	__updateRemainingScrollHeight: function (opts) {
		opts = opts || {};
		if (this.__offsetHeight === 0) {
			return;
		}
		if (this.__loadingNextPage || this.__loadingPrevPage) {
			return;
		}
		var scrollY = window.scrollY;
		var remainingScrollBottom = this.__offsetHeight + this.__offsetBottom - scrollY - this.__viewportHeight - this.__paddingBottom;
		var pageDimentions = this.__pageDimentions;
		var pageIds = this.props.pageIds;
		var pageOpts = {};
		var __pageDimentions;
		if (remainingScrollBottom <= this.__nextPageThreshold) {
			__pageDimentions = pageDimentions[pageIds[0]];
			if (__pageDimentions && scrollY > (__pageDimentions.offsetHeight + this.__paddingTop)) {
				pageOpts.unloadPageId = pageIds[0];
			}
			this.__loadNextPage(pageOpts);
		} else if (opts.init !== true) {
			var remainingScrollTop = scrollY - this.__offsetTop - this.__paddingTop;
			__pageDimentions = pageDimentions[pageIds[pageIds.length-1]];
			if (remainingScrollTop <= this.__prevPageThreshold && __pageDimentions) {
				if (scrollY + (this.__viewportHeight * 2) < __pageDimentions.offsetTop) {
					pageOpts.unloadPageId = pageIds[pageIds.length-1];
				}
				this.__loadPrevPage(pageOpts);
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
