---------------------------------------------------------------------
-- barrel (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2024-04-26 11:44:58
---------------------------------------------------------------------

--- 六边形计算，通过GPT3翻译hex.cs文件整理所得

local Hex = {}

-- Offset与Cube的转换

-- 地图采用顶点朝上 奇数行右移
-- 单个六角形的width设为2个unit ==》边长为1.1547f;
Hex.HexRadius = 1.1547
local Sqrt3 = 1.7320508
Hex.Sqrt3 = Sqrt3
-- 中心点偏移
Hex.CenterUnit_x = Hex.HexRadius * Sqrt3 * 0.5
Hex.CenterUnit_y = 0
Hex.CenterUnit_z = Hex.HexRadius

local function Internal_CubeRound(cube_x, cube_y, cube_z)
	-- 三个轴先进行round 然后对diff最大的进行校正
	local rx = math.floor(cube_x + 0.5)
	local ry = math.floor(cube_y + 0.5)
	local rz = math.floor(cube_z + 0.5)

	local x_diff = math.abs(rx - cube_x)
	local y_diff = math.abs(ry - cube_y)
	local z_diff = math.abs(rz - cube_z)

	if x_diff > y_diff and x_diff > z_diff then
		rx = -ry - rz
	elseif y_diff > z_diff then
		ry = -rx - rz
	else
		rz = -rx - ry
	end

	return rx, ry, rz
end

local function Internal_OffsetToCube(offset_x, offset_y)
	local x = offset_x - (offset_y - (offset_y & 1)) / 2
	local z = offset_y
	local y = -x - z
	return x, y, z
end

local function Internal_CubeToOffset(cube_x, cube_y, cube_z)
	local col = cube_x + (cube_z - (cube_z & 1)) / 2
	local row = cube_z
	return col, row
end

local function Internal_OffsetToWorld(offset_x, offset_y)
	local x = Hex.HexRadius * Sqrt3 * (offset_x + 0.5 * (offset_y & 1) + 0.5)
	local y = Hex.HexRadius * (3 / 2.0 * offset_y + 1)
	return x, 0, -y
end

local function Internal_WorldToOffset(world_x, world_y, world_z)
	-- 先把负z转为正z 再减去中心点的偏移
	world_x = world_x - Hex.CenterUnit_x
	world_y = world_y - Hex.CenterUnit_y
	world_z = -world_z - Hex.CenterUnit_z

	local q = (Sqrt3 / 3 * world_x - 1 / 3 * world_z) / Hex.HexRadius
	local r = (0 + 2 / 3 * world_z) / Hex.HexRadius

	local cube_x, cube_y, cube_z = Internal_CubeRound(q, -q - r, r)
	return Internal_CubeToOffset(cube_x, cube_y, cube_z)
end

local function Internal_HexDistance(hexA_x, hexA_y, hexA_z, hexB_x, hexB_y, hexB_z)
	return math.max(math.abs(hexB_x - hexA_x), math.abs(hexB_y - hexA_y), math.abs(hexB_z - hexA_z))
end

local function Internal_TileDistance(a_x, a_y, b_x, b_y)
	local cube_a_x, cube_a_y, cube_a_z = Internal_OffsetToCube(a_x, a_y)
	local cube_b_x, cube_b_y, cube_b_z = Internal_OffsetToCube(b_x, b_y)
	return Internal_HexDistance(cube_a_x, cube_a_y, cube_a_z, cube_b_x, cube_b_y, cube_b_z)
end

-- 邻接点的偏移量
-- https://www.redblobgames.com/grids/hexagons/#neighbors-offset
local NeighborOffset = {
	{
		{x = 1, y = 0}, {x = 0, y = -1}, {x = -1, y = -1},
		{x = -1, y = 0}, {x = -1, y = 1}, {x = 0, y = 1}
	},
	{
		{x = 1, y = 0}, {x = 1, y = -1}, {x = 0, y = -1},
		{x = -1, y = 0}, {x = 0, y = 1}, {x = 1, y = 1}
	}
}

local function Internal_OddROffsetNeighbor(pos_x, pos_y, dir)
	local parity = pos_y & 1
	local d = NeighborOffset[parity + 1][dir]
	return pos_x + d.x, pos_y + d.y
end

-- 对外接口

local MapHeight = 1732.619
Hex.UP_SIDE_DOWN = false

-- 之前写的Hex offset y起始点是上面，现在新项目y起始点是下面 先不动上面offset和cube的转换 万一哪天又要改回去 直接包一层翻转下
local function UpsideDownOffset(offset_x, offset_y)
	if Hex.UP_SIDE_DOWN then
		offset_y = 999 - offset_y
	end
	return offset_x, offset_y
end

function Hex.WorldToOffset(world_x, world_y, world_z)
	if Hex.UP_SIDE_DOWN then
		world_z = world_z - MapHeight
	end

	local offset_x, offset_y = Internal_WorldToOffset(world_x, world_y, world_z)
	return UpsideDownOffset(offset_x, offset_y)
end

function Hex.OffsetToWorld(offset_x, offset_y)
	offset_x, offset_y = UpsideDownOffset(offset_x, offset_y)
	local world_x, world_y, world_z = Internal_OffsetToWorld(offset_x, offset_y)
	if Hex.UP_SIDE_DOWN then
		world_z = world_z + MapHeight
	end
	return world_x, world_y, world_z
end

function Hex.OffsetToCube(offset_x, offset_y)
	offset_x, offset_y = UpsideDownOffset(offset_x, offset_y)
	return Internal_OffsetToCube(offset_x, offset_y)
end

function Hex.CubeToOffset(cube_x, cube_y, cube_z)
	local offset_x, offset_y = Internal_CubeToOffset(cube_x, cube_y, cube_z)
	return UpsideDownOffset(offset_x, offset_y)
end

function Hex.OddROffsetNeighbor(offset_x, offset_y, dir)
	offset_x, offset_y = UpsideDownOffset(offset_x, offset_y)
	return Internal_OddROffsetNeighbor(offset_x, offset_y, dir)
end

function Hex.TileDistance(a_x, a_y, b_x, b_y)
	a_x, a_y = UpsideDownOffset(a_x, a_y)
	b_x, b_y = UpsideDownOffset(b_x, b_y)
	return Internal_TileDistance(a_x, a_y, b_x, b_y)
end

return Hex
