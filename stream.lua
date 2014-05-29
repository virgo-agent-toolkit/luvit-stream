local Emitter = require('core').Emitter


local exports = {}

local Stream = Emitter:extend()

exports.Stream = Stream

return exports
