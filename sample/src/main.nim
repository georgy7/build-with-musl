## Author: Erik Johansson Andersson
## This file is in the public domain
## See COPYING.txt in project root for details

import portaudio as PA

type
  TPhase = tuple[left, right: float32]

var streamCallback = proc(
    inBuf, outBuf: pointer,
    framesPerBuf: culong,
    timeInfo: ptr TStreamCallbackTimeInfo,
    statusFlags: TStreamCallbackFlags,
    userData: pointer): cint {.cdecl.} =
  var
    outBuf = cast[ptr array[0xffffffff, TPhase]](outBuf)
    phase = cast[ptr TPhase](userData)
  for i in 0.. <framesPerBuf.int:
    outBuf[i] = phase[]

    # Use a different pitch for each channel.
    phase.left += 0.01
    phase.right += 0.03

    if phase.left >= 1:
      phase.left = -1

    if phase.right >= 1:
      phase.right = -1

  # Lower the amplitude (volume).
  for i in 0.. <framesPerBuf.int:
    outBuf[i].left *= 0.1
    outBuf[i].right *= 0.1

  scrContinue.cint

proc check(err: TError|TErrorCode) =
  if cast[TErrorCode](err) != PA.NoError:
    raise newException(E_Base, $PA.GetErrorText(err))


var
  phase = (left: 0.cfloat, right: 0.cfloat)
  stream: PStream

check(PA.Initialize())
check(PA.OpenDefaultStream(cast[PStream](stream.addr),
                           numInputChannels = 0,
                           numOutputChannels = 2,
                           sampleFormat = sfFloat32,
                           sampleRate = 44_100,
                           framesPerBuffer = 256,
                           streamCallback = streamCallback,
                           userData = cast[pointer](phase.addr)))
check(PA.StartStream(stream))
PA.Sleep(2000)
check(PA.StopStream(stream))
check(PA.CloseStream(stream))
check(PA.Terminate())
