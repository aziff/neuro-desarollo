*-------------------------------------------------------------------------------
/*
Neuro-Desarrollo Data Cleaning 
Author: 			Sarah Quander
Date Created: 		7-13-16
Date Last Updated: 	8-2-16
*/

*Renaming Variables 
rename *,lower
rename idindividuo 	id
rename numestado 	id_state
rename estado 		state
rename municipio 	muni
rename nummunicipio 	id_muni
rename comunidad 	city 
rename numcomunidad 	id_city
rename numfamilia 	id_family 
rename sexo 		sex
rename sexonum 		sex_num
rename fechanac 	birth_date
rename delegacion 	test_center
rename altitud 		alt 
rename beneficiario     caretaker
rename nino             name_subject

*------------------------------------------------------------------------------
*Renaming measurement variables

foreach month in ene_feb mar_abr may_jun jul_ago sep_oct nov_dic{
	foreach time in primer segundo{
		forval year = 2000/2014 {
			foreach test in anemia hb {
	
		cap rename `month'_`year'_peso 			weight_`month'_`year'
		cap rename `month'_`year'_edad 			age_`month'_`year'
		cap rename `month'_`year'_ped_fsoma 		test_date_`month'_`year'
		cap rename `month'_`year'_pedz			zscore_`month'_`year'
		cap rename `month'_`year'_pednut		weight_level_`month'_`year'
		cap rename `month'_`year'_ted_fsoma		test_date_height_`month'_`year'
		cap rename `month'_`year'_tedz			zscore_height_`month'_`year'
		cap rename `month'_`year'_tednut		height_level_`month'_`year'
		cap rename `month'_`year'_edad_talla		age_height_`month'_`year'
		cap rename `month'_`year'_tall                  height_`month'_`year'
		cap rename `time'_semestre_`year'_`test' 	`test'_`time'_`year'
		cap rename primer_semestre_fecha_`year'_hb  	hb_primer_date_`year'
		cap rename segundo_semestre_fecha_`year'_hb  	hb_segundo_`year'
			}
		}
	}
}

foreach var in weight age test_date zscore weight_level test_date_height ///
zscore_height height_level height age_height {
	forval year = 2000/2014{
		cap rename `var'_ene_feb_`year' 	`var'_jan_feb_`year'
		cap rename `var'_mar_abr_`year'		`var'_mar_apr_`year'
		cap rename `var'_may_jun_`year'	        `var'_may_jun_`year'
		cap rename `var'_jul_ago_`year'		`var'_jul_aug_`year'
		cap rename `var'_sep_oct_`year'		`var'_sep_oct_`year'
		cap rename `var'_nov_dic_`year'		`var'_nov_dec_`year'
	}
}

foreach period in inicial final{
	rename `period'_ped_fsoma 	test_date_`period'
	rename `period'_edad		age_`period'
}

rename inicial_hb  		hb_inicial
rename inicial_anemia 		anemia_inicial
rename final_hb			hb_final
rename final_anemia 		anemia_final 

      
*-------------------------------------------------------------------------------
*Renaming missing variables
foreach var in age zscore weight age_height {
	forval year = 2000/2014 {
		foreach month in jan_feb mar_apr may_jun jul_aug sep_oct nov_dec{
			replace `var'_`month'_`year' = . if `var'_`month'_`year'== -999
		}
	}
}
*-------------------------------------------------------------------------------
*Generating accurate calcuations of subject ages
gen gen_inicial_age 	= test_date_inicial - birth_date
replace age_inicial 	= (gen_inicial_age/365) * 12
drop gen_inicial_age

