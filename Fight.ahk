; Run around to fight encountered enemies. There are 2 modes of this script.
;
; `All` mode will fight any enemies and is intended to leveling.
;
; `Targeted` mode will only fight enemies with registered coordinates, which is helpful when looting certain items.
; To use this mode, use `Window Spy` to the coordinate of white pixel in enemy name.
; The coordinates registered for that specific enemy must not overlap with other enemies that can be found in that area.
; For example, if the target enemy is `WildBoar` and `Wolf` is also found in the area,
; the selected coordinate should be `Boar` since `Wild` may overlap with `Wolf`.
;
; Game     : S1 & S2
; Location : Any enemy-spawn area
; Speed    : >300 FPS

Menu, Tray, Icon, res/icon_s2_off.ico
MsgBox,, % "Fight (S1 & S2)"
  , % "Controls:`n"
    . "```t`tToggle Suikoden 1 or 2.`n"
    . "-`t`tToggle fight all or targeted enemies.`n"
    . "=`t`tChange enemy coordinates for targeted enemies.`n"
    . "+`t`tTest enemy coordinates.`n"
    . "Backspace`tToggle on/off."

#noEnv
#include lib/commons.ahk
#maxThreadsPerHotkey 2
#singleInstance force

-::
  toggleModePreference("Fight", "Targeted", "Targeted enemies.", "All enemies.")
  return

=::
  enemyCoordinates := getPreference("Fight", "EnemyCoordinates")
  InputBox, input, Enter Enemy Coordinates, Coordinates are comma-separated. (x`,y)`nSupports multiple coordinates by separating them with space. (x1`,y1 x2`,y2),,,,,,,, %enemyCoordinates%
  if (not errorLevel) {
    setPreference("Fight", "EnemyCoordinates", input)
  }
  return

+::
  enemyCoordinates := getPreference("Fight", "EnemyCoordinates")
  StringSplit, coordinates, enemyCoordinates, %A_Space%
  message := "Enemy colors:`n"
  loop %coordinates0% {
    StringSplit, coordinate, coordinates%A_Index%, `,
    if (isEnemyFound(coordinate1, coordinate2)) {
      found := "found.`n"
    } else {
      found := "not found.`n"
    }
    message = %message%%coordinate1%`,%coordinate2% is %found%
  }
  msgBox %message%
  return

Backspace::
  toggle := !toggle
  if (toggle) {
    Menu, Tray, Icon, res/icon_s2_on.ico
    initialize()
    targeted := getPreference("Fight", "Targeted")
    if (targeted) {
      enemyCoordinates := getPreference("Fight", "EnemyCoordinates")
      StringSplit, coordinates, enemyCoordinates, %A_Space%
    }
  }
  loop {
    if (not toggle) {
      Menu, Tray, Icon, res/icon_s2_off.ico
      break
    }

    if (isFightState()) {
      if (not targeted) {
        doFight()
      } else {
        loop %coordinates0% {
          StringSplit, coordinate, coordinates%A_Index%, `,
          if (isEnemyFound(coordinate1, coordinate2)) {
            doFight()
            break
          }
        }
        ; If not found, escape fight.
        send {%ddown% down}
        send {%ddown% up}
        send {%cross% down}
        send {%cross% up}
        ; Wait for dialog animation and close.
        sleep 100
        send {%cross% down}
        send {%cross% up}
      }
    } else if (isFinishState()) {
      doFinish()
    } else if (isFallbackState()) {
      doFallback()
    } else {
      doMoveAround(100)
    }
  }
  return

isEnemyFound(colorX, colorY) {
  PixelGetColor, color, colorX, colorY
  return color = currentEnemyColor
}
