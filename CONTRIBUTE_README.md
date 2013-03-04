## Design

### Views

There are two places to find views. The main layout, navigation, and authentication views are found in `lib/tent-status/views` (html/erb). Everything else is found in `assets/javascripts/templates` (html/mustache).

Here are a few things you need to know:

- Elements with `data-view='SomeViewName'` will cause `Marbles.Views.SomeViewName` view class to be initialized using that element. `ack SomeViewName assets/javascripts/views` is a good way to find the relevant CoffeeScript file.
- Routers live in `assets/javascripts/routers` with easy to understand route maps at the top of each file. Look in these files to find the relevant view, and look in the view file to find the template name(s).
- Views (the CoffeeScript classes, not tempaltes) live in `assets/javascripts/views` and reference their coresponding template name and any templates rendered inside of that template (partials).
- Rendering partials in mustache is done like this: `{{> template_name}}`.

