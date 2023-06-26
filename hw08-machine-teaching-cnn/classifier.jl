using DataFrames
using Flux

# Implement the NN classifier for arbitrary number of dimensions
# train_x: training data matrix, each row is a data point
# train_y: training label vector
# test_x: test data matrix, each row is a data point
# test_y: test label vector
# k: number of nearest neighbors
# return: predicted labels y-hat for test_x, cross entropy loss, and accuracy
function nn_classifier(train_x, train_y, test_x, test_y, category_range)
  x = train_x
  n_dim = first(size(x))
  y = Flux.onehotbatch(train_y, category_range)
  model = Flux.Chain(
    Dense(n_dim, 32, relu),
    Dense(32, 16, relu),
    Dense(16, last(category_range) - first(category_range) + 1),
    softmax
  )
  loss(x, y) = Flux.crossentropy(model(x), y)
  opt = ADAM()
  for _ in 1:100
    Flux.train!(loss, Flux.params(model), [(x, y)], opt)
  end
  y_hat = Flux.onecold(model(test_x)) .- 1 .+ first(category_range)
  if test_y !== nothing
    l = loss(test_x, Flux.onehotbatch(test_y, category_range))
    acc = sum(y_hat .== test_y) / length(test_y)
  else
    l = nothing
    acc = nothing
  end
  return y_hat, l, acc
end
