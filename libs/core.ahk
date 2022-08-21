#noEnv

global dup := getPreference("Controls", "DUp")
global dleft := getPreference("Controls", "DLeft")
global ddown := getPreference("Controls", "DDown")
global dright := getPreference("Controls", "DRight")
global triangle := getPreference("Controls", "Triangle")
global circle := getPreference("Controls", "Circle")
global cross := getPreference("Controls", "Cross")
global square := getPreference("Controls", "Square")

global currentEnemyColor := getPreference("Scans", "EnemyColor")
global currentFallbackCounter := 0
global currentFightX
global currentFightY
global currentFightColor
global currentFinishX
global currentFinishY
global currentFinishColor

prepareScanStateS1() {
  currentEnemyColor := getPreference("Scans", "EnemyColor")
  currentFallbackCounter := 0

  currentFightCoordinate := getPreference("Scans", "S1FightCoordinate")
  currentFightColor := getPreference("Scans", "S1FightColor")
  currentFinishCoordinate := getPreference("Scans", "S1FinishCoordinate")
  currentFinishColor := getPreference("Scans", "S1FinishColor")
  StringSplit, coordinate, currentFightCoordinate, `,
  currentFightX := coordinate1
  currentFightY := coordinate2
  StringSplit, coordinate, currentFinishCoordinate, `,
  currentFinishX := coordinate1
  currentFinishY := coordinate2
}

prepareScanStateS2() {
  currentEnemyColor := getPreference("Scans", "EnemyColor")
  currentFallbackCounter := 0

  currentFightCoordinate := getPreference("Scans", "S2FightCoordinate")
  currentFightColor := getPreference("Scans", "S2FightColor")
  currentFinishCoordinate := getPreference("Scans", "S2FinishCoordinate")
  currentFinishColor := getPreference("Scans", "S2FinishColor")
  StringSplit, coordinate, currentFightCoordinate, `,
  currentFightX := coordinate1
  currentFightY := coordinate2
  StringSplit, coordinate, currentFinishCoordinate, `,
  currentFinishX := coordinate1
  currentFinishY := coordinate2
}

isFightState() {
  PixelGetColor, color, currentFightX, currentFightY
  return color = currentFightColor
}

isFinishState() {
  PixelGetColor, color, currentFinishX, currentFinishY
  return color = currentFinishColor
}

isFallbackState() {
  currentFallbackCounter++
  if (currentFallbackCounter > 10) {
    currentFallbackCounter := 0
    return true
  }
  return false
}

doFight() {
  ; Select Free Will/Auto
  send {%dup% down}
  send {%dup% up}
  send {%cross% down}
  send {%cross% up}

  ; Wait for dialog animation and confirm
  sleep 100
  send {%cross% down}
  send {%cross% up}
}

doFinishS1() {
  ; No need for looping in S1 because money and item gained box is the same
  send {%cross% down}
  send {%cross% up}
}

doFinishS2() {
  ; Party members lv 1> exp gained 2> money gained
  loop 2 {
    send {%cross% down}
    send {%cross% up}
  }
  ; Money gained 1> item gained 2> give up on item (if full) 3> close
  loop 3 {
    sleep 100
    send {%cross% down}
    send {%cross% up}
  }
}

doFallbackS1() {
  send {%circle% down}
  send {%circle% up}
}

doFallbackS2() {
  send {%triangle% down}
  send {%triangle% up}
}

doMoveAround(direction1, direction2, duration) {
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
