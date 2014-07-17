local core = require('core')
local table = require('table')
local Readable = require('..').Readable
local Writable = require('..').Writable
local test = require('tape')('test-stream2-wrap')

test('preserve old method', nil, function(t)
  local old = core.Emitter:new()
  old.foo = function()
    return 42
  end
  local wrapped = Readable:new():wrap(old)
  t:equal(wrapped.foo(), 42)
  t:finish()
end)
