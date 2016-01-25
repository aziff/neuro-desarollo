# Convert .sav format to .dta
# Anna Ziff
# 1/21/16

library(foreign)

setwd("/Volumes/klmMexico/Neurodesarollo")

# Convert .sav to .dta taking in a string of the filename (with no extension)
sav_to_dta <- function(filename){
	sav_filename <- paste(filename,".sav", sep="")
	dta_filename <- paste(filename,".dta", sep="")
	
	data <- read.spss(sav_filename)
	
	# Check if .sav file exists
	if (file.exists(sav_filename) == TRUE) {
		
		# Make sure .dta file does not exist
		if (file.exists(dta_filename) == FALSE) {
			write.dta(data, dta_filename)
		}
		
		# Overwrite .dta file if it does exist
		else {
			file.remove(dta_filename)
			write.dta(data, dta_filename)
		}
		print(paste(sav_filename," : successfully converted"))
	}
	
	else {
		print(paste(sav_filename," :failed to be converted because it does not exist"))
	}	
}

files_to_convert <- c("MATRIZ_BIMESTRAL_UKA_2000-2014", "NEURO_LONGITUDINAL_29_06_2015")

convert <- lapply(files_to_convert, sav_to_dta)
