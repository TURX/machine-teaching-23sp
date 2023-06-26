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

function plot_subset(subset, d, acc, title, subset_name)
  subset_sz = size(subset, 1)
  subset.id = 1:subset_sz
  subset.size = 10 .* (log.(subset.id) .+ 1)
  pool_xmin = minimum(pool.x1)
  pool_xmax = maximum(pool.x1)
  pool_ymin = minimum(pool.x2)
  pool_ymax = maximum(pool.x2)
  pool_x1 = collect(range(pool_xmin, pool_xmax, length=100))
  pool_x2 = collect(range(pool_ymin, pool_ymax, length=100))
  traces = [
    scatter(pool, x=:x1, y=:x2, mode="markers", name="pool", marker=attr(color=:y, colorscale="Greens"), hovertemplate="(%{x}, %{y})<br>category: %{marker.color}")
  ]
  subset.d = d[1:subset_sz]
  subset.acc = acc[1:subset_sz]
  for i in 1:subset_sz
    push!(traces, scatter(
      subset[1:i, :], x=:x1, y=:x2, marker=attr(size=:size, sizeref=1, color=:y, colorscale="Reds", opacity=0.8), mode="markers+text", name=subset_name,
      text=:id,
      hovertemplate="(%{x}, %{y})<br>category: %{marker.color}<br>order in sequence: %{text}",
      visible=(i == subset_sz),
      showlegend=(i == subset_sz),
    ))
    push!(traces, trace_decision_boundary(subset[1:i, :], pool_x1, pool_x2, (i == subset_sz)))
    # g = (x1p, x2p) -> knn_classifier_single(subset[1:i, :].x1, subset[1:i, :].x2, subset[1:i, :].y, x1p, x2p, k)
    # subset.d[i] = dist(Z, g, loss_bin)
  end
  plot(
    traces,
    Layout(
      width=800,
      height=600,
      yaxis=attr(scaleanchor="x", scaleratio=1),
      title = title * "<br>Iteration: $(subset_sz); Loss: $(subset.d[subset_sz]); Accuracy: $(subset.acc[subset_sz])",
      sliders=[
        attr(
          steps=[
            attr(
              label=i,
              method="update",
              args=[
                attr(
                  visible=[true; fill(false, 2 * (i - 1)); fill(true, 2); fill(false, 2 * (subset_sz - i))],
                  showlegend=[true; fill(false, 2 * (i - 1)); fill(true, 2); fill(false, 2 * (subset_sz - i))],
                ),
                attr(
                  title = title * "<br>Iteration: $i; Loss: $(subset.d[i]); Accuracy: $(subset.acc[i])",
                )
              ],
            )
            for i in 1:subset_sz
          ],
          active=subset_sz - 1,
          currentvalue=attr(
            label=subset_sz,
            prefix="Iteration: ",
            visible=[true; fill(false, 2 * (subset_sz - 1)); fill(true, 2)],
            showlegend=[true; fill(false, 2 * (subset_sz - 1)); fill(true, 2)],
          ),
        )
      ]
    )
  )
end

function plot_loss(frame, title)
  frame.id = 1:size(frame, 1)
  p1 = plot(frame, x=:id, y=:d, mode="lines+markers", name="loss",
    labels=Dict(
      :id => "Iteration",
      :d => "Loss",
    ),
    hovertemplate="Iteration: %{x}<br>Loss: %{y}",
    Layout(
      width=400,
      height=600
    )
  )
  p2 = plot(frame, x=:id, y=:acc, mode="lines+markers", name="accuracy",
    labels=Dict(
      :id => "Iteration",
      :acc => "Accuracy",
    ),
    hovertemplate="Iteration: %{x}<br>Accuracy: %{y}",
    Layout(
      width=400,
      height=600
    )
  )
  p = [p1 p2]
  relayout!(p, title_text=title)
  return p
end

function generate_decision_boundary(train_pool, x1, x2)
  # generate grid for test_x matrix, each row is a data point
  test_x = collect(product(x1, x2))
  test_x = reshape(test_x, length(x1) * length(x2))
  test_x = hcat(first.(test_x), last.(test_x))
  test_x = transpose(test_x)
  # generate train_x and train_y from pool, which are one matrix and one vector
  train_x = transpose([train_pool[:, :x1] train_pool[:, :x2]])
  train_y = train_pool[:, :y] |> Vector
  # generate y_hat from kNN
  y_hat, _, _ = nn_classifier(train_x, train_y, test_x, nothing, category_range)
  # generate decision boundary pool
  test_x = transpose(test_x)
  db_pool = DataFrame(x1=test_x[:, 1], x2=test_x[:, 2], y=y_hat)
  return db_pool
end

function trace_decision_boundary(train_pool, x1, x2, visible)
  db_pool = generate_decision_boundary(train_pool, x1, x2)
  return scatter(db_pool, x=:x1, y=:x2, mode="markers", name="decision boundary", marker=attr(color=:y, colorscale="Greens", symbol="square"), hoverinfo="skip", visible=visible, showlegend=visible, legendrank=2000, opacity=0.5)
end
