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
parEstimationLBodeSSm <-function
(
		cnolist,				model,					ode_parameters=NULL,
		indices=NULL,			maxeval=Inf,			maxtime=100,			
		ndiverse=NULL,			dim_refset=NULL, 		local_solver=NULL,      
		time=1,					verbose=0, 				transfer_function=3,	
		reltol=1e-4,			atol=1e-3,				maxStepSize=Inf,		
		maxNumSteps=100000,		maxErrTestsFails=50,	nan_fac=1,
		lambda_tau=0, lambda_k=0, bootstrap=FALSE,
		SSpenalty_fac=0, SScontrolPenalty_fac=0, boot_seed=sample(1:10000,1)
)
{
	
	if (class(cnolist)=="CNOlist"){cnolist = compatCNOlist(cnolist)}
	if (!requireNamespace("MEIGOR", quietly = TRUE)) {
		stop("Package \"MEIGOR\" needed for SSm to work. Please install it or try the Genetic Algorithm
	optimiser instead. MEIGOR got depricated on Bioconductor in release 3.18, but you can download the latest
			 version from Github: https://github.com/jaegea/MEIGOR/tree/RELEASE_3_18 ",
			 call. = FALSE)
	}
	
	
	checkSignals(CNOlist=cnolist,model=model)
	
	adjMat=incidence2Adjacency(model);
	if(is.null(ode_parameters)){
		ode_parameters=createLBodeContPars(model,random=TRUE);
	}
	if(is.null(indices))indices <- indexFinder(cnolist,model,verbose=FALSE);
	
	#Check if essR is installed
	dummy_f<-function(x){
		return(0);
	}
	problem<-list(f=dummy_f,x_L=rep(0),x_U=c(1));
	opts<-list();
	opts$maxeval=0;
	opts$maxtime=0;

    val=MEIGOR::essR(problem,opts)

	problem=list();
	problem$f<-getLBodeContObjFunction(cnolist=cnolist,
	                                   model=model,
	                                   ode_parameters=ode_parameters,
	                                   indices=indices,
	                                   time=time,
	                                   verbose=verbose,
	                                   transfer_function=transfer_function,
	                                   reltol=reltol,
	                                   atol=atol,
	                                   maxStepSize=maxStepSize,
	                                   maxNumSteps=maxNumSteps,
	                                   maxErrTestsFails=maxErrTestsFails,
	                                   nan_fac=nan_fac,
	                                   lambda_tau=lambda_tau,
	                                   lambda_k=lambda_k,
	                                   bootstrap=bootstrap,
	                                   SSpenalty_fac=SSpenalty_fac,
	                                   SScontrolPenalty_fac=SScontrolPenalty_fac,
	                                   boot_seed=boot_seed);
	problem$x_L <- ode_parameters$LB[ode_parameters$index_opt_pars];
	problem$x_U <- ode_parameters$UB[ode_parameters$index_opt_pars];
	problem$x_0<- ode_parameters$parValues[ode_parameters$index_opt_pars];
	problem$int_var =0;
	problem$bin_var =0;
	opts=list();
	opts$maxeval=maxeval;
	opts$maxtime=maxtime;
	if(!is.null(local_solver))opts$local_solver=local_solver;
	if(!is.null(ndiverse))opts$ndiverse=ndiverse;      
	if(!is.null(dim_refset))opts$dim_refset=dim_refset;  
	results=MEIGOR::essR(problem,opts);
	ode_parameters$parValues[ode_parameters$index_opt_pars]=results$xbest;
	ode_parameters$ssm_results=results;
	return(ode_parameters);	
}

