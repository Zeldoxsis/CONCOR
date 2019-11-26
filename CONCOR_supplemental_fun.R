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
