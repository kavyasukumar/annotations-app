//= require_tree ./_vendor

/* If you use any Foundation javascript add the following line to the top of
 * of this file...
 *   //= require foundation
 * then uncomment the following line.
 */
// $(document).foundation();

/* If you would like to use Javascript templates, you can enable them by adding
 * the following line to the top of this file
 *   //=require_tree ./_templates
 * you can then use the templates like this:
 *   var template = window.JST['_templates/example'];
 *   var html = template({my_var: 'Hello!', list: [1, 2, 3, 4]});
 *   $('#example').html(html);
 * Template files should have the extension `.jst.ejs` to be properly loaded.
 */

(function() {
  // Application code goes here

  $(document).ready(function() {
    // Initialize lazy load
    $('.lazy').lazyload({
      threshold : 0,
      failure_limit: 999,
      effect: 'fadeIn',
      data_attribute_queries: [
        {media: "(max-width: 1600px)", data_name: "x-large"},
        {media: "(max-width: 1200px)", data_name: "large"},
        {media: "(max-width: 900px)", data_name: "medium"},
        {media: "(max-width: 640px)", data_name: "small"},
        {media: "(max-width: 400px)", data_name: "x-small"}
      ]
    });


    // Initialize your code here
  });
})();
