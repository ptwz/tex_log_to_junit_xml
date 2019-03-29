callback.register("show_error_hook",
  function ()
    texio.write_nl("[FILE: " .. status.filename .. ", LINE: " .. status.linenumber .. "]")
  end)

--callback.register("open_read_file",
--  function (file_name)
--    texio.write_nl("[FILE: " .. status.filename .. ", LINE: " .. status.linenumber .. "]")
--    return luatexbase.read_data_file(file_name)
--  end)

-- luafuncions.lua
curfile=""

letpass = function(line)
  if (status.filename ~= curfile)  then
    curfile=status.filename
    texio.write_nl(">>>>>> "..  curfile .. " <<<<<")
    
  end
  return nil
end
callback.register("process_input_buffer",letpass)

xml_msg = function(line)
        texio.write_nl("Hallo")
        for index, data in ipairs(line) do
            texit.write_nl("#########", index, data)
        end
    return nil
end
---callback.register("show_error_hook", xml_msg)

hallo = function(line)
        texio.write_nl("Hallo Welt "..line)
    return nil
end
