This function is meant to help visualizing random forests by finding a "typical" tree. Its output does *not* have any deeper statistical meaning. 

It builds on the the `grf` package and the resulting forest object. To understand how to build a random forest, consult the documentation [here](https://grf-labs.github.io/grf/index.html). To access forests, consider the example of a causal forest. The first tree of a forest called `forst` can be accessed like this:

```
tree_id <- 1
first_tree <- get_tree(forst, tree_id)
```

It can be plotted like this:

```
plot(first_tree)
```

The "typical" tree of a forest is found through the following algorithm: 

- The forest is "chopped down" (i.e. subset) so that all trees have the most common first split variable.
- The forest is further chopped down to all those trees with the most common second split variable.
- And so on, until either the most common case is no more splits, or there are no more than two trees left.

The function's output is a grf::plot object of the the typical tree.
