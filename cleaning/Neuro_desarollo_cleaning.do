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
*Renaming weight and date measurement variables
forval year = 2000/2014 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC{
	rename `month'_`year'_PESO PESO_`month'_`year'
	}
}
forval year = 2000/2014 {
	foreach month in ENE_FEB MAR_ABR MAY_JUN JUL_AGO SEP_OCT NOV_DIC{
	rename `month'_`year'_EDAD EDAD_`month'_`year'
	}
}
	
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










foreach edad in EDAD* {
	generate `edad'


local year_age 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 {
	 {
		foreach year in `year_age'
		generate avg_`month'_`year'_age = round(`month'_`year'_EDAD,1)
		}
	}
	

