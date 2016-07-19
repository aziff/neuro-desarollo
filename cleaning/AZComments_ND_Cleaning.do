// Anna comments!

/*
Neuro-Desarrollo Data Merging 
Author: 			Sarah Quander
Date Created: 		7-13-16
Date Last Updated: 	7-19-16
*/

clear
set more off 
set maxvar 30000


local filedir: 	pwd

if strpos("`filedir'", "cleaning") == 0 {
	di as error "Error: Must run dofile from file's directory"
	exit 111
}

global klmMexico: env klmMexico
local scripts = subinstr("`filedir'/scripts", "/", c(dirsep), .)


*Merging Bimestral and Neuro_Longitudinal data
use ${klmMexico}/Neurodesarollo/NEURO_LONGITUDINAL_29_06_2015.dta
recast str Nino, force
tempfile neuro_save
save `neuro_save'

clear

use ${klmMexico}/Neurodesarollo/MATRIZ_BIMESTRAL_UKA_2000-2014.dta
recast str Nino, force

merge 1:m Nino Delegacion using `neuro_save' 

*Save merged data
save merged-neurodesarrollo, replace

// AZ comment: up to here should be a separate .do-file to merge
*-------------------------------------------------------------------------------
/*
Neuro-Desarrollo Data Cleaning 
Author: 			Sarah Quander
Date Created: 		7-13-16
Date Last Updated: 	7-19-16
*/

// AZ comment: are these variables well-labelled?
*Renaming Variables 
rename IdIndividuo 	id 
rename NumEstado 	id_state
rename Estado 		state
rename Municipio 	muni
rename NumMunicipio id_muni
rename Comunidad 	city 
rename NumComunidad id_city
rename NumFamilia 	id_family 
rename Sexo 		sex
rename sexonum 		sex1
rename FechaNac 	birth_date
rename Delegacion 	test_center
rename altitud 		alt 
*------------------------------------------------------------------------------
*Renaming measurement variables
forval year = 2000/2014 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC{
		rename `month'_`year'_PESO 			peso_`month'_`year'
		rename `month'_`year'_EDAD 			edad_`month'_`year'
		rename `month'_`year'_PED_FSOMA 	ped_fsoma_`month'_`year'
		rename `month'_`year'_PEDZ 			pedz_`month'_`year'
		rename `month'_`year'_PEDNUT 		pednut_`month'_`year'
		rename `month'_`year'_TED_FSOMA 	ted_fsoma_`month'_`year'
		rename `month'_`year'_TEDZ 			tedz_`month'_`year'
		rename `month'_`year'_TEDNUT 		tednut_`month'_`year'
		rename `month'_`year'_talla 		talla_`month'_`year'
		//rename `month'_`year'_GPESO 		gpeso_`month'_`year'
		rename `month'_`year'_EDAD_talla 	edad_talla_`month'_`year'
		}
}

rename inicial_PED_FSOMA 	inicial_ped_fsoma
rename inicial_EDAD 		inicial_edad
*-------------------------------------------------------------------------------

// AZ comment: I added a loop here. Please check that it is correct
*Renaming missing variables
foreach var in edad pedz peso edad_talla {
	forval year = 2000/2014 {
		foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC{
			replace `var'_`month'_`year' = . if `var'_`month'_`year'== -999
			//replace pedz_`month'_`year' = . if pedz_`month'_`year' == -999
			//replace peso_`month'_`year' = . if peso_`month'_`year' == -999
			//replace edad_talla_`month'_`year' = . if edad_talla_`month'_`year' == -999
		}
	}
}
*-------------------------------------------------------------------------------
*Generating accurate calcuations of subject ages
gen gen_inicial_age 	= inicial_ped_fsoma - birth_date
replace inicial_edad 	= (gen_inicial_age/365) * 12
drop gen_inicial_age

forval year = 2000/2014 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC{
		replace edad_`month'_`year' = (ped_fsoma_`month'_`year' - birth_date)
		replace edad_`month'_`year' = (edad_`month'_`year' / 365) * 12 
	}
}

*-------------------------------------------------------------------------------
*Generating variables listing number of observations per subject 
egen num_observations = rownonmiss(edad*)

*-------------------------------------------------------------------------------
// AZ comment: consider adding a loop here as I did above!
* Generate new variable recording subject age as integer values 
forval year = 2000/2014 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC{
		generate rnd_edad_`month'_`year' = round(edad_`month'_`year',1)
		replace edad_`month'_`year' = rnd_edad_`month'_`year'
		drop rnd_edad_`month'_`year'
		generate rnd_edad_talla_`month'_`year' = round(edad_talla_`month'_`year',1)
		replace edad_talla_`month'_`year' = rnd_edad_talla_`month'_`year'
		drop rnd_edad_talla_`month'_`year'
		
	}
}

*-------------------------------------------------------------------------------
* Generate weight variables by subject age  
set trace on 
// AZ comment: in general, set trace on should only be used for debugging, not in the .dofile
forval year = 2000/2014 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC{
	levelsof edad_`month'_`year', local(age_`month'_`year')
	levelsof edad_talla_`month'_`year', local(age_talla_`month'_`year')
	}
}
// AZ comment: what is the difference between edad and edad_talla?

forval year = 2000/2014 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC{
		foreach age in `age_`month'_`year'' {
			foreach measure in peso talla pedz pednut tedz tednut gpeso {
				cap generate `measure'_`age' = .
				cap replace `measure'_`age' = `measure'_`month'_`year' ///
							if rnd_edad_`month'_`year' == `age'
			}
		}
	}
}

forval year = 2000/2014 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC{
		foreach age in `age_talla_`month'_`year'' {
				cap generate talla_`age' = .
				cap replace talla_`age' = talla_`month'_`year' ///
							if rnd_edad_`month'_`year' == `age'
			}
		}
	}
*-------------------------------------------------------------------------------
*dropping excessive variables
forval year = 2002/2014 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC {
		foreach measure in peso pedz pednut tedz tednut talla  {
			drop `measure'_`month'_`year'
			}
		}
	}
*-------------------------------------------------------------------------------
*Encoding a numeric variable for the `PEDNUT' string variable 
forval year = 2001/2014 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC{
	encode pednut_`month'_`year', generate(pednut_num_`month'_`year')
	drop pednut_`month'_`year'
	}
}
set trace off

// AZ comment: it might be convenient to label the variables (label variable...) in the loops you have above

*misstable summarize (peso*)
