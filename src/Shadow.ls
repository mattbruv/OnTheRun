-- Cast Lingo ParentScript Shadow.ls

property shModel, shName, shShadow, shUp, shHeight, shOffset
global G, world

on new me, target_model, shadow_name, vector_up, shadow_height
  shModel = target_model
  shName = shadow_name
  shUp = vector_up
  shHeight = shadow_height
  shShadow = world.model(shModel.name & shName)
  if voidp(shShadow) then
    shShadow = world.model(shName).clone(shModel.name & shName)
  end if
  shOffset = shUp * shHeight
  return me
end

on updateShadow me, point_of_contact, normal_vector
  t = transform()
  t.position = point_of_contact + shOffset
  shShadow.transform = t
  shShadow.pointAt(point_of_contact + normal_vector)
  shShadow.transform.preRotate(vector(0, 0, -shModel.transform.rotation.z))
end

on hideShadow me
  shShadow.visibility = #none
end

on showShadow me
  shShadow.visibility = #front
end
