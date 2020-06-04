Chile_VMS <- read.csv ("Chile_VMS.csv", header = TRUE)
RPI_PDF <- read.csv ("RPI.csv", header = TRUE)

tmp <- RPI_PDF$X...RPI %in% Chile_VMS$RPI
RPI_PDF$VMS_PRESENT <- tmp