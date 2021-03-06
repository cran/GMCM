vector2theta <- function(par, d, m) {
  # Extracting pie
  pie <- inv.logit(par[1:m])
  names(pie) <- paste0("pie", 1:m)
  par <- par[-(1:m)]  # Removing the pies from par

  # Extracting mus
  mu <- lapply(1:(m-1), function(i) unname(par[1:d + d*(i-1)]))
  mu <- c(list(rep(0, d)), mu)
  par <- par[-(1:((m-1)*d))]  # Removing the mus from par

  # Extracting sigmas
  sigma <- vector("list", m)
  for (i in 1:m) {
    diag <- i != 1 # Indicator for anchor component
    count <- sum(upper.tri(diag(d), diag = diag))

    tmp.U <- matrix(0, d, d)
    tmp.U[upper.tri(tmp.U, diag = diag)] <- par[1:count]

    if (!diag) {
      diag(tmp.U) <- sqrt(1 - colSums(tmp.U^2))
    } else {
      diag(tmp.U) <- exp(diag(tmp.U))  # Transform back
    }

    tmp.mat <- t(tmp.U) %*% tmp.U

    sigma[[i]] <- tmp.mat
    par <- par[-(1:count)]
  }
  names(mu) <- names(sigma) <- paste("comp", 1:m, sep = "")
  return(structure(list(m = m, d = d, pie = pie, mu = mu, sigma = sigma),
                   class="theta"))
}
