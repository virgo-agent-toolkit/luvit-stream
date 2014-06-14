#!/usr/bin/env luvit

local spawn = require('childprocess').spawn
local execFile = require('childprocess').execFile
local stream = require('..')

local child = spawn("git", {"clone", "--recursive", "-b", "songgao/wip", "git://github.com/virgo-agent-toolkit/luvit-tape", "modules/tape"})
stream.Readable:new():wrap(child.stdout):pipe(process.stdout)
stream.Readable:new():wrap(child.stderr):pipe(process.stdout)
