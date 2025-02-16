using DrWatson

funsdir(args...) = projectdir("funs", args...)
figsdir(args...) = projectdir("figs", args...)
analysisdir(args...) = projectdir("analysis", args...)
lcadir(args...) = analysisdir("latent-class", args...)
