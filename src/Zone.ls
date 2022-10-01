-- Cast Lingo MovieScript Zone.ls

global G, tot

on createZone
  gLoad()
  tot = []
  repeat with i = 1 to G.zoneNumber
    z = []
    m = member("Zona" & i)
    repeat with k = 1 to m.model.count
      z.append(m.model[k].name)
    end repeat
    tot.append(z)
  end repeat
end

on adjustZone
  gLoad()
  G.zoneNumber = G.zoneOn.count
  gUpdate(#zoneNumber, G.zoneNumber)
  zone01 = []
  repeat with i = 1 to G.zoneNumber
    zona = []
    repeat with k = 1 to G.zoneNumber
      if k = i or G.zoneOn[i].getOne(k) <> 0 then
        zona.append(1)
        next repeat
      end if
      zona.append(0)
    end repeat
    zone01[i] = zona
  end repeat
  gUpdate(#zone01, zone01)
end
