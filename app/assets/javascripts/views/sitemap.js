var Sitemap = (function($, m) {

  var init = function() {
    init_d3();
  };

  var init_d3 = function() {
    var margin = { top: 20, right: 120, bottom: 20, left: 120 },
        width = 1024 - margin.right - margin.left,
        height = 800 - margin.top - margin.bottom;

    var i = 0,
        duration = 750,
        root;

    var tree = d3.layout.tree()
        .size([height, width]);

    var diagonal = d3.svg.diagonal()
        .projection(function(d) { return [d.y, d.x]; });

    var svg = d3.select(".sitemap-wrapper").append("svg")
        .attr("width", width + margin.right + margin.left)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    root = theJson;
    root.x0 = height / 2;
    root.y0 = 0;

    function collapse(d) {
      if (d.children) {
        d._children = d.children;
        d._children.forEach(collapse);
        d.children = null;
      }
    }

    update(root);

    d3.select(self.frameElement).style("height", "800px");

    function update(source) {

      // Compute the new tree layout.
      var nodes = tree.nodes(root).reverse(),
          links = tree.links(nodes);

      // Normalize for fixed-depth.
      nodes.forEach(function(d) { d.y = d.depth * 135; });

      // Update the nodes…
      var node = svg.selectAll("g.node")
          .data(nodes, function(d) { return d.id || (d.id = ++i); });

      // Enter any new nodes at the parent's previous position.
      var nodeEnter = node.enter().append("g")
          .attr("class", "node")
          .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
          .on("click", click);

      nodeEnter.append("circle")
          .attr("r", 1e-6)
          .style("fill", function(d) { return d._children ? "rgb(22, 135, 70)" : "#fff"; });

      nodeEnter.append("text")
          .attr("x", -8)
          .attr("y", -12)
          .attr("text-anchor", "start")
          .text(function(d) { return d.name; })
          .style("fill-opacity", 1e-6);

      // Transition nodes to their new position.
      var nodeUpdate = node.transition()
          .duration(duration)
          .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

      nodeUpdate.select("circle")
          .attr("r", 7.5)
          .style("fill", function(d) { return d._children ? "rgb(22, 135, 70)" : "#fff"; });

      nodeUpdate.select("text")
          .style("fill-opacity", 1);

      // Transition exiting nodes to the parent's new position.
      var nodeExit = node.exit().transition()
          .duration(duration)
          .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
          .remove();

      nodeExit.select("circle")
          .attr("r", 1e-6);

      nodeExit.select("text")
          .style("fill-opacity", 1e-6);

      // Update the links…
      var link = svg.selectAll("path.link")
          .data(links, function(d) { return d.target.id; });

      // Enter any new links at the parent's previous position.
      link.enter().insert("path", "g")
          .attr("class", "link")
          .attr("d", function(d) {
            var o = { x: source.x0, y: source.y0 };
            return diagonal({ source: o, target: o });
          });

      // Transition links to their new position.
      link.transition()
          .duration(duration)
          .attr("d", diagonal);

      // Transition exiting nodes to the parent's new position.
      link.exit().transition()
          .duration(duration)
          .attr("d", function(d) {
            var o = { x: source.x, y: source.y };
            return diagonal({ source: o, target: o });
          })
          .remove();

      // Stash the old positions for transition.
      nodes.forEach(function(d) {
        d.x0 = d.x;
        d.y0 = d.y;
      });
    }

    // Toggle children on click.
    function click(d) {
      window.location.href = d.url;
    }
  };

  return {
    init: init
  };
}(jQuery, Sitemap || {}));


var theJson = {
  "name": "Home",
  "url": "/",
  "children": [
  {
    "name": "Sign In",
    "url": "/signin",
    "children": [
    {
      "name": "Planners",
      "url": "/planners/admin",
      "children": [
      {
        "name": "Events",
        "url": "/planners/admin/events",
        "children": [
        {
          "name": "New Event",
          "url": "/planners/admin/events/new",
        }
      ]},
      {
        "name": "Account",
        "url": "/planners/admin/account",
        "children": [
        {
          "name": "Profile",
          "url": "/planners/admin/account/profile",
          "children": [
            {
              "name": "Change Password",
              "url": "/planners/admin/edit",
            }
          ]
        },
        {
          "name": "Messages",
          "url": "/planners/admin/account/inquiries",
        },
        {
          "name": "Settings",
          "url": "/planners/admin/account/settings",
        }]
      }]
    },
    {
      "name": "Vendors",
      "children": [
      {
        "name": "Locations",
        "url": "/vendors/admin/locations",
        "children": [
        {
          "name": "New Location",
          "url": "/vendors/admin/locations/new"
        },
        {
          "name": "Location Claims",
          "url": "/vendors/admin/locations/claims"
        }]
      },
      {
        "name": "Account",
        "url": "/vendors/admin/account",
        "children": [
        {
          "name": "Profile",
          "url": "/vendors/admin/account/profile",
          "children": [
            {
              "url": "/vendors/admin/edit",
              "name": "Change Password"
            }
          ]
        },
        {
          "name": "Billing",
          "url": "/vendors/admin/account/billing"
        },
        {
          "name": "Messages",
          "url": "/vendors/admin/account/inquiries"
        },
        {
          "name": "Settings",
          "url": "/vendors/admin/account/settings"
        }]
      }]
    }]
  },
  {
    "name": "Blog",
    "url": "/blog"
  }]
};
