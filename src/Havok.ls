-- Cast Lingo BehaviorScript Havok.ls

global havok, G

on exitFrame
  if G.Run then
    havok.step()
  end if
end