forval year = 2000/2014 {
	foreach month in jan_feb mar_apr may_jun jul_aug sep_oct nov_dec{
		replace age_`month'_`year' = (test_date_`month'_`year' - birth_date)
		replace age_`month'_`year' = (age_`month'_`year' / 365) * 12 
	}
}

*-------------------------------------------------------------------------------
*Generating variables listing number of observations per subject 
egen num_observations = rownonmiss(age*)

*-------------------------------------------------------------------------------
* Generate new variable recording subject age as integer values 
foreach var in age age_height{
	forval year = 2000/2014 {
		foreach month in jan_feb mar_apr may_jun jul_aug sep_oct nov_dec{
			generate rnd_`var'_`month'_`year' = round(`var'_`month'_`year',1)
			replace `var'_`month'_`year' = rnd_`var'_`month'_`year'
			drop rnd_`var'_`month'_`year'
		}
	}
}

*-------------------------------------------------------------------------------
* Generate weight variables by subject age  
forval year = 2000/2014 {
	foreach month in jan_feb mar_apr may_jun jul_aug sep_oct nov_dec{
	levelsof age_`month'_`year', local(age_`month'_`year')
	levelsof age_height_`month'_`year', local(age_height_`month'_`year')
	}
}

forval year = 2000/2014 {
	foreach month in jan_feb mar_apr may_jun jul_aug sep_oct nov_dec{
		foreach age in `age_height_`month'_`year'' {
				cap generate height_`age' = .
				cap replace height_`age' = height_`month'_`year' ///
				if rnd_age_`month'_`year' == `age'
			}
		}
	}
	
forval year = 2000/2014 {
	foreach month in jan_feb mar_apr may_jun jul_aug sep_oct nov_dec{
		foreach age in `age_`month'_`year'' {
			foreach measure in weight height zscore weight_level ///
			 zscore_height height_level {
				cap generate `measure'_`age' = .
				cap replace `measure'_`age' = `measure'_`month'_`year' ///
				if rnd_age_`month'_`year' == `age'
			}
		}
	}
}

*-------------------------------------------------------------------------------
*Encoding a numeric variable for the `weight_level' string variable 
forval year = 2001/2014 {
	foreach month in jan_feb mar_apr may_jun jul_aug sep_oct nov_dec {
	encode weight_level_`month'_`year', generate(weight_level_num_`month'_`year')
	drop pednut_`month'_`year'
	}
}
*-------------------------------------------------------------------------------
*dropping excessive variables
forval year = 2000/2014 {
	foreach month in jan_feb mar_apr may_jun jul_aug sep_oct nov_dec {
		foreach measure in weight zscore weight_level zscore_height ///
		height_level height  {
			drop `measure'_`month'_`year'
			}
		}
	}
*-------------------------------------------------------------------------------
*reformating HB and Anemia variables by subject age
set trace on 
foreach per in primer segundo{
	forval year = 2000/2014 {
		cap gen hb_`per'_age_`year' = .
		cap replace hb_`per'_age_`year' = hb_`per'_date_`year' - birth_date
		cap replace hb_`per'_age_`year' = (hb_`per'_age_`year'/365)*12
		cap replace hb_`per'_age_`year' = round(hb_`per'_age_`year',1)
		}
	}

foreach per in primer segundo {
	forval year = 2000/2014 {
		levelsof hb_`per'_age_`year', local(hb_`year'_age)
	}
}


set trace on
forval year = 2000/2014 {
	foreach per in primer segundo {
		foreach measure in hb anemia {
				foreach age of local `hb_age_`year'' {
			cap generate `measure'_`age' = .
			cap replace `measure'_`age' = `measure'_`per'_`year' ///
			if `age' == hb_`per'_age_`year'
			}
		}
	}
} 

forval year = 2000/2014 {
	foreach month in jan_feb mar_apr may_jun jul_aug sep_oct nov_dec{
	levelsof age_`month'_`year', local(age_`month'_`year')
	levelsof age_height_`month'_`year', local(age_height_`month'_`year')
	}
}

	
forval year = 2000/2014 {
	foreach age in `age_`month'_`year'' {
		foreach measure in hb anemia {
			cap generate `measure'_`age' = .
			cap replace `measure'_`age' = `measure'_`month'_`year' ///
			if rnd_age_`month'_`year' == `age'
			}
		}
	}




set trace off

// AZ comment: it might be convenient to label the variables (label variable...) in the loops you have above

*misstable summarize (peso*)
