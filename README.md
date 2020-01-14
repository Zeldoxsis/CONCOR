# CONCOR
CONCOR (convergence of iterate correlations) is an algorithm meant for role analysis of social network data. It was introduced by Breiger et al. in the 1975 paper "An algorithm for clustering relational data with applications to social network analysis and comparison with multidimensional scaling." The version created here is meant for use on R data and was largely based off the description by Wasserman and Faust in the book "Social Network Analysis: Methods and Applications" as to be able to take into account directional social network data. The concor function itself does not rely on non-default packages but many of the supplementary functions rely on `igraph` and some of the blockmodeling functions rely on `sna`.

## Where to start
Before getting started using the concor algorithm on your own data it is recommended that you check out the example file `CONCOR_example.html`. This will walk through using the concor function and all other supplemental functions.

## The R Files
### CONCOR.R
Includes: The concor function and all sub-functions

### CONCOR_supplemental_fun.R
Includes: Functions for running concor and plotting the network using `igraph` 

### CONCOR_blockmodeling.R
Includes: Functions for blockmodeling based off the CONCOR split data, plotting them, and making/plotting reduced graphs


## Acknowledgements
This work was supported by the National Science Foundation under awards DUE-1711017 and DUE-1712341.