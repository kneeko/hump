--[[
Copyright (c) 2010-2013 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local assert = assert
local sqrt, cos, sin, atan2 = math.sqrt, math.cos, math.sin, math.atan2

local vector = {}
vector.__index = vector

local function new(v)
	return setmetatable({v[1] or 0, v[2] or 0}, vector)
end
local zero = new{0,0}

local function isvector(v)
	return type(v) == 'table' and type(v[1]) == 'number' and type(v[2]) == 'number'
end

function vector:clone()
	return new{self[1], self[2]}
end

function vector:unpack()
	return self[1], self[2]
end

function vector:__tostring()
	return "("..tonumber(self[1])..","..tonumber(self[2])..")"
end

function vector.__unm(a)
	return new{-a[1], -a[2]}
end

function vector.__add(a,b)
	assert(isvector(a) and isvector(b), "Add: wrong argument types (<vector> expected)")
	return new{a[1]+b[1], a[2]+b[2]}
end

function vector.__sub(a,b)
	assert(isvector(a) and isvector(b), "Sub: wrong argument types (<vector> expected)")
	return new{a[1]-b[1], a[2]-b[2]}
end

function vector.__mul(a,b)
	if type(a) == "number" then
		return new{a*b[1], a*b[2]}
	elseif type(b) == "number" then
		return new{b*a[1], b*a[2]}
	else
		assert(isvector(a) and isvector(b), "Mul: wrong argument types (<vector> or <number> expected)")
		return a[1]*b[1] + a[2]*b[2]
	end
end

function vector.__div(a,b)
	assert(isvector(a) and type(b) == "number", "wrong argument types (expected <vector> / <number>)")
	return new{a[1] / b, a[2] / b}
end

function vector.__eq(a,b)
	return a[1] == b[1] and a[2] == b[2]
end

function vector.__lt(a,b)
	return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2])
end

function vector.__le(a,b)
	return a[1] <= b[1] and a[2] <= b[2]
end

function vector.permul(a,b)
	assert(isvector(a) and isvector(b), "permul: wrong argument types (<vector> expected)")
	return new{a[1]*b[1], a[2]*b[2]}
end

function vector:len2()
	return self[1] * self[1] + self[2] * self[2]
end

function vector:len()
	return sqrt(self[1] * self[1] + self[2] * self[2])
end

function vector.dist(a, b)
	assert(isvector(a) and isvector(b), "dist: wrong argument types (<vector> expected)")
	local dx = a[1] - b[1]
	local dy = a[2] - b[2]
	return sqrt(dx * dx + dy * dy)
end

function vector.dist2(a, b)
	assert(isvector(a) and isvector(b), "dist: wrong argument types (<vector> expected)")
	local dx = a[1] - b[1]
	local dy = a[2] - b[2]
	return (dx * dx + dy * dy)
end

function vector:normalize_inplace()
	local l = self:len()
	if l > 0 then
		self[1], self[2] = self[1] / l, self[2] / l
	end
	return self
end

function vector:normalized()
	return self:clone():normalize_inplace()
end

function vector:rotate_inplace(phi)
	local c, s = cos(phi), sin(phi)
	self[1], self[2] = c * self[1] - s * self[2], s * self[1] + c * self[2]
	return self
end

function vector:rotated(phi)
	local c, s = cos(phi), sin(phi)
	return new{c * self[1] - s * self[2], s * self[1] + c * self[2]}
end

function vector:perpendicular()
	return new{-self[2], self[1]}
end

function vector:projectOn(v)
	assert(isvector(v), "invalid argument: cannot project vector on " .. type(v))
	-- (self * v) * v / v:len2()
	local s = (self[1] * v[1] + self[2] * v[2]) / (v[1] * v[1] + v[2] * v[2])
	return new{s * v[1], s * v[2]}
end

function vector:mirrorOn(v)
	assert(isvector(v), "invalid argument: cannot mirror vector on " .. type(v))
	-- 2 * self:projectOn(v) - self
	local s = 2 * (self[1] * v[1] + self[2] * v[2]) / (v[1] * v[1] + v[2] * v[2])
	return new{s * v[1] - self[1], s * v[2] - self[2]}
end

function vector:cross(v)
	assert(isvector(v), "cross: wrong argument types (<vector> expected)")
	return self[1] * v[2] - self[2] * v[1]
end

-- ref.: http://blog.signalsondisplay.com/?p=336
function vector:trim_inplace(maxLen)
	local s = maxLen * maxLen / self:len2()
	s = (s > 1 and 1) or math.sqrt(s)
	self[1], self[2] = self[1] * s, self[2] * s
	return self
end

function vector:angleTo(other)
	if other then
		return atan2(self[2], self[1]) - atan2(other[2], other[1])
	end
	return atan2(self[2], self[1])
end

function vector:trimmed(maxLen)
	return self:clone():trim_inplace(maxLen)
end


-- the module
return setmetatable({new = new, isvector = isvector, zero = zero},
{__call = function(_, ...) return new(...) end})
