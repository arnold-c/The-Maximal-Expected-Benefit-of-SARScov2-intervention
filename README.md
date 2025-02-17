# The Maximal Expected Benefit of SARS-CoV-2 Intervention
This repository reproduces the simulation results to accompany the paper "The Maximal Expected Benefit of SARS-CoV-2 Interventions Among University Students: A Simulation Study Using Latent Class Analysis".
The initial LCA fitting is no included as it relies on personally-identifiable data, but the simulation code & results are included.

To run:

- Ensure you have Julia 1.11.3 installed (we would recommend installing using `juliaup`).
- Enter the Julia REPL in the project directory, enter the `Pkg` REPL using the `]` command before typing `activate .`

- Still in the `Pkg` REPL, type the following commands:
    - `dev Data4ActionUtils`
    - `instantiate` (to download the necessary packages)
- Type backspace to re-enter the standard Julia REPL
- Run the command `include("manuscripts/lca/scripts/lca-plots.jl")`

To create the manuscript file, ensure you have Typst installed locally and then run `typst compile manuscripts/lca/combined-manuscript.typ` to compile the manuscript and supplemental appendix.
