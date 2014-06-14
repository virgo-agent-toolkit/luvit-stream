local table = require('table')
local Readable = require('..').Readable
local Writable = require('..').Writable
local test = require('./modules/tape')('test-stream2-objects')

function noop() end

function toArray(callback)
  local stream = Writable:new({ objectMode = true })
  local list = {}
  stream.write = function(self, chunk)
    table.insert(list, chunk)
  end

  stream._end = function()
    callback(list)
  end

  return stream
end

function fromArray(list)
  local r = Readable:new({ objectMode = true })
  r._read = noop
  for k,v in pairs(list) do
    r:push(v)
  end
  r:push(nil)

  return r
end


--[[
]]
test('can read objects from stream', nil, function(t)
  local r = fromArray({{ one = '1'}, { two = '2' }})

  local v1 = r:read()
  local v2 = r:read()
  local v3 = r:read()

  t:equal(v1, { one = '1' })
  t:equal(v2, { two = '2' })
  t:equal(v3, nil)

  t:finish()
end)

test('can pipe objects into stream', nil, function(t)
  local r = fromArray({{ one = '1'}, { two = '2' }})

  r:pipe(toArray(function(list)
    t:equal(list, {
      { one = '1' },
      { two = '2' }
    })

    t:finish()
  end))
end)

test('read(n) is ignored', nil, function(t)
  local r = fromArray({{ one = '1'}, { two = '2' }})

  local value = r:read(2)

  t:equal(value, { one = '1' })

  t:finish()
end)

test('can read objects from _read (sync)', nil, function(t)
  local r = Readable:new({ objectMode = true })
  local list = {{ one = '1'}, { two = '2' }}
  r._read = function(self, n)
    local item = table.remove(list, 1)
    r:push(item or nil)
  end

  r:pipe(toArray(function(list)
    t:equal(list, {
      { one = '1' },
      { two = '2' }
    })

    t:finish()
  end))
end)

test('can read objects from _read (async)', nil, function(t)
  local r = Readable:new({ objectMode = true })
  local list = {{ one = '1'}, { two = '2' }}
  r._read = function(self, n)
    local item = table.remove(list, 1)
    process.nextTick(function()
      r:push(item or nil)
    end)
  end

  r:pipe(toArray(function(list)
    t:equal(list, {
      { one = '1' },
      { two = '2' }
    })

    t:finish()
  end))
end)

test('can read strings as objects', nil, function(t)
  local r = Readable:new({
    objectMode = true
  })
  r._read = noop
  local list = {'one', 'two', 'three'}
  for k,v in pairs(list) do
    r:push(v)
  end
  r:push(nil)

  r:pipe(toArray(function(array)
    t:equal(array, list)

    t:finish()
  end))
end)

test('read(0) for object streams', nil, function(t)
  local r = Readable:new({
    objectMode = true
  })
  r._read = noop

  r:push('foobar')
  r:push(nil)

  local v = r:read(0)

  r:pipe(toArray(function(array)
    t:equal(array, {'foobar'})

    t:finish()
  end))
end)

test('falsey values', nil, function(t)
  local r = Readable:new({
    objectMode = true
  })
  r._read = noop

  r:push(false)
  r:push(0)
  r:push('')
  r:push(nil)

  r:pipe(toArray(function(array)
    t:equal(array, {false, 0, ''})

    t:finish()
  end))
end)

test('high watermark _read', nil, function(t)
  local r = Readable:new({
    highWaterMark = 6,
    objectMode = true
  })
  local calls = 0
  local list = {'1', '2', '3', '4', '5', '6', '7', '8'}

  r._read = function(self, n)
    calls = calls + 1
  end

  for k,v in pairs(list) do
    r:push(v)
  end

  local v = r:read()

  t:equal(calls, 0)
  t:equal(v, '1')

  local v2 = r:read()
  t:equal(v2, '2')

  local v3 = r:read()
  t:equal(v3, '3')

  t:equal(calls, 1)

  t:finish()
end)

test('high watermark push', nil, function(t)
  local r = Readable:new({
    highWaterMark = 6,
    objectMode = true
  })
  r._read = function(self, n) end
  for i = 1,6 do
    local bool = r:push(i)
    t:equal(bool, i ~= 6)
  end

  t:finish()
end)

test('can write objects to stream', nil, function(t)
  local w = Writable:new({ objectMode = true })

  w._write = function(self, chunk, encoding, cb)
    t:equal(chunk, { foo = 'bar' })
    cb()
  end

  w:on('finish', function()
    t:finish()
  end)

  w:write({ foo = 'bar' })
  w:_end()
end)

test('can write multiple objects to stream', nil, function(t)
  local w = Writable:new({ objectMode = true })
  local list = {}

  w._write = function(self, chunk, encoding, cb)
    table.insert(list, chunk)
    cb()
  end

  w:on('finish', function()
    t:equal(list, {0, 1, 2, 3, 4})

    t:finish()
  end)

  w:write(0)
  w:write(1)
  w:write(2)
  w:write(3)
  w:write(4)
  w:_end()
end)

test('can write strings as objects', nil, function(t)
  local w = Writable:new({
    objectMode = true
  })
  local list = {}

  w._write = function(self, chunk, encoding, cb)
    table.insert(list, chunk)
    process.nextTick(cb)
  end

  w:on('finish', function()
    t:equal(list, {'0', '1', '2', '3', '4'})

    t:finish()
  end)

  w:write('0')
  w:write('1')
  w:write('2')
  w:write('3')
  w:write('4')
  w:_end()
end)

test('buffers finish until cb is called', nil, function(t)
  local w = Writable:new({
    objectMode = true
  })
  local called = false

  w._write = function(self, chunk, encoding, cb)
    t:equal(chunk, 'foo')

    process.nextTick(function()
      called = true
      cb()
    end)
  end

  w:on('finish', function()
    t:equal(called, true)

    t:finish()
  end)

  w:write('foo')
  w:_end()
end)
