
-- Field translation table
rename = {
  environment = "labels.environment.",
  hostname    = "hostx.hostname.",
  level       = "logx.level.",
  log         = "logx.original.",
  logger      = "logx.logger.",
}

-- utilities
function merge(a, b)
    if type(a) == 'table' and type(b) == 'table' then
        for k,v in pairs(b) do if type(v)=='table' and type(a[k] or false)=='table' then merge(a[k],v) else a[k]=v end end
    end
    return a
end

function nest(key, val)
  local t
  t = {}
  t[key] = val
  return t
end

-- Convert keys
function rename_key (record, oldkey, value)
  -- parse and create nested key
  local newkey, nkey, leaf
  newkey = rename[oldkey]
  -- Get key parts for nesting
  i=0
  nkey={}
  for m in string.gmatch(newkey, '(.-)%f[.]') do
    if ( m == "" ) then goto continue end
    nkey[i] = m
    i = i + 1
    ::continue::
  end
  -- Build nested key
  leaf = {}
  leaf[nkey[#nkey]] = value
  for i= #nkey-1, 1, -1 do
    leaf = nest(nkey[i], leaf)
  end
  record[string.format("%s",nkey[0])] = merge(leaf, record[string.format("%s",nkey[0])])
  -- Delete old key. If old != new
  if (oldkey ~= string.format("%s",nkey[0])) then
    record[oldkey] = nil
  end
  return record
end

-- Process all fields
function convert_fields_to_ecs(tag, timestamp, record)
  if (record["log"] ~= nil) then
    record = rename_key(record, "log", record["log"])
  end
  for key,value in pairs(record) do
    if (not (rename[key] == nil )) then
      record = rename_key(record, key, value)
    end
  end
  return 2, timestamp, record
end
