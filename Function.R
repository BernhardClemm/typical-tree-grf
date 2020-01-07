#############################
### FIND A "TYPICAL" TREE ###
#############################

# Required packages: dplyr, tidyr, grf, DiagrammeR

# This function is meant to help visualizing random forests by finding a "typical" tree. 
# Its output does *not* have any deeper statistical meaning. 

# The "typical" tree of a forest is found through the following algorithm: 
## The forest is "chopped down" (i.e. subset) so that all trees have the most common first split variable.
## The forest is further chopped down to all those trees with the most common second split variable.
## And so on, until either the most common case is no more splits, or there are no more than two trees left.

# The function's output is a grf::plot object of the the typical tree.

typical_tree <- function(cf_object) {
  
  num_trees <- cf_object$`_num_trees` # number of trees in the forest
  trees <- data.frame(id = 1:num_trees) # data frame for storing subsets of trees
  
  level <- 1 # level of tree
  node_vector <- c(1) # nodes at respective level
  search_next_level <- TRUE 
  
  while (search_next_level == TRUE) {
    
    vars <- NULL # split variable(s) at respective level
    
    for (i in 1:nrow(trees)) { # this loops through all trees still in the forest and finds most common split variable(s) at the respective level
      
      id <- trees[i, "id"] 
      tree <- get_tree(cf_object, id) 
      
      for (node in node_vector) {
        
        var <- paste("node", node, "var", sep = "_")
        vars <- c(vars, var)
        
        if (tree[["nodes"]][[node]][["is_leaf"]] == FALSE) {
          variable <- tree[["nodes"]][[node]][["split_variable"]]
          trees[i, paste("node", node, "var", sep = "_")] <- tree[["columns"]][[variable]]
        }
        
      }
    }
    
    trees <- trees %>% unite(level_split_var, vars, sep = " ", remove = FALSE) # If more than one split variable (e.g. at level two), combine variable names to one string
    
    var_primary <- names(sort(table(trees$level_split_var), decreasing = TRUE)[1]) # Find the most common split variable(s) at respective level
    
    print(paste("Most common variable(s) at level ", level, ": ", var_primary, sep = ""))
    
    trees %<>% filter(level_split_var == var_primary) # Chop the forest, selecting trees with same splitting variables at this level
    
    test_tree <- get_tree(cf_object, trees[1, "id"]) 
    next_nodes <- c() 
    for (node in node_vector) { # Find the nodes at the next level  
      if (test_tree[["nodes"]][[node]][["is_leaf"]] == FALSE) {
        left <- test_tree[["nodes"]][[node]][["left_child"]]
        right <- test_tree[["nodes"]][[node]][["right_child"]]
        next_nodes <- c(next_nodes, left, right)
      }
    }
    node_vector <- next_nodes
    
    level <- level + 1
    
    if (is.null(node_vector) | nrow(trees) < 3) { # stop search if no more splits at next level, or if fewer than two trees
      search_next_level <- FALSE
      typical_tree_id <<- trees[1, "id"]
    }
  }
  
  if (search_next_level == FALSE) {
    print(paste("Typical tree found after level", level))
  }
  
  typical_tree_plot <- plot(get_tree(causal_forest, typical_tree_id))
  
  return(typical_tree_plot)
  
}
