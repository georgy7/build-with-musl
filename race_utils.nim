var line* = "-------------------"

proc workerCode*(name: string) =
  for i in 0 .. 10:
    echo name, ": ", i
