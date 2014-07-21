local stream = require('./lib/stream')
local stream_readable = require('./lib/stream_readable')
local stream_writable = require('./lib/stream_writable')
local stream_duplex = require('./lib/stream_duplex')
local stream_transform = require('./lib/stream_transform')
local stream_passthrough = require('./lib/stream_passthrough')
local stream_observable = require('./lib/stream_observable')
local stream_concat = require('./lib/stream_concat')

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

for k,v in pairs(stream_duplex) do
  exports[k] = v
end

for k,v in pairs(stream_transform) do
  exports[k] = v
end

for k,v in pairs(stream_passthrough) do
  exports[k] = v
end

for k,v in pairs(stream_observable) do
  exports[k] = v
end

for k,v in pairs(stream_concat) do
  exports[k] = v
end

return exports
