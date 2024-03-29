#
#  This file is part of the CNO software
#
#  Copyright (c) 2011-2013 - EBI
#
#  File author(s): CNO developers (cno-dev@ebi.ac.uk)
#
#  Distributed under the GPLv3 License.
#  See accompanying file LICENSE.txt or copy at
#      http://www.gnu.org/licenses/gpl-3.0.html
#
#  CNO website: http://www.cellnopt.org
#
##############################################################################
#' @export
plotLBodeModelSim <-function
(
	cnolist,				    model,					    ode_parameters=NULL,
	indices=NULL,			    adjMatrix=NULL,			  	timeSignals=NULL,
	time=1,						verbose=0, 				    transfer_function=3,		
	reltol=1e-4,				atol=1e-3,				    maxStepSize=Inf,
	maxNumSteps=100000,			maxErrTestsFails=50,  		large=FALSE,          		
	nsplit=4, show=TRUE
)
{
	
	if (class(cnolist)=="CNOlist"){cnolist = compatCNOlist(cnolist)}
	if(is.null(indices))indices=indexFinder(cnolist,model);
	if(is.null(adjMatrix))adjMatrix=incidence2Adjacency(model);
	if(is.null(ode_parameters))ode_parameters=createLBodeContPars(model);
	if(!is.null(timeSignals))cnolist$timeSignals=timeSignals;
	
	
	sim_data=getLBodeModelSim(cnolist,model,
							  ode_parameters,indices,timeSignals,time,verbose,transfer_function,
							  reltol,atol,maxStepSize,maxNumSteps,maxErrTestsFails);
	
	temp=list();
	
	for(i in 1:length(cnolist$timeSignals)){
		
		temp[[i]]=sim_data[[i]];
	}
	
	sim_data=temp;
	
	cnolist = simdata2cnolist(sim_data, cnolist, model)
	
	if (show==T){
		if(large)
		{
			plotCNOlistLarge(cnolist,nsplit);
		}
		else
		{   
			plotCNOlist(cnolist);
		}
	}
	
	return(sim_data);
}
