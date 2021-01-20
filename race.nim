proc firstWorker() =
  for i in 0 .. 10:
    echo "first: ", i

proc secondWorker() =
  for i in 0 .. 10:
      echo "second: ", i

var workers: array[2, Thread[void]]

createThread(workers[0], firstWorker)
createThread(workers[1], secondWorker)

joinThreads(workers)
