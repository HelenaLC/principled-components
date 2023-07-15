# in the code below...
# sce = 'SingleCellExperiment'
# ids = character string; 'colData' column to use
# dr  = character string; 'reducedDim' to use
# nd  = scalar integer; number of dimensions to use

# principal component regression
.pcr <- \(sce, id, dr = "PCA", nd = 20) {
  y <- reducedDim(sce, dr)
  x <- sce[[id]]
  nd <- min(nd, ncol(y))
  r2 <- apply(y[, seq_len(nd)], 2, \(.) 
    summary(lm(. ~ x))$adj.r.squared)
  nd <- names(r2)
  nd <- factor(nd, nd)
  df <- data.frame(
    id, dr, nd, r2,
    row.names = NULL)
  pv <- attr(y, "percentVar")
  if (!is.null(pv)) {
    names(pv) <- colnames(y)
    df$pv <- pv[df$nd]
    df$r2pv <- with(df, r2*pv)
  } else df$pv <- df$r2pv <- NA
  return(df)
}

# convex hull areas
.cha <- \(sce, id, dr = "PCA", nd = 20) {
  xy <- reducedDim(sce, dr)
  nd <- min(nd, ncol(xy))
  xy <- xy[, seq_len(nd)]
  xy <- data.frame(xy)
  as <- by(xy, sce[[id]], \(xy) {
    # for each cluster...
    apply(xy[, -1], 2, \(.) {
      # get convex hull of PC1 vs. PCN
      xy <- cbind(xy[, 1], .)
      xy <- xy[chull(xy), ]
      # return its area scaled by 1/√n
      pg <- sp::Polygon(xy, TRUE)
      pg@area/sqrt(length(.))
      # TODO: need to figure out proper scaling here,
      # or an altogether simpler/better approach.
    })
  })
  as <- array2DF(as)
  names(as)[1] <- "group"
  df <- tidyr::pivot_longer(as, 
    cols = -group,
    names_to = "nd",
    values_to = "area")
  df <- cbind(dr, id, df)
  df$nd <- with(df, factor(nd, colnames(xy)))
  df$group <- factor(df$group, levels(factor(sce[[id]])))
  return(df)
}

# plot R2 from PCR with optional
# coloring & faceting (automated)
# x = dimensions; y = R2
.plot_r2 <- \(df) {
  id <- if (length(id <- unique(df$id)) > 1) id[1]
  dr <- if (length(dr <- unique(df$dr)) > 1) dr[1]
  ggplot(df, if (!length(id)) 
    aes(nd, r2, group = id) else 
    aes(nd, r2, col = id, group = id)) +
    (if (length(dr)) facet_wrap(~ dr)) +
    scale_y_continuous(limits = c(0, 1)) +
    geom_point() + geom_path(show.legend = FALSE) +
    guides(col = guide_legend(override.aes = list(size = 2))) +
    labs(x = NULL) + theme_bw() + theme(
      panel.grid.minor = element_blank(),
      legend.key.size = unit(0.5, "lines"),
      axis.text.x = element_text(angle = 45, hjust = 1))
}

# plot convex hull areas colored by group, and
# faceted by grouping variables (batch or cluster)
# x = dimensions; y = area
.plot_ch <- \(df, x = c("nd", "group"), ...) {
  x <- match.arg(x)
  z <- setdiff(c("nd", "group"), x)
  lapply(split(df, df$id), \(df) {
    ggplot(df, aes(.data[[x]], area, 
      col = .data[[z]], group = .data[[z]])) +
      (if (length(unique(df$dr)) > 1) facet_grid(~ dr)) +
      geom_path(show.legend = FALSE) +
      geom_point(show.legend = (z == "group")) + 
      labs(x = NULL, y = "convex hull area") +
      scale_y_continuous(limits = c(0, NA)) +
      guides(col = guide_legend(override.aes = list(size = 2))) +
      theme_bw() + theme(
        legend.justification = c(0, 0.5),
        panel.grid.minor = element_blank(),
        legend.key.size = unit(0.5, "lines"),
        axis.text.x = element_text(angle = 45, hjust = 1))
  }) |> patchwork::wrap_plots(...)
}

# prettified dimension reduction plot
# colored & split according to 'id'
.plot_dr <- \(sce, 
  dr = "PCA", nd = c(1, 2),
  id = "cluster", split = TRUE) {
  plotReducedDim(sce, 
    dimred = dr, ncomponents = nd, 
    point_size = 0.1, color_by = id) +
    (if (split && !is.null(id)) 
    facet_wrap(~ colour_by)) + 
    geom_vline(xintercept = 0) + 
    geom_hline(yintercept = 0) +
    guides(col = guide_legend(
      override.aes = list(alpha = 1, size = 2))) +
    theme_bw() + theme(
      panel.grid.minor = element_blank(),
      legend.key.size = unit(0.5, "lines"),
      axis.text.x = element_text(angle = 45, hjust = 1))
}