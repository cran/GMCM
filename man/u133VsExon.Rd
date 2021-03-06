% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/GMCM-package.R
\docType{data}
\name{u133VsExon}
\alias{u133VsExon}
\title{Reproducibility between U133 plus 2 and Exon microarrays}
\format{The format of the \code{data.frame} is:

  \code{'data.frame':  19577 obs. of  2 variables:}\cr
  \code{$ u133: num  0.17561 0.00178 0.005371 0.000669 0.655261 ...}\cr
  \code{$ exon: num  1.07e-01 6.74e-10 1.51e-03 6.76e-05 3.36e-01 ...}\cr}
\description{
This dataset contains a \code{data.frame} of unadjusted P-values for
differential expression between germinal center cells and other B-cells
within tonsils for two different experiments. The experiments differ
primarily in the microarray platform used. The first column corresponds the
evidence from the Affymetrix GeneChip Human Genome U133 Plus 2.0 Array.
The second column corresponds to the Affymetrix GeneChip Human Exon 1.0 ST
Array.
}
\details{
Further details can be found in Bergkvist et al. (2014) and
  Rasmussen and Bilgrau et al. (2014).
}
\examples{
data(u133VsExon)
str(u133VsExon)

# Plot P-values
plot(u133VsExon, cex = 0.5)

# Plot ranked and scaled P-values
plot(Uhat(1-u133VsExon), cex = 0.5)
}
\references{
Bergkvist, Kim Steve, Mette Nyegaard, Martin Boegsted, Alexander Schmitz,
Julie Stoeve Boedker, Simon Mylius Rasmussen, Martin Perez-Andres et al.
(2014). "Validation and Implementation of a Method for Microarray Gene
Expression Profiling of Minor B-Cell Subpopulations in Man".
BMC immunology, 15(1), 3.

Rasmussen SM, Bilgrau AE, Schmitz A, Falgreen S, Bergkvist KS, Tramm AM,
Baech J, Jacobsen CL, Gaihede M, Kjeldsen MK, Boedker JS, Dybkaer K,
Boegsted M, Johnsen HE (2015). "Stable Phenotype Of B-Cell Subsets Following
Cryopreservation and Thawing of Normal Human Lymphocytes Stored in a Tissue
Biobank." Cytometry Part B: Clinical Cytometry, 88(1), 40-49.
}
\author{
Anders Ellern Bilgrau <anders.ellern.bilgrau@gmail.com>
}
\keyword{data}
