local stream = require('./lib/stream')
local stream_readable = require('./lib/stream_readable')
local stream_writable = require('./lib/stream_writable')

local exports = {}

for k,v in pairs(stream) do
  exports[k] = v
end

for k,v in pairs(stream_readable) do
  exports[k] = v
end

for k,v in pairs(stream_writable) do
  exports[k] = v
end

return exports
