using JSONTables
using PlotlyJS
using IterTools

# remove all *.svg and *.html files in the current directory
function clean_plot_dir(dir)
  for file in readdir(dir)
    if endswith(file, ".svg") || endswith(file, ".html")
      rm(joinpath(dir, file))
    end
  end
end

function plot_save(p, name)
  savefig(p, name * ".html")
  savefig(p, name * ".svg")
end

function plot_pool(pool, name)
  p = plot(
    scatter(pool, x=:x1, y=:x2, name="pool", mode="markers", marker=attr(color=:y, colorscale="Greens"), hovertemplate="(%{x}, %{y})<br>category: %{marker.color}"),
    Layout(
      width=800,
      height=600,
      yaxis=attr(scaleanchor="x", scaleratio=1),
      title="Pool: " * string(size(pool, 1)) * " data points in " * name,
    )
  )
  plot_save(p, "pool")
  display(p)
end

function plot_subset(subset, title, subset_name)
  subset.id = 1:size(subset, 1)
  subset.size = 10 .* (log.(subset.id) .+ 1)
  pool_xmin = minimum(pool.x1)
  pool_xmax = maximum(pool.x1)
  pool_ymin = minimum(pool.x2)
  pool_ymax = maximum(pool.x2)
  pool_x1 = collect(range(pool_xmin, pool_xmax, length=100))
  pool_x2 = collect(range(pool_ymin, pool_ymax, length=100))
  plot(
    [
      scatter(pool, x=:x1, y=:x2, mode="markers", name="pool", marker=attr(color=:y, colorscale="Greens"), hovertemplate="(%{x}, %{y})<br>category: %{marker.color}"),
      scatter(
        subset, x=:x1, y=:x2, marker=attr(size=:size, sizeref=1, color=:y, colorscale="Reds", opacity=0.8), mode="markers+text", name=subset_name,
        text=:id,
        hovertemplate="(%{x}, %{y})<br>category: %{marker.color}<br>order in sequence: %{text}",
      ),
      trace_decision_boundary(subset, pool_x1, pool_x2),
    ],
    Layout(
      width=800,
      height=600,
      yaxis=attr(scaleanchor="x", scaleratio=1),
      title=title,
    )
  )
end

function enum_plot(m)
  best_subset = DataFrame(jsontable(enum_results.subset[m]))
  best_d = enum_results.d[m]
  return plot_subset(best_subset, "Enumeration: Best Teaching Set vs Pool: m = $m, d = $best_d", "best subset")
end

function plot_loss(frame, title)
  frame.id = 1:size(frame, 1)
  plot(frame, x=:id, y=:d, mode="lines+markers", name="loss",
    labels=Dict(
      :id => "Iteration",
      :d => "Loss",
    ),
    hovertemplate="Iteration: %{x}<br>Loss: %{y}",
    Layout(
      width=800,
      height=600,
      title=title,
    )
  )
end

function generate_decision_boundary(train_pool, x1, x2)
  # generate grid for test_x matrix, each row is a data point
  test_x = collect(product(x1, x2))
  test_x = reshape(test_x, length(x1) * length(x2))
  test_x = hcat(first.(test_x), last.(test_x))
  # generate train_x and train_y from pool, which are one matrix and one vector
  train_x = [train_pool[:, :x1] train_pool[:, :x2]]
  train_y = train_pool[:, :y]
  # generate test_y from kNN
  test_y = knn_classifier(train_x, train_y, test_x, k)
  # generate decision boundary pool
  db_pool = DataFrame(x1=test_x[:, 1], x2=test_x[:, 2], y=test_y)
  return db_pool
end

function trace_decision_boundary(train_pool, x1, x2)
  db_pool = generate_decision_boundary(train_pool, x1, x2)
  return scatter(db_pool, x=:x1, y=:x2, mode="markers", name="decision boundary", marker=attr(color=:y, colorscale="Greens"), hoverinfo="skip", visible="legendonly", legendrank=2000, opacity=0.5)
end
