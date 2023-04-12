using DataFrames
using StatsBase

# Implement the kNN classifier for arbitrary k and arbitrary number of dimensions
# train_x: training data matrix, each row is a data point
# train_y: training label vector
# test_x: test data matrix, each row is a data point
# k: number of nearest neighbors
# return: predicted labels y-hat for test_x
function knn_classifier(train_x, train_y, test_x, k)
  test_y = zeros(Float64, size(test_x, 1))
  for i in 1:size(test_x, 1)
    dist = sum((train_x .- test_x[i, :]') .^ 2, dims=2)
    knn = sortperm(dist[:])[1:k]
    test_y[i] = mode(train_y[knn])
  end
  return test_y
end

# Predict the label of a single point using kNN classifier
# x1: vector of first dimension of data points
# x2: vector of second dimension of data points
# y: vector of labels
# x1p: position of the first dimension of the point to be labeled
# x2p: position of the second dimension of the point to be labeled
# k: number of nearest neighbors
# return: predicted label y-hat for the point (x1p, x2p)
function knn_classifier_single(x1, x2, y, x1p, x2p, k)
  train_x = vcat(x1', x2')'
  train_y = y
  test_x = [x1p x2p]
  return knn_classifier(train_x, train_y, test_x, k)[1]
end

# Binary loss function
# y: vector of true labels
# yp: vector of predicted labels
# return: binary loss
function loss_bin(y, yp)
  return sum(y .!= yp) / length(y)
end

# Metric between functions f and g defined by equation (3)
# Z: data frame (x1p, x2p, yp), x1p and x2p are positions of the points to be labeled, yp is the expected label
# f: function f, the predictor with arguments x1p, x2p, returning yp (i.e., y-hat)
# l: loss function, taking two vectors of labels and returning a scalar of total loss
function dist(Z, f, l)
  pred = f.(Z.x1p, Z.x2p)
  d = l(Z.yp, pred)
  return d
end
