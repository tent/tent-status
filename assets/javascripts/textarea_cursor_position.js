/*
 * https://github.com/kir/js_cursor_position
 * Copyright (c) 2010-2012 Kirill Maximov, released under the MIT license
 */

// string splitter
if (!window.maxkir) maxkir = {};

// width_provider_function is a function which takes one argument - a string
// and returns width of the string
maxkir.StringSplitter = function(width_provider_function) {
  this.get_width = width_provider_function;
};

// returns array of strings, as if they are splitted in textarea
maxkir.StringSplitter.prototype.splitString = function(s, max_width) {

  if (s.length == 0) return [""];
  
  var prev_space_pos = -1;
  var width_exceeded = false;

  var that = this;
  var cut_off = function(idx) {
    var remaining = s.substr(idx + 1);
    if (remaining.length > 0) {
      return [s.substr(0, idx + 1)].concat(that.splitString(remaining, max_width));
    }
    return [s.substr(0, idx + 1)]; 
  };

  for(var i = 0; i < s.length; i ++) {
    if (s.charAt(i) == ' ') {

      width_exceeded = this.get_width(s.substr(0, i)) > max_width;
      if (width_exceeded && prev_space_pos > 0) {
        return cut_off(prev_space_pos);
      }
      if (width_exceeded) {
        return cut_off(i);
      }
      prev_space_pos = i;
    }
    if (s.charAt(i) == '\n') {
      return cut_off(i);
    }
  }

  if (prev_space_pos > 0 && this.get_width(s) > max_width) {
    return cut_off(prev_space_pos);
  }
  return [s];
};

// selection rannge
if (!window.maxkir) maxkir = {};

/**
 * Get current selection range for the TEXTAREA or INPUT[text] element.
 *
 * Usage:
 *
 *  var range = new maxkir.SelectionRange(textarea);
 *  var selection = range.get_selection_range()
 *  var selectionStart = selection[0]
 *  var selectionEnd   = selection[1]
 *  On a error, returns [0,0]
 *
 *  var selection_text = range.get_selection_text();
 *
 *
 * */
maxkir.SelectionRange = function(element) {
  this.element = element;
};


maxkir.SelectionRange.prototype.get_selection_range = function() {

  var get_sel_range = function(element) {
    // thanks to http://the-stickman.com/web-development/javascript/finding-selection-cursor-position-in-a-textarea-in-internet-explorer/
    if( (typeof element.selectionStart == 'undefined') && document.selection ){
      // The current selection
      var range = document.selection.createRange();
      // We'll use this as a 'dummy'
      var stored_range = range.duplicate();
      // Select all text
      if (element.type == 'text') {
        stored_range.moveStart('character', -element.value.length);
        stored_range.moveEnd('character', element.value.length);
      } else { // textarea
        stored_range.moveToElementText( element );
      }
      // Now move 'dummy' end point to end point of original range
      stored_range.setEndPoint( 'EndToEnd', range );
      // Now we can calculate start and end points
      var selectionStart = stored_range.text.length - range.text.length;
      var selectionEnd = selectionStart + range.text.length;
      return [selectionStart, selectionEnd];
    }
    return [element.selectionStart, element.selectionEnd];
  };

  try {
    return get_sel_range(this.element);
  }
  catch(e) {
    return [0,0]
  }
};

maxkir.SelectionRange.prototype.get_selection_text = function() {
  var r = this.get_selection_range();
  return this.element.value.substring(r[0], r[1]);
};

// cursor
if (!window.maxkir) maxkir = {};
maxkir.FF = /Firefox/i.test(navigator.userAgent);

// Unify access to computed styles (for IE)
if (typeof document.defaultView == 'undefined') {
  document.defaultView = {};
  document.defaultView.getComputedStyle = function(element){
    return element.currentStyle;
  }
}

// This class allows to obtain position of cursor in the text area
// The position can be calculated as cursorX/cursorY or
// pointX/pointY
// See getCursorCoordinates and getPixelCoordinates
maxkir.CursorPosition = function(element, padding) {
  this.element = element;
  this.padding = padding;
  this.selection_range = new maxkir.SelectionRange(element);

  var that = this;

  this.get_string_metrics = function(s) {
    return maxkir.CursorPosition.getTextMetrics(element, s, padding);
  };

  var splitter = new maxkir.StringSplitter(function(s) {
    var metrics = that.get_string_metrics(s);
    //maxkir.info(s + " |||" + metrics)
    return metrics[0];
  });

  this.split_to_lines = function() {
    var innerAreaWidth = element.scrollWidth;
    if (maxkir.FF) {  // FF has some implicit additional padding
      innerAreaWidth -= 4;
    }

    var pos = that.selection_range.get_selection_range()[0];
    return splitter.splitString(element.value.substr(0, pos), innerAreaWidth);
  };

};

maxkir.CursorPosition.prototype.getCursorCoordinates = function() {
  var lines = this.split_to_lines();
  return [lines[lines.length - 1].length, lines.length];
};

maxkir.CursorPosition.prototype.getPixelCoordinates = function() {
  var lines = this.split_to_lines();
  var m = this.get_string_metrics(lines[lines.length - 1]);
  var w = m[0];
  var h = m[1] * lines.length - this.element.scrollTop + this.padding;
  return [w, h];
};

/** Return preferred [width, height] of the text as if it was written inside styledElement (textarea)
 * @param styledElement element to copy styles from
 * @s text for metrics calculation
 * @padding - explicit additional padding
 * */
maxkir.CursorPosition.getTextMetrics = function(styledElement, s, padding) {

  var element = styledElement;
  var clone_css_style = function(target, styleName) {
    var val = element.style[styleName];
    if (!val) {
      var css = document.defaultView.getComputedStyle(element, null);
      val = css ? css[styleName] : null;
    }
    if (val) {
      target.style[styleName] = val;
    }
  };

  var widthElementId = "__widther";
  var div = document.getElementById(widthElementId);
  if (!div) {
    div = document.createElement("div");
    document.body.appendChild(div)
    div.id = widthElementId;

    div.style.position = 'absolute';
    div.style.left = '-10000px';
  }

  clone_css_style(div, 'fontSize');
  clone_css_style(div, 'fontFamily');
  clone_css_style(div, 'fontWeight');
  clone_css_style(div, 'fontVariant');
  clone_css_style(div, 'fontStyle');
  clone_css_style(div, 'textTransform');
  clone_css_style(div, 'lineHeight');

  div.style.width = '0';
  div.style.paddingLeft = padding + "px";

  div.innerHTML = s.replace(' ', "&nbsp;");
  div.style.width = 'auto';
  return [div.offsetWidth, div.offsetHeight];

};
