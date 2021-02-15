function add_time(tag, timestamp, record)
  if (record['@timestamp'] == nil ) then
    -- ISO 8601: YYYY-MM-DDTHH:MM:SS.mmmmmm
    -- "2021-02-12T22:23:09.189596000Z
    record['@timestamp'] = os.date("!%Y-%m-%dT%T.", timestamp['sec']) .. timestamp['nsec'] .. "Z"
    return 1, timestamp, record
  else
    return 0, timestamp, record
  end
end
