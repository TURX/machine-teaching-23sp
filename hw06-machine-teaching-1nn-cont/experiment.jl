using CSV
using DataFrames
using Combinatorics
using JSONTables
using Random
using ProgressMeter

# Time the execution of an expression
# return: tuple of (time in seconds, return value of f)
macro timed_run(expr)
  return quote
      local t0 = time()
      local ret = $(esc(expr))
      local t1 = time()
      ((t1 - t0), ret)
  end
end

# Run the function and save or load the resulting DataFrame from a csv file
# expr: expression to be run
# file: file to save or load the result
# return: DataFrame
macro saved_run(expr, file)
return quote
  if isfile($file)
    CSV.read($file, DataFrame)
  else
    local df = $expr
    CSV.write($file, df)
    df
  end
end
end

function enum_timed(m)
  best_d = Inf
  best_subset = nothing
  index_subsets = with_replacement_combinations(1:size(Z, 1), m)
  counter = 0
  @showprogress 1 "enum subset index (subset size $m): " for index_subset in index_subsets
    subset = pool[index_subset, :]
    counter += 1
    g = (x1p, x2p) -> knn_classifier_single(subset.x1, subset.x2, subset.y, x1p, x2p, k)
    d = dist(Z, g, loss_bin)
    if d < best_d
      best_d = d
      best_subset = subset
    end
  end
  return (counter, best_d, best_subset)
end

# Implementation of the enumeration algorithm
# Reporting:
# 1. the number of teaching sets of that size that you have to search through;
# 2. number of seconds it takes for that size;
# 3. d(kNN(D), g) of the best teaching set of that size;
# 4. plot the best teaching set D-hat in relation to P (i.e. plot both, but use different symbols for D-hat)
function enum_run()
  results = DataFrame(
    subset_sz = Int64[],
    subset_n = Int64[],
    time = Float64[],
    d = Float64[],
    subset = String[],
  )
  for m in 1:enum_upper
    (t, r) = @timed_run enum_timed(m)
    rs = objecttable(r[3])
    push!(results, (m, r[1], t, r[2], rs))
  end
  return results
end

function greedy_timed(prev_D)
  best_d = Inf
  idx_l = []
  for i in 1:size(pool, 1)
    D = vcat(prev_D, i)
    subset = pool[D, :]
    g = (x1p, x2p) -> knn_classifier_single(subset.x1, subset.x2, subset.y, x1p, x2p, k)
    d = dist(Z, g, loss_bin)
    if d < best_d
      best_d = d
      idx_l = [i]
    elseif d == best_d
      push!(idx_l, i)
    end
  end
  idx_to_add = rand(idx_l)
  return (size(pool, 1), best_d, idx_to_add)
end

# Implementation of the greedy algorithm
# Reporting:
# 1. the number of teaching sets of that size that you have to search through;
# 2. number of seconds it takes for that size;
# 3. d(kNN(D), g) of the best teaching set of that size;
# 4. plot one figure for the last teaching set D-hat with size n* in relation to P
function greedy_run()
  results = DataFrame(
    subset_sz = Int64[],
    subset_n = Int64[],
    time = Float64[],
    d = Float64[],
    index = Int64[],
  )
  prev_D = []
  for m in 1:greedy_upper
    if m > 1
      push!(prev_D, results.index[m - 1])
    end
    (t, r) = @timed_run greedy_timed(prev_D)
    push!(results, (m, r[1], t, r[2], r[3]))
  end
  return results
end

macro enum_plot_all()
  return quote
    for m in 1:enum_upper
      p = enum_plot(m)
      plot_save(p, "enum_result_m$m")
      display(p)
    end
    p = plot_loss(enum_results, "Enumeration: Loss vs Iteration: m = $enum_upper")
    plot_save(p, "enum_loss_m$enum_upper")
    display(p)
  end
end

macro greedy_plot_all()
  return quote
    selected_pool = pool[greedy_results.index, :]
    last_d = greedy_results.d[greedy_upper]

    p = plot_subset(selected_pool, "Greedy: Last Teaching Set vs Pool: m = $greedy_upper, d = $last_d", "greedy")
    plot_save(p, "greedy_result_m$greedy_upper")
    display(p)
    p = plot_loss(greedy_results, "Greedy: Loss vs Iteration")
    plot_save(p, "greedy_loss_m$greedy_upper")
    display(p)
  end
end

# generate a random pool of size 100 by two centers of exponential distribution
function generate_pool()
  pool_half_size = 50
  x1_first_half = randexp(pool_half_size)
  x2_first_half = randexp(pool_half_size)
  y_first_half = ones(Int64, pool_half_size)
  x1_second_half = 4 .- randexp(pool_half_size)
  x2_second_half = 4 .- randexp(pool_half_size)
  y_second_half = ones(Int64, pool_half_size) * 2
  pool = DataFrame(
    x1 = vcat(x1_first_half, x1_second_half),
    x2 = vcat(x2_first_half, x2_second_half),
    y = vcat(y_first_half, y_second_half),
  )
  return pool
end
