#!~/bin/lua

require "fun" ()

-- the factorio lua files want to use data:extend so we implement it here
data = {}
function data.extend (target, new_data)
  -- append rows from new_data to target
  for i=1,#new_data do
    target[#target+1] = new_data[i]
  end
end

function print_table (table)
  print( print_table_depth(table, 0))
end

function print_table_depth (table, depth)
  -- print out a table in a nice visualization
  assert ( type(table) == "table")
  out = ""
  for k,v in pairs(table) do
    -- indent
    out = out .. string.rep(" ", depth)
    if type(v) == "number" or type(v) == "string" or type(v) == "boolean" then
      out = out .. string.format("%s: %s\n", k, v)
    elseif type(v) == "table" then
      out = out .. string.format("%s\n", k)
      out = out .. print_table_depth(v, depth + 1)
    elseif type(v) == "function" then
      out = out .. string.format("function %s\n", k)
    else
      assert(false)
    end
  end
  return out
end
  

tech_path = "/Users/hbullen/Library/Application Support/Steam/steamapps/common/Factorio/factorio.app/Contents/data/base/prototypes/technology/technology.lua"
--tech_path = "samp-tech.lua"


dofile(tech_path)

print("Nodes found")
print(#data)
print( "technology nodes found: ")
print(#totable(filter(function(x) return x.type == "technology" end, ipairs(data))))
print( "Non-technology nodes found: ")
print(#totable(filter(function(x) return x.type ~= "technology" end, ipairs(data))))

function contains(is, target)
  --if is == nil then return false end
  return any(function(x) return x[1] == target end, ipairs(is))
end

function ingredients_to_type(is)
  if contains(is, "space-science-pack") then
    name = "Space Science"
  elseif contains(is, "high-tech-science-pack") then
    name = "High Tech Science"
  elseif contains(is, "science-pack-3") then
    name = "Blue Science"
  elseif contains(is, "science-pack-2") then
    name = "Green Science"
  else
    name = "Red Science"
  end

  if contains(is, "military-science-pack") then
    name = "Military " .. name
  end
  if contains(is, "production-science-pack") then
    name = "Production " .. name
  end
  return name
  -- return "Production Science"
  -- return Military Science"

end

function ingredients_to_string(is)
  if is == nil then return "" end
  return table.concat( totable( map ( function (x) return x[1] end, ipairs(is))), ":")
end

function unlocks_to_string(es)
  if (es == nil ) then return "" else
  return table.concat( totable(
  map(function(e) return e.recipe end,
  filter(function(e) return e.type == "unlock-recipe" end, ipairs(es)))), ", ")
  end
end

function unit_to_count(u)
  if u.count ~= nil then return u.count else return u.count_formula end
end

function prerequisites(ps)
 if ps == nil then 
  return ""
 else
  return table.concat(ps, ", ")
 end
end

function entry_to_string(e) 
  return string.format("%s\t%s\t%s\t%s\t%s\t%s",
              e.name,
              prerequisites(e.prerequisites),
              ingredients_to_type(e.unit.ingredients),
              -- ingredients_to_string(e.unit.ingredients),
              e.unit.time, unit_to_count(e.unit),
              unlocks_to_string(e.effects))
end

res = filter(function(x) return x.type == "technology" end, ipairs(data))
print(table.concat(totable(map(entry_to_string, res)),"\n"))


