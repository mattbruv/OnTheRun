-- Cast Lingo BehaviorScript AttesaSemaforo.ls

property attesa
global G, human, havok, world

on beginSprite me
  attesa = VOID
  world.model("Semaforo").transform.rotation = vector(0, 90, 0)
end

on exitFrame
  if voidp(attesa) then
    attesa = the milliSeconds + 3000
    sound(human.sndChEngine).volume = 254
    go(the frame)
  else
    if the milliSeconds < attesa then
      havok.step()
      go(the frame)
    else
      world.model("Semaforo").transform.rotation = vector(0, 90, 90)
      G.Run = 1
    end if
  end if
end
