import race_utils


when isMainModule:

  echo line

  var workers: array[2, Thread[string]]

  createThread(workers[0], workerCode, "First")
  createThread(workers[1], workerCode, "Second")

  joinThreads(workers)

  echo line
