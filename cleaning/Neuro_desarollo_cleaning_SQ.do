*Neuro-Desarrollo Data Cleaning 
*Author: Sarah Quander
*Date Created: 7-13-16
*Date Last Updated: 7-13-16
*-------------------------------------------------------------------------------
*Renaming Variables 
rename IdIndividuo id 
rename NumEstado id_state
rename Estado state
rename Municipio muni
rename NumMunicipio id_muni
rename Comunidad city 
rename NumComunidad id_city
rename NumFamilia id_family 
rename Sexo sex
rename sexonum sex1
rename FechaDeBaja birth_date
rename Delegacion test_center
rename altitud alt 
*------------------------------------------------------------------------------
*Renaming measurement variables
forval year = 2000/2014 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC{
	rename `month'_`year'_PESO PESO_`month'_`year'
	rename `month'_`year'_EDAD EDAD_`month'_`year'
	rename `month'_`year'_PED_FSOMA PED_FSOMA_`month'_`year'
	rename `month'_`year'_PEDZ PEDZ_`month'_`year'
	rename `month'_`year'_PEDNUT PEDNUT_`month'_`year'
	rename `month'_`year'_TED_FSOMA TED_FSOMA_`month'_`year'
	rename `month'_`year'_TEDZ TEDZ_`month'_`year'
	rename `month'_`year'_TEDNUT TEDNUT_`month'_`year'
	}
}

}
*Generating variables listing number of observations per subject 
egen num_observations = rownonmiss(EDAD*)

* Generate new variable recording subject age as integer values 
forval year = 2000/2014 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC{
	generate avg_EDAD_`month'_`year' = round(EDAD_`month'_`year',1)
	}
}

* Generate weight variables by subject age 
forval year = 2000/2014 {
forval age = 0/1378 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC {
		generate month_`age'_weight = PESO_`month'_`year' if avg_EDAD_`month'_`year' == `age'
		}
	}
}










