-- Cast Lingo BehaviorScript Target.ls

property n, period, amplitude, offset, spriteNum, pSprite, world, pmodel, pTarget, sinarg
global havok

on beginSprite me
  pSprite = sprite(me.spriteNum)
  world = pSprite.member
  n = 3
  period = 3
  amplitude = 2
  offset = [0.5, 0.25, 0.25]
  repeat with i = 1 to 3
    offset[i] = offset[i] + amplitude
  end repeat
  sinarg = float(2.0 * PI / float(period))
  pmodel = world.model("AutoPlayer")
  target_resource = world.modelResource("TargetResource")
  if voidp(target_resource) then
    target_resource = world.newModelResource("TargetResource", #box, #front)
    target_resource.height = 0.5
    target_resource.width = 0.5
    target_resource.length = 0.5
    target_resource.lengthVertices = 2
    target_resource.widthVertices = 2
    target_resource.lengthVertices = 2
  end if
  target_shader = world.shader("TargetShader")
  if voidp(target_shader) then
    target_shader = world.newShader("TargetShader", #standard)
    target_shader.ambient = rgb(32, 32, 128)
    target_shader.blend = 50
    target_shader.transparent = 1
    target_shader.renderStyle = #fill
  end if
  pTarget = []
  repeat with i = 1 to n
    pTarget[i] = world.model("Target" & i)
    if voidp(pTarget[i]) then
      pTarget[i] = world.newModel("Target" & i, target_resource)
      pTarget[i].shaderList = target_shader
      pTarget[i].parent = pmodel
      pTarget[i].visibility = #none
    end if
  end repeat
end

on exitFrame
  now = havok.simTime
  delta = sin(sinarg * now) * amplitude
  repeat with i = 1 to n
    case i of
      1:
        p = vector(-offset[i] - delta, 0, 0)
      2:
        p = vector(0, -offset[i] + delta, 0)
      3:
        p = vector(0, offset[i] - delta, 0)
    end case
    pTarget[i].transform.position = p
  end repeat
end
