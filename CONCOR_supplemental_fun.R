#CONCOR supplementary functions
#Tyme Suda

#Contains functions that can be usfull to be used on the outputs of CONCOR
name=function(mat){
  #gives names v001,v002... to each collumn/row treated as the node names now
  a=1:nrow(mat)
  vnames=sprintf("v%03d", a)
  colnames(mat)=vnames
  rownames(mat)=vnames
  return(mat)
}

concor.vlaiditycheck=function(m.list){
  #check validity of concor input (makes sure matrixsizes/vertex names match and adds vertex names if they don't exist)
  #output is the same list of matrixies, with the adition of vertex names if they did not exist
  
  #check that matrix sizes match
  a=m.list[[1]]
  for (i in 1:length(m.list)) {
    if (length(a)!=length(m.list[[i]])) {
      stop('Adgacency matrixes of mixmatched sizes')
    }
  }
  
  #check if nodes are named
  b=sapply(m.list, function(x) is.null(colnames(x)))
  if (all(b)) {
    warning("node names don't exist\nAdding default node names\n")
    m.list=lapply(m.list, function(x) name(x))
    b=sapply(m.list, function(x) is.null(colnames(x)))
  }
  if (any(b)) {
    stop("Node name mismatch")
  }
  
  #check that colnames agree
  a=m.list[[1]]
  for (i in 1:length(m.list)) {
    if (all(colnames(a)!=colnames(m.list[[i]]))) {
      stop("Node name mismatch")
    }
  }
  return(m.list)
}

blk.apply = function(iobject, split, v="cat"){
  #function adds vertex atribute "v" to igraph object in iobject
  #atribute is the concor blocking specified in splitlist
  #Inputs:
  #iobject is the igraph object that is gaining the new vertex attribute, must be the same as the object CONCOR was ran on
  #split is the output from concor for the desired split
  #Output: returns thr igraph object with the new vertex atribute
  
  o=match(vertex.attributes(iobject)$name, split$vertex)
  o.block=split$block[o]
  temp=set.vertex.attribute(iobject, v, value = o.block)
  return(temp)
}

make.igraph=function(adj.list, nsplit=1){
  #function creates igrahp ibjects from each adgacency matrix in adj.list and adds the concor output as a vertex atribute "csplit" "n"
  #where n is nsplit, for nsplit=1 yeilds "csplit1", the output will be in a list
  #Inputs:
  #adj.list is the list of adjacency matrixies concor is ran on, each is a seperate relationship, and must corrispond to the same data
  #nsplit is the desired concor spliting
  
  #run concor on adj.list
  con.out=suppressWarnings(concor(adj.list, p=nsplit))
  
  #create igraph objects from the adjacency matrixies used as concor inputs
  igraph.list=lapply(adj.list, function(x) graph_from_adjacency_matrix(x))
  
  #Create split name (name of the vertex atribute)
  v=paste("csplit", nsplit ,sep="")
  
  #add concor split as a vertex atribute to each relation included in adj.list
  igraph.out=lapply(igraph.list, function(x) blk.apply(x, con.out, v))
  
  return(igraph.out)
}

concor.igraph.apply=function(igraph.list, nsplit=1){
  #run concor on a series of relations in igraph.list and add the putput as a vertex attribute
  
  #get adgacency matrix list for running concor on
  adj.list=lapply(igraph.list, function(x) get.adjacency(x, sparse = FALSE))
  
  #run concor on adj.list
  con.out=suppressWarnings(concor(adj.list, p = nsplit))
  
  #Create split name (name of the vertex atribute)
  v=paste("csplit", nsplit ,sep="")
  
  #add concor split as a vertex atribute to each relation included in adj.list
  igraph.out=lapply(igraph.list, function(x) blk.apply(x, con.out, v))
  
  return(igraph.out)
}

concor.plot= function(iobject, p=NULL){
  #function(iobject, split.name="cat", tital="cats", color.list)
  split.name=paste0("csplit", p)
  plot(iobject, vertex.color=vertex.attributes(iobject)[[split.name]], vertex.label=NA, vertex.size= 5,edge.arrow.size=.3)
}

