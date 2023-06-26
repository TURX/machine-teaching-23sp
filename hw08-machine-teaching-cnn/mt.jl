using SHA
using Random
using Tidier
using CSV
using DataFrames

cd("/Users/turx/Projects/machine-teaching-23sp/hw08-machine-teaching-cnn")
include("plot.jl")
include("classifier.jl")
include("experiment.jl")
Random.seed!(sum(sha256("machine-teaching")))
cd("/Users/turx/Projects/machine-teaching-23sp/hw08-machine-teaching-cnn/hw5adata")
clean_plot_dir(pwd())
pool = CSV.read("hw5data.txt", delim=" ", header=[:x1, :x2, :y], DataFrame)
# plot_pool(pool, "hw5adata")
greedy_upper = 20  # n_star for greedy, threshold for the number of teaching examples
category_range = 0:1
greedy_results = @saved_run greedy_run() "greedy.csv"
@greedy_plot_all
readline()
