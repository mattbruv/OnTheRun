-- Cast Lingo ParentScript Trail.ls

property trailID, trailType, maxNum, minTime, minDistance, dirMarker, realMark, markList, modelList
global G, havok, world

on new me, id, max_num, min_time, min_distance, dir_marker, real_mark
  trailID = "Trail" & id
  maxNum = max_num
  minTime = min_time
  minDistance = min_distance
  dirMarker = dir_marker
  realMark = real_mark
  if dir_marker then
    trailType = #cone1
  else
    trailType = #sphere1
  end if
  if realMark then
    trail_resource = world.modelResource(trailID & "Resource")
    if voidp(trail_resource) then
      case trailType of
        #sphere1:
          trail_resource = world.newModelResource(trailID & "Resource", #sphere, #front)
          trail_resource.radius = 1
          trail_resource.resolution = 4
        #cone1:
          trail_resource = world.newModelResource(trailID & "Resource", #cylinder, #front)
          trail_resource.topRadius = 0
          trail_resource.bottomRadius = 0.5
          trail_resource.numSegments = 1
          trail_resource.numSegments = 5
          trail_resource.height = 1
      end case
    end if
    trail_shader = world.shader(trailID & "Shader")
    if voidp(trail_shader) then
      trail_shader = world.newShader(trailID & "Shader", #standard)
      trail_shader.ambient = rgb(32, 128, 32)
      trail_shader.blend = 40
      trail_shader.transparent = 1
      trail_shader.renderStyle = #fill
    end if
    modelList = []
    repeat with i = 1 to maxNum
      trail_model = world.model(trailID & "Model" & i)
      if voidp(trail_model) then
        trail_model = world.newModel(trailID & "Model" & i, trail_resource)
        trail_model.shaderList = trail_shader
        trail_model.pointAtOrientation = [vector(0, 1, 0), vector(0, 0, 1)]
        trail_model.visibility = #front
      end if
      trail_model.removeFromWorld()
      append(modelList, trail_model)
    end repeat
  end if
  markList = []
  return me
end

on dropMark me, pos, Dir
  now = havok.simTime
  if markList.count > 0 then
    lastMark = markList[markList.count]
    if minTime > 0 then
      if now - lastMark.time < minTime then
        return 0
      end if
    end if
    if minDistance > 0 then
      if pos.distanceTo(lastMark.pos) < minDistance then
        lastMark.Dir = pos - lastMark.pos
        if realMark then
          lastMark.model.pointAt(pos)
        end if
        return 0
      end if
    end if
    if dirMarker then
      if Dir.angleBetween(lastMark.Dir) < 45 then
        return 0
      end if
    end if
    if markList.count = maxNum then
      if realMark then
        trail_model = markList[1].model
      end if
      markList.deleteAt(1)
    end if
  end if
  if realMark then
    if voidp(trail_model) then
      trail_model = modelList[1]
      modelList.deleteAt(1)
      trail_model.addToWorld()
    end if
    trail_model.transform.position = pos
    markList.append([#time: now, #pos: pos, #Dir: Dir, #model: trail_model])
  else
    markList.append([#time: now, #pos: pos, #Dir: Dir])
  end if
  return 1
end

on getMark me, i
  n = markList.count - i
  if n > 1 then
    return markList[n]
  end if
  return VOID
end

on deleteMark me, mark
  repeat with i = 1 to markList.count
    if markList[i].time = mark.time and markList[i].pos = mark.pos then
      if realMark then
        markList[i].model.removeFromWorld()
        modelList.append(markList[i].model)
      end if
      markList.deleteAt(i)
      exit repeat
    end if
  end repeat
end

on getHiddenMark me, camera
  repeat with mark in markList
    if voidp(camera.worldSpaceToSpriteSpace(mark.pos)) then
      return mark
    end if
  end repeat
  return VOID
end

on reset me
  if realMark then
    repeat with mark in markList
      mark.model.removeFromWorld()
      modelList.append(mark.model)
    end repeat
  end if
  markList = []
end
