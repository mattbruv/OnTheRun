-- Cast Lingo BehaviorScript Calcolo punti.ls

global G, havok, punti

on exitFrame me
  repeat with i in [1, 2, 3, 5, 6, 7, 8]
    sound(i).stop()
  end repeat
  member("txtbenz").text = numToStr(integer(G.benza * 100 / G.benzaMax), EMPTY, 1, 0) & "%"
  member("txttotBenz").text = numToStr(G.totBenz, EMPTY, 2, 0) & "/" & G.bonusType1
  member("txtmecc").text = numToStr(integer(G.carrozzeria * 100 / G.carrozzeriaMax), EMPTY, 1, 0) & "%"
  member("txttotMecc").text = numToStr(G.totMecc, EMPTY, 2, 0) & "/" & G.bonusType2
  member("txttime1").text = numToTime(integer(havok.simTime * 10))
  member("txttime2").text = numToTime(integer(havok.simTime * 10))
  punti = G.benza + G.carrozzeria * G.totMecc + 121 * G.totBenz + 121 * G.totMecc
  member("txtpoint").text = numToStr(punti, EMPTY, 5, 0)
end

on beginSprite me
  cursor(-1)
  repeat with n = 1 to 100
    sprite(n).cursor = -1
  end repeat
end
