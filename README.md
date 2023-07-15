# Notes

- Principal Component regression (henceforth abbreviated with "pcr") has been
proposed in [Büttner et al., 2019](http://dx.doi.org/10.1038/s41592-018-0254-1)
to assess batch correction.

- Here, pcr is performed against batches only, and scores are aggregated across
PCs to assess the amount of variability (overall) that is attributable to batch.

- Here, we aim to consider pcr against both batch and cluster, and develop an
approach (e.g., metrics, diagnostic plots) in order to assess clustering, and
potentially identify subpopulations that represent distinct functional states
(that are biologically meaningful and may better be treated as distinct), or
outliers (that should be removed).