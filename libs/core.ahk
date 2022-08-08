; Moves selection 1> auto 2> confirm.
global S1_FIGHT_CROSSTIMES=2
; S2 runs on slower fps, so add 2 extra times to ensure the script does not stop in confirmation
global S2_FIGHT_CROSSTIMES=4

global dup := getPreference("Controls", "DUp")
global dleft := getPreference("Controls", "DLeft")
global ddown := getPreference("Controls", "DDown")
global dright := getPreference("Controls", "DRight")
global triangle := getPreference("Controls", "Triangle")
global circle := getPreference("Controls", "Circle")
global cross := getPreference("Controls", "Cross")
global square := getPreference("Controls", "Square")

global currentEnemyColor
global currentFightX
global currentFightY
global currentFightColor
global currentFightCrossTimes
global currentFinishX
global currentFinishY
global currentFinishColor

; Call this once before calling any other scan functions.
prepareScan() {
  s2 := getPreference("General", "S2")
  currentEnemyColor := getPreference("Scans", "EnemyColor")
  if (s2) {
    currentFightCoordinate := getPreference("Scans", "S2FightCoordinate")
    currentFightColor := getPreference("Scans", "S2FightColor")
    currentFinishCoordinate := getPreference("Scans", "S2FinishCoordinate")
    currentFinishColor := getPreference("Scans", "S2FinishColor")
    currentFightCrossTimes := S2_FIGHT_CROSSTIMES
  } else {
    currentFightCoordinate := getPreference("Scans", "S1FightCoordinate")
    currentFightColor := getPreference("Scans", "S1FightColor")
    currentFinishCoordinate := getPreference("Scans", "S1FinishCoordinate")
    currentFinishColor := getPreference("Scans", "S1FinishColor")
    currentFightCrossTimes := S1_FIGHT_CROSSTIMES
  }
  StringSplit, coordinate, currentFightCoordinate, `,
  currentFightX := coordinate1
  currentFightY := coordinate2
  StringSplit, coordinate, currentFinishCoordinate, `,
  currentFinishX := coordinate1
  currentFinishY := coordinate2
}

scanFight() {
  PixelGetColor, color, currentFightX, currentFightY
  return color = currentFightColor
}

scanFinish() {
  PixelGetColor, color, currentFinishX, currentFinishY
  return color = currentFinishColor
}

fight() {
  send {%dup% down}
  send {%dup% up}
  loop %currentFightCrossTimes% {
    send {%cross% down}
    send {%cross% up}
  }
}

finish() {
  send {%cross% down}
  send {%cross% up}
}

moveTwice(direction1, direction2, duration) {
  send {%circle% down}

  send {%direction1% down}
  sleep duration
  send {%direction1% up}

  send {%direction2% down}
  sleep duration
  send {%direction2% up}

  send {%circle% up}
}

getPreference(section, key) {
  IniRead, value, preferences.ini, %section%, %key%
  return value
}

setPreference(section, key, value) {
  IniWrite, %value%, preferences.ini, %section%, %key%
}

toggleModePreference(section, key, modeOnDesc, modeOffDesc) {
  value := getPreference(section, key)
  setPreference(section, key, !value)
  if (!value) {
    msgBox Mode changed:`n%modeOnDesc%
  } else {
    msgBox Mode changed:`n%modeOffDesc%
  }
}