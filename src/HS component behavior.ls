-- Cast Internal BehaviorScript HS component behavior.ls

property spriteNum, hsGame, hsScoreLoc, hsSave, hsTime, hsReverse, hsMulti, hsSuffix

on isOKToAttach ascript, aSpriteType, aSpriteNum
  case aSpriteType of
    #graphic:
      case sprite(aSpriteNum).member.type of
        #flash:
          return 1
      end case
  end case
end

on beginSprite me
  sprite(spriteNum).goToFrame(2)
  sprite(spriteNum).width = (the stage).rect[3] - (the stage).rect[1]
  sprite(spriteNum).height = (the stage).rect[4] - (the stage).rect[2]
  sprite(spriteNum).locH = sprite(spriteNum).width / 2
  sprite(spriteNum).locV = sprite(spriteNum).height / 2 - 20
  sprite(spriteNum).ink = 36
  if hsMulti then
    gname = hsGame & string(value(hsSuffix))
  else
    gname = hsGame
  end if
  sprite(spriteNum).setVariable("playerScore", string(value(hsScoreLoc)))
  sprite(spriteNum).setVariable("saveScore", string(hsSave))
  sprite(spriteNum).setVariable("gameName", gname)
  sprite(spriteNum).setVariable("scoreIsTime", string(hsTime))
  sprite(spriteNum).setVariable("scoreReversed", string(hsReverse))
  sprite(spriteNum).setVariable("isShockwave", string(1))
  sprite(spriteNum).cursor = 280
  put "Data sent to flash HS component updated"
end

on mouseUp me
  if not (the moviePath contains "miniclip.com") then
    gotoNetPage("http://www.miniclip.com/" & hsGame & ".htm", "_new")
  end if
end

on getPropertyDescriptionList me
  description = [:]
  description.addProp(#hsGame, [#comment: "Game name?", #format: #string, #default: "?"])
  description.addProp(#hsMulti, [#comment: "Game uses multiple highScores?", #format: #boolean, #default: 0])
  description.addProp(#hsSuffix, [#comment: "Name of variable containing suffix? (for multiple highscores)", #format: #string, #default: "?"])
  description.addProp(#hsScoreLoc, [#comment: "Player Score? (name of variable containing score)", #format: #string, #default: "?"])
  description.addProp(#hsSave, [#comment: "Save score?", #format: #boolean, #default: 0])
  description.addProp(#hsTime, [#comment: "Score is time?", #format: #boolean, #default: 0])
  description.addProp(#hsReverse, [#comment: "Score is reversed?", #format: #boolean, #default: 0])
  return description
end

on getBehaviorDescription
  return "MiniClip Highscore Component Settings" & RETURN & RETURN & "8 options:" & RETURN & "'Game name?'" & RETURN & "Name of the game on the MiniClip highscore server." & RETURN & RETURN & "'Game uses multiple highScores?'" & RETURN & "If your game uses more than 1 high score table tick this." & RETURN & RETURN & "'Name of variable containing suffix?'" & RETURN & "Name of the variable containing the track or level number. This will be added to the game's name to send the score to the correct location." & RETURN & RETURN & "'Player score?'" & RETURN & "Name of variable containing the player's score." & RETURN & RETURN & "'Save score?'" & RETURN & "Selected = Present player with option to enter their name. Unselected = just show scores." & RETURN & RETURN & "'Score is time?'" & RETURN & "Selected = Score is based on time - '00m23s45ms' should be entered as '2345' (number mustn't start with a zero). Unselected = score is numeric value" & RETURN & RETURN & "'Score is reversed?'" & RETURN & "Selected = score is sorted descending, time is sorted ascending.." & RETURN & RETURN & "Notes:" & RETURN & "Automatically, scales, centers and sets ink of the HS component"
end

on getBehaviorTooltip
  return "Controls the MiniClip Highscore Flash Component"
end
