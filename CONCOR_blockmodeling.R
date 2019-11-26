
make.blk=function(adj.list, splitn=1){
  #returns raw blockmodel data
  
  #run concor to get igraph splits, and shhh
  con.out=suppressWarnings(concor(adj.list, p=splitn))
  
  #check and reorder the concor output to be the same as the vertex list
  o=match(colnames(adj.list[[1]]), con.out$vertex)
  o.block=con.out$block[o]
  
  ##prepare to atach sna (needed for next part) so it can later be detached easily
  #record the packagest that existed at the start
  pre=names(sessionInfo()$otherPkgs)
  #get rid of all nondefault packages
  if (length(pre)!=0) {
    invisible(lapply(paste('package:',names(sessionInfo()$otherPkgs),sep=""),detach,character.only=TRUE,unload=TRUE))
  }
  #add that asshole of a package nice and quietly
  suppressMessages(library(sna))
  
  #make blokmodels (aka the thing allthis has lead to)
  blk.mod.list=lapply(adj.list, function(x) blockmodel(as.matrix(x), o.block))
  
  ##dtach sna and reatach whatever eles
  invisible(lapply(paste('package:',names(sessionInfo()$otherPkgs),sep=""),detach,character.only=TRUE,unload=TRUE))
  invisible(lapply(pre, library, character.only = TRUE))
  
  #return raw blockmedel data
  return(blk.mod.list)
}

edge.dens=function(adj.mat){
  adj.mat[adj.mat>0]=1
  a=sum(adj.mat)
  m=length(adj.mat)-sqrt(length(adj.mat))
  d=a/m
  return(d)
}

make.red=function(adj.list, splitn=1, weighted=FALSE){
  #returns list of reduced matrixies one for each relation in $red.mat
  #also returns the cutoff densities in $dens
  #inputs are list of adj matrxies what split you want and weather weited or not (True is weighted)
  
  #get the raw blockmodel resaults
  blk.out=make.blk(adj.list, splitn)
  
  #check density of the adgacency matrix
  dens.vec=sapply(adj.list, function(x) edge.dens(x))
  
  #pull out the density matrix of the blk.module
  d=lapply(blk.out, function(x) x[[5]])
  
  #play with the matrix for latter use
  mat.return=vector("list", length = length(dens.vec))
  
  for (i in 1:length(dens.vec)) {
    temp1=d[[i]]
    #check for and make NaN to 0
    temp1[is.nan(temp1)]=0
    #set blocks with density less than overall density to 0
    temp1[temp1<dens.vec[[i]]]=0
    if (!weighted) {
      temp1[temp1>0]=1
      mat.return[[i]]=temp1
    }
    if (weighted) {
      #find minimum density and scale all by that
      min=min(temp1[temp1>0])
      mat.return[[i]]=as.matrix(temp1/min)
      #scale all densitys to 10 or less
      while (max(mat.return[[i]])>20) {
        mat.return[[i]]=mat.return[[i]]/1.05
      }
      while (max(mat.return[[i]])<18) {
        mat.return[[i]]=mat.return[[i]]*1.05
      }
    }
  }
  l.return=list()
  l.return$red.mat=mat.return
  l.return$dens=dens.vec
  return(l.return)
}

plot.blk=function (x, ...) {
  #slightly eddided version of the function from SNA, plots as square and slighly changed labeling also atached SNA and later removed
  #why is it convention to not have comments
  
  ##atach SNA for latter use and record packages that existed beforehand
  #record the packagest that existed at the start
  pre=names(sessionInfo()$otherPkgs)
  #get rid of all nondefault packages
  invisible(lapply(paste('package:',names(sessionInfo()$otherPkgs),sep=""),detach,character.only=TRUE,unload=TRUE))
  #add sna
  suppressMessages(library(sna))
  
  oldpar <- par(no.readonly = TRUE)
  on.exit(par(oldpar))
  n <- dim(x$blocked.data)[2]
  m <- stackcount(x$blocked.data)
  if (!is.null(x$plabels)) 
    plab <- x$plabels
  else plab <- (1:n)[x$order.vector]
  if (!is.null(x$glabels)) 
    glab <- x$glabels
  else glab <- 1:m
  par(mfrow = c(floor(sqrt(m)), ceiling(m/floor(sqrt(m)))))
  if (m > 1) 
    for (i in 1:m) {
      plot.sociomatrix(x$blocked.data[i, , ], labels = list(plab, 
                                                            plab), main = glab[i], 
                       drawlines = FALSE, asp=1)
      for (j in 2:n) if (x$block.membership[j] != x$block.membership[j - 
                                                                     1]) 
        abline(v = j - 0.5, h = j - 0.5, lty = 3)
    }
  else {
    plot.sociomatrix(x$blocked.data, labels = list(plab, 
                                                   plab), main = glab[1], 
                     drawlines = FALSE, asp=1)
    for (j in 2:n) if (x$block.membership[j] != x$block.membership[j - 
                                                                   1]) 
      abline(v = j - 0.5, h = j - 0.5, lty = 3)
  }
  
  ##dtach sna and reatach whatever eles
  invisible(lapply(paste('package:',names(sessionInfo()$otherPkgs),sep=""),detach,character.only=TRUE,unload=TRUE))
  invisible(lapply(pre, library, character.only = TRUE))
}

plot.blk.labeless=function(bm){
  #get rid of those pesky lables
  bm$plabels = rep("",length(bm$plabels))
  bm$glabels = ""
  plot.blk(bm)
}


#Igraph needed beyond this point
make.red.igraph=function(red.mat){
  w=NULL
  if (any(red.mat>1)) {
    w=TRUE
  }
  iplotty=graph_from_adjacency_matrix(red.mat, mode = "directed", weighted = w)
  return(iplotty)
}

plot.red.weighted= function(blk){
  #plots just weighted blockmodel network
  #plots colors based on order of blocks (I think this should match those on the networks)
  plot(blk,vertex.color=c(1:length(vertex.attributes(blk)[[1]])), vertex.label = NA,
       edge.width=(E(blk)$weight/2), edge.arrow.size=.6, vertex.size= 25)
}

plot.red= function(blk){
  #plots just weighted blockmodel network
  #plots colors based on order of blocks (I think this should match those on the networks)
  plot(blk,vertex.color=c(1:length(vertex.attributes(blk)[[1]])), vertex.label = NA,
       edge.width=4, edge.arrow.size=.6, vertex.size= 25)
}
