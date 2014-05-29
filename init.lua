local stream_readable = require('./lib/stream_readable')
local stream = require('./lib/stream')

local exports = {}

for k,v in pairs(stream_readable) do
  exports[k] = v
end

for k,v in pairs(stream) do
  exports[k] = v
end

return exports
