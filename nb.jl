using Conda
Conda.pip_interop(true)
Conda.pip("install", "webio_jupyter_extension")

using IJulia
notebook(dir=pwd())
