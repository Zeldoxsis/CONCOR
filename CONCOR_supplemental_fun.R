#CONCOR supplementary functions

#Created 8/20/19
#Tyme Suda

#Contains functions that can be usfull to be used on the outputs of CONCOR

#simmple plotting functions:
blk.apply = function(iobject, split, v="cat"){
  #function adds vertex atribute "v" to igraph object in iobject
  #atribute is the concor blocking specified in splitlist
  #Inputs:
  #iobject is the igraph object that is gaining the new vertex attribute, must be the same as the object CONCOR was ran on
  #split is the output from concor for the desired split
  #Output: returns thr igraph object with the new vertex atribute
  
  temp2=split$block[order(split$vertex)]
  temp=set.vertex.attribute(iobject, v, value = temp2)
  return(temp)
}

concor.plot= function(iobject, split.name="cat", tital="cats"){
  #an exaple function for plotting the network with a concor split shown in color
  #split,name is the name of the vertex atribute the concor split is saved as in the igraph object
  plot(iobject, vertex.color=vertex.attributes(iobject)[[split.name]], vertex.label=NA, vertex.size= 5,edge.arrow.size=.3, main=tital)
}

#blockmodeling functions
make.blokmodel.stuff=function(iobject, s.name="cat"){
  #s.name is the name of the vertex atribute the concor split is saved as in the igraph object
  #iobject is the desired igraph object to be run on
  #otputs a list with:
  #the first entry being the blockmodel as outputed by statnet
  #the second being a non-weighted reduced graph's igraph object
  #the third being the weighted reduced graph's igraph object 
  
  #get adgacency maatrixes for latter use
  mat=get.adjacency(iobject)
  
  #atach statnet (the package can interfeer with igraph)
  library(statnet)
  
  #make blokmodels
  blk.mod=blockmodel(as.matrix(mat), vertex.attributes(iobject)[[s.name]])
  
  
  #get rid of statnet (and every other fucking pakage that fights me)
  lapply(paste('package:',names(sessionInfo()$otherPkgs),sep=""),detach,character.only=TRUE,unload=TRUE)
  #put igraph back on for later use mabey
  library(igraph)
  
  #check density of the igraph object
  dens=edge_density(iobject, loops = FALSE)
  
  #pull out the density matrix of the blk.module
  d=blk.mod[[5]]

  
  #play with the matrix for latter use
  #check for and make NaN to 0
  d[is.nan(d)]=0
  #set blocks with density less than overall density to 0
  d[d<dens]=0
  #save as new varible for latter use
  d2=d
  
  ##For unweighted reduced graph
  #set all non zero (less than overall density blocks to 1)
  d[d!=0]=1
  matty=as.matrix(d)
  #make a new igraph object out of our density matrix
  iplotty=graph_from_adjacency_matrix(matty, mode = "directed")
  
  ##for a weighted reduced graph
  #find minimum density and scale all by that
  min=min(d2[d2>0])
  matty2=as.matrix(d2/min)
  #scale all densitys to have maximum between 18 and 20
  while (max(matty2)>20) {
    matty2=matty2/1.05
  }
  while (max(matty2)<18) {
    matty2=matty2*1.05
  }
  #make a new igraph object out of our density matrix
  iplotty2=graph_from_adjacency_matrix(matty2, mode = "directed", weighted = TRUE)
  
  #return raw blockmedel data and new igraph object
  return(list(blk.mod,iplotty, iplotty2, dens))
}

weighted.reduced.plot= function(blk.out){
  #plots just weighted reducedl network
  #plots colors based on order of blocks (I think this should match those on the networks)
  #vertex/arrow sizes used for saving large immages
  cat=blk.out
  plot(cat[[2]],vertex.color=c(1:length(vertex.attributes(cat[[2]])[[1]])), vertex.label = NA,
       edge.width=(E(cat[[3]])$weight)/3, edge.arrow.size=.6, vertex.size= 25)
}

reduced.plot=function(blk.out){
  #plots unweightedreduced network diagram
  #plots colors based on order of blocks (I think this should match those on the networks)
  #vertex/arrow sizes used for saving large immages
  cat=blk.out
  plot(cat[[2]],vertex.color=c(1:length(vertex.attributes(cat[[2]])[[1]])), vertex.label = NA,
       edge.width=5, edge.arrow.size=.6, vertex.size= 25)
}