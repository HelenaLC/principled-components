site is deployed at [https://helenalc.github.io/principled-components](https://helenalc.github.io/principled-components)

# Food for thought

- Principal Component regression (henceforth abbreviated with "pcr") has been
proposed in [Büttner et al., 2019](http://doi.org/10.1038/s41592-018-0254-1)
to assess batch correction.  

- Here, pcr is performed against batches only, and scores are aggregated across
PCs to assess the amount of variability (overall) that is attributable to batch.

- [Lütge et al.](https://doi.org/10.26508/lsa.202001004) evaluates
metrics for batch effect quantification, and also includes pcr.

- Again, pcr is performed against batch only; it comes out as being less
sensitive (i.e., only strong effects are detected), but performs well overall.
Should be fine, since we're not aggregating across PCs, but are interested
in "subtleties" (e.g., looking at genes/clusters vs. overall variability).

- Here, we aim to consider pcr against both batch and cluster, and develop an
approach (e.g., metrics, diagnostic plots) in order to assess clustering, and
potentially identify subpopulations that represent distinct functional states
(that are biologically meaningful and may better be treated as distinct), or
outliers (that should be removed).