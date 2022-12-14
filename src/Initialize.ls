-- Cast Lingo MovieScript Initialize.ls

global G, world, havok, havokCallback, trail, tastoP, tastoR, tastoS, ffxExit

on prepareMovie
  ffxExit = 0
  repeat with i = 1 to 8
    sound(i).stop()
    sound(i).volume = 254
    sound(i).pan = 0
  end repeat
  tastoP = 0
  set the keyDownScript to "keyDownManager"
  set the keyUpScript to "keyManager"
  the alertHook = script("alertScript")
end

on stopMovie
  if objectp(havok) then
    if havok.initialized then
      havok.shutDown()
    end if
  end if
  if G.editBonus then
    another_loop = 1
    repeat while another_loop
      another_loop = 0
      repeat with i = 1 to G.bonusList.count
        if voidp(G.bonusList[i]) then
          G.bonusList.deleteAt(i)
          another_loop = 1
          exit repeat
        end if
      end repeat
    end repeat
    gUpdate(#bonusList, G.bonusList)
    world.resetWorld()
  end if
  set the keyDownScript to EMPTY
  set the keyUpScript to EMPTY
end

on keyDownManager
  if the key = "p" then
    tastoP = 1
  end if
  if the key = "r" then
    tastoR = 1
  end if
  if the key = "s" then
    tastoS = 1
  end if
  pass()
end

on keyManager
  k = the key
  if tastoP then
    tastoP = 0
    if G.pausa then
      G.Run = 1
      repeat with i = 1 to 8
        sound(i).play()
      end repeat
      G.pausa = 0
      sprite(1).camera.fog.enabled = 0
    else
      if G.Run = 1 then
        G.Run = 0
        repeat with i = 1 to 8
          sound(i).pause()
        end repeat
        G.pausa = 1
        sprite(1).camera.fog.decayMode = #exponential
        sprite(1).camera.fog.far = 200
        sprite(1).camera.fog.color = rgb(192, 192, 192)
        sprite(1).camera.fog.enabled = 1
      end if
    end if
  else
    if tastoR then
      tastoR = 0
      if G.Run = 1 then
        repeat with i = 1 to 8
          sound(i).stop()
          sound(i).volume = 254
          sound(i).pan = 0
        end repeat
        go(1)
      end if
    else
      if k = "q" or charToNum(k) = 27 then
        G.Run = 0
        repeat with i = 1 to 8
          sound(i).stop()
          sound(i).volume = 254
          sound(i).pan = 0
        end repeat
        ffxExit = 1
        go("WAIT")
      else
        if tastoS then
          tastoS = 0
          if the soundLevel = 7 then
            set the soundLevel to 0
          else
            set the soundLevel to 7
          end if
        end if
      end if
    end if
  end if
end
