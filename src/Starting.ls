-- Cast Lingo BehaviorScript Starting.ls

global G, world, havok, havokCallback, trail

on beginSprite me
  cursor(200)
end

on exitFrame me
  gLoad()
  world = member("aworld")
  havok = member("aphysic")
  world.resetWorld()
  world.animationEnabled = 0
  getRendererServices().textureRenderFormat = #rgba5551
  repeat with n = 1 to world.model.count
    m = world.model[n]
    if m.name contains "?" then
      m.removeFromWorld()
    end if
    if m.name contains "*" then
      m.addModifier(#lod)
      m.lod.auto = 1
      m.lod.bias = 8
    end if
    if m.name contains "+" then
      m.visibility = #both
    end if
    if m.name contains "-" then
      if not (m.name contains "Overlay-copy") then
        m.visibility = #none
      end if
    end if
    if m.name starts "Sbarra" or m.name = "Treno" then
      m.addModifier(#keyframePlayer)
      m.keyframePlayer.removeLast()
    end if
  end repeat
  repeat with n = 1 to world.shader.count
    s = world.shader[n]
    if s.name contains "$" then
      s.flat = 0
      next repeat
    end if
    s.flat = 1
  end repeat
  repeat with n = 1 to world.texture.count
    t = world.texture[n]
    t.nearFiltering = 1
    if t.name contains "&m" then
      t.quality = #medium
    else
      if t.name contains "&h" then
        t.quality = #high
      else
        t.quality = #low
      end if
    end if
    if t.name contains "&rgba4444" then
      t.renderFormat = #rgba4444
    end if
    t.compressed = 0
  end repeat
  world.animationEnabled = 1
  repeat with sourceName in ["aMotionSbarreBonus", "aMotionTreniMacchine"]
    mem = member(sourceName)
    repeat with i = 2 to mem.motion.count
      mot = mem.motion[i]
      if voidp(world.motion(sourceName & "-" & mot.name)) then
        world.cloneMotionFromCastmember(sourceName & "-" & mot.name, mot.name, mem)
      end if
    end repeat
  end repeat
  tot = G.zoneList.count
  repeat with i = 1 to tot
    grp = world.group("zona" & i)
    if voidp(grp) then
      grp = world.newGroup("zona" & i)
      sublist = G.zoneList[i]
      repeat with obj in sublist
        grp.addChild(world.model(obj))
      end repeat
    end if
    G.zone[i] = grp
  end repeat
  havok.Initialize(world)
  havok.gravity = vector(0, 0, -32)
  havok.deactivationParameters = [10, 0.5]
  havok.dragParameters = [100, 100]
  havok.timeStep = 0.04
  havok.subSteps = 6
  trail = new(script("trail"), 1, 20, 1, 10, 0, 0)
  world.registerForEvent(#timeMS, #zoneManager, 0, 0, 1000, 0)
  zoneChange(1)
end
