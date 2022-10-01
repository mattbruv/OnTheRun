-- Cast Lingo ParentScript alertScript.ls

on new me
  return me
end

on alertHook me, err, Msg
  if Msg contains "Officine Pixel" then
    alert(Msg)
  end if
  return 1
end
