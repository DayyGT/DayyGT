-- Variable Retrieve Magplant
Mag_X = 1
Mag_Y = 116
MagDrop = 0
DelayMAG = 250
MAGToggle = false
CekKoor = false

-- PTHT YANG MAU DI ADD
CropID   = 955
SeedID   = 956
PlatID   = 564
DelayHT  = 30
DelayPT  = 30     
DelayUWS = 1000
TileRemote = { x = 9, y = 11 }
WorldType = "Island"

--PNB VARIABLE
PNB_ID = 328
PNB_Delay = 100
PNB_Far = 1
PNB_Right = true
PNB_Left = false

PlantToggle = true
HarvestToggle = true
UWSToggle = true
AutoLeaveEnabled = false
PNBToggle = false
PTHTToggle = false
DayyCollect = false

-- MagTile: digunakan khusus untuk retrieve/mag
MagTile = { x = 9, y = 116 }

-- Variable EditToggle
LastAntilag = false
LastNoParticle = false
LastModFly = false

local json = [[
{
  "sub_name": "DayyGTPS (PTHT)",
  "icon": "Fingerprint",
  "menu": [
    {"type":"labelapp","icon":"AutoMode","text":"Plant & Harvest"},
    {"type":"input_string","text":"Koordinat PTHT X,Y","default":"9,11","label":"Position","placeholder":"9,11","icon":"LocationOn","alias":"TileRemoteXY"},
    {"type":"dialog","text":"PTHT Settings","support_text":"Click to open","fill":false,"menu":[
      {"type":"labelapp","icon":"Settings","text":"Setting PTHT"},
      {"type":"slider","text":"Delay Plant","min":0,"max":300,"default":50,"use_dot":false,"step":50,"alias":"DelayPT"},
      {"type":"slider","text":"Delay Harvest","min":0,"max":300,"default":50,"use_dot":false,"step":30,"alias":"DelayHT"},
      {"type":"slider","text":"Delay Ultra World Spray","min":0,"max":2000,"default":800,"use_dot":false,"step":20,"alias":"DelayUWS"},
      {"type":"item_picker","text":"Seed Plant","item":"5640","default":"5640","alias":"SeedID"},
      {"type":"item_picker","text":"Seed Harvest","item":"No Yet","default":"341","alias":"CropID"},
      {"type":"input_int","text":"ItemID Plat","default":"7520","label":"Value","placeholder":"hold 1","icon":"Menu","alias":"PlatID"}
    ]},
    {"type":"toggle_button","text":"Only Plant","alias":"PlantToggle","default":true},
    {"type":"toggle_button","text":"Only Harvest","alias":"HarvestToggle","default":true},
    {"type":"label","text":""},
    {"type":"toggle_button","text":"Start PTHT","alias":"PTHTToggle","default":false},
    {"type":"divider"},
    {"type":"labelapp","icon":"SmartToy","text":"Automatic"},
    {"type":"dialog","text":"PNB Settings","support_text":"Click to open","fill":true,"menu":[
      {"type":"labelapp","icon":"Settings","text":"PNB Setting"},
      {"type":"toggle","text":"Break To Right","alias":"PNB_Right","default":true},
      {"type":"toggle","text":"Break To Left","alias":"PNB_Left","default":false},
      {"type":"item_picker","text":"Place Block","item":"5640","default":"5640","alias":"PNB_ID"},
      {"type":"input_int","text":"Delay(ms)","default":"120","label":"Value","placeholder":"hold 3","icon":"Timer","alias":"PNB_Delay"},
      {"type":"slider","text":"Range Far","min":1,"max":10,"default":5,"use_dot":true,"step":5,"alias":"PNB_Far"}
    ]},
    {"type":"input_string","text":"Koordinat Magplant X,Y","default":"9,116","label":"Position","placeholder":"9,116","icon":"LocationOn","alias":"MagKoor"},
    {"type":"dialog","text":"Retrieve Mag Settings","support_text":"Click to open","fill":true,"menu":[
      {"type":"labelapp","icon":"Settings","text":"Retrieve Magplant Settings"},
      {"type":"toggle","text":"Auto Save Koordinat Magplant","alias":"CekKoor","default":false},
      {"type":"item_picker","text":"Item to Drop","item":"No Yet","default":"0","alias":"MagDrop"},
      {"type":"input_int","text":"Delay(ms)","default":"250","label":"Value","placeholder":"hold 3","icon":"Timer","alias":"DelayMAG"}
    ]},
    {"type":"toggle_button","text":"Start Retrivie Mag & Drop","alias":"MAGToggle","default":false},
    {"type":"label","text":""},
    {"type":"toggle_button","text":"Start PNB","alias":"PNBToggle","default":false},
    {"type":"divider"},
    {"type":"labelapp","icon":"ToggleOn","text":"Other Toggle"},
    {"type":"dialog","text":"Toggle Settings","support_text":"Click to open","fill":false,"menu":[
      {"type":"labelapp","icon":"Settings","text":"Others"},
      {"type":"toggle","text":"Auto Leave","alias":"AutoLeave","default":false},
      
{"type":"toggle","text":"ModFly","alias":"ModFly","default":false},
{"type":"toggle","text":"Koordinat","alias":"LihatKoor","default":false},
      {"type":"toggle","text":"Anti Lag","alias":"Antilag","default":false},
      {"type":"toggle","text":"No Particle","alias":"NoParticle","default":true},
      {"type":"toggle","text":"Ultra World Spray","alias":"UWSToggle","default":true}
    ]}
  ]
}
]]
addIntoModule(json)

local save, load
if SetVar and GetVar then
  save = function(k, v) SetVar(k, v) end
  load = function(k) return GetVar(k) end
elseif SetLocal and GetLocal then
  save = function(k, v) SetLocal(k, v) end
  load = function(k) return GetLocal(k) end
elseif SetConfig and GetConfig then
  save = function(k, v) SetConfig(k, v) end
  load = function(k) return GetConfig(k) end
elseif SetSetting and GetSetting then
  save = function(k, v) SetSetting(k, v) end
  load = function(k) return GetSetting(k) end
else
  save = function() end
  load = function() return nil end
end

AutoSaveMag = true
LihatKoor = false
-- load saved MagTile coords (do not overwrite TileRemote)
local sx = tonumber(load("MagTile_x"))
local sy = tonumber(load("MagTile_y"))
if sx and sy then
  MagTile.x = sx
  MagTile.y = sy
  Mag_X = sx
  Mag_Y = sy
  LogToConsole("9[INIT]w Loaded saved MagTile X=" .. sx .. " Y=" .. sy)
end

function toBool(v)
  return v == true or v == "true" or v == 1 or v == "1"
end

function getWorldSize()
  if string.lower(WorldType or "") == "normal" then
    return 199, 199
  else
    return 199, 199
  end
end

local function toItemId(v)
  if type(v) == "number" then return v end
  if type(v) == "string" then
    local n = tonumber(v)
    if n then return n end
    if growtopia and growtopia.getItemID then return growtopia.getItemID(v) end
  elseif type(v) == "table" then
    if v.id then return toItemId(v.id) end
    if v.itemid then return toItemId(v.itemid) end
    if v.itemID then return toItemId(v.itemID) end
    if v[1] then return toItemId(v[1]) end
  end
  return nil
end

function place(x, y, id)
  SendPacketRaw(false, { 
  x = x * 32, 
  y = y * 32, 
  px = x, 
  py = y, 
  type = 3, 
  value = SeedID 
  })
end

function punch(x, y)
  SendPacketRaw(false, { x = x * 32, y = y * 32, px = x, py = y, type = 3, value = 18 })
end

function takeRemote(x, y)
  local pkt = string.format([[action|dialog_return
dialog_name|itemsucker_block
tilex|%d|
tiley|%d|
buttonClicked|getplantationdevice
]], x, y)
  SendPacket(2, pkt)
  Sleep(500)
end

function findPath(x, y)
  FindPath(x, y)
  Sleep(DelayPT)
end

function placeSeed(x, y)
    local pkt = {type = 3, px = x, py = y, x = x * 32, y = y * 32, value = seedid}
    SendPacketRaw(false, pkt)
end

function break_tile(x, y)
  SendPacketRaw(false, { state = 32, x = x * 32, y = y * 32 })
  SendPacketRaw(false, { type = 3, value = 18, px = x, py = y, x = x * 32, y = y * 32 })
  Sleep(DelayHT)
end

function useUWS()
  if not UWSToggle then return end
  SendPacket(2, "action|dialog_return\ndialog_name|world_spray\n")
  Sleep(DelayUWS)
end

AddHook(function(_, alias, val)
  if alias == "SeedID" or alias == "MagDrop" then
    LogToConsole("`9[AutoSet]`w" .. tostring(alias) .. " => " .. tostring(val))
  end

  local function applyItemPicker(a)
    local id = toItemId(val)
    if id then
      if a == "SeedID" then SeedID = id
      elseif a == "CropID" then CropID = id
      elseif a == "PlatID" then PlatID = id
      elseif a == "PNB_ID" then PNB_ID = id
      elseif a == "MagDrop" then MagDrop = id
      end
     
    end
  end

  if alias == "SeedID" then applyItemPicker("SeedID") return
  elseif alias == "CropID" then applyItemPicker("CropID") return
  elseif alias == "PlatID" then applyItemPicker("PlatID") return
  elseif alias == "PNB_ID" then applyItemPicker("PNB_ID") return
  elseif alias == "MagDrop" then applyItemPicker("MagDrop") return
  end

  if alias == "TileRemoteXY" then
    local sx, sy = tostring(val):match("(%-?%d+)%s*,%s*(%-?%d+)")
    if sx and sy then
      local x = tonumber(sx); local y = tonumber(sy)
      TileRemote.x = x; TileRemote.y = y
      
    end
    return
  end

  if alias == "MagKoor" then
    local sx, sy = tostring(val):match("(%-?%d+)%s*,%s*(%-?%d+)")
    if sx and sy then
      MagTile.x = tonumber(sx); MagTile.y = tonumber(sy)
      Mag_X = MagTile.x; Mag_Y = MagTile.y
     
    end
    return
  end

  if alias == "DelayPT" then DelayPT = tonumber(val) or DelayPT; return end
  if alias == "DelayHT" then DelayHT = tonumber(val) or DelayHT; return end
  if alias == "DelayUWS" then DelayUWS = tonumber(val) or DelayUWS; return end
  if alias == "DelayMAG" then DelayMAG = tonumber(val) or DelayMAG; return end
  if alias == "PNB_Delay" then PNB_Delay = tonumber(val) or PNB_Delay; return end
  if alias == "PNB_Far" then PNB_Far = tonumber(val) or PNB_Far; return end

  if alias == "AutoLeave" then AutoLeaveEnabled = (val == true); return end
  if alias == "PlantToggle" then PlantToggle = (val == true); return end
  if alias == "HarvestToggle" then HarvestToggle = (val == true); return end
  if alias == "UWSToggle" then UWSToggle = (val == true); return end
  if alias == "VerticalToggle" then VerticalToggle = (val == true); return end
  if alias == "PTHTToggle" then PTHTToggle = (val == true); return end
  if alias == "PNBToggle" then PNBToggle = (val == true); return end
  if alias == "MAGToggle" then MAGToggle = (val == true); return end
  if alias == "CekKoor" then CekKoor = (val == true); return end
  if alias == "AutoSaveMag" then AutoSaveMag = (val == true); return end
  if alias == "LihatKoor" then LihatKoor = (val == true); return end
  if alias == "DayyCollect" then DayyCollect = (val == true); return end

  if alias == "PNB_Right" then PNB_Right = toBool(val); return end
  if alias == "PNB_Left" then PNB_Left = toBool(val); return end
  if alias == "PNB_ID" then PNB_ID = toItemId(val) or PNB_ID; return end

  if alias == "Antilag" then
    local b = (val == true)
    if b ~= LastAntilag then EditToggle("Antilag", b); LastAntilag = b end
    return
  end
  if alias == "NoParticle" then
    local b = (val == true)
    if b ~= LastNoParticle then EditToggle("No Particle", b); LastNoParticle = b end
    return
  end
  if alias == "ModFly" then
    local b = (val == true)
    if b ~= LastModFly then EditToggle("ModFly", b); LastModFly = b end
    return
  end
end, "onValue")

-------------------------
-- PNB thread (auto place & break)
-------------------------

runThread(function()
  while true do
    if not PNBToggle then
      Sleep(200)
    else
      local sx = math.floor(GetLocal().posX / 32)
      local sy = math.floor(GetLocal().posY / 32)
      for i = 1, PNB_Far do
        if not PNBToggle then break end
        if PNB_Right then place(sx + i, sy, PNB_ID); punch(sx + i, sy) end
        if PNB_Left then place(sx - i, sy, PNB_ID); Sleep(5); punch(sx - i, sy) end
        Sleep(PNB_Delay)
      end
    end
  end
end)
-------------------------
-- PTHT main thread
-------------------------
local function checkMissPlant(W, H)
  local missCount = 0
  for y = 0, H do
    if not PTHTToggle then return missCount end
    for x = 0, W do
      if not PTHTToggle then return missCount end
      local tile = GetTile(x, y)
      if tile and tile.fg == PlatID then
        local above = GetTile(x, y - 1)
        if above and above.fg == 0 then
          findPath(y, x - 1)
          plantHere(y, x - 1, SeedID)
          missCount = missCount + 1
          Sleep(50)
        end
      end
    end
  end
  return missCount
end

-- Plant yang mau di add
function PTHT_Plant()
  for _, tile in pairs(GetTiles()) do
    if not PTHTToggle or not PlantToggle then return end

    if tile.fg == 0 then
      local below = GetTile(tile.x, tile.y + 1)
      if below and below.fg == PlatID then
        SendPacketRaw(false, {
          type = 3,
          px = tile.x, 
          py = tile.y,
          x = tile.x * 32, 
          y = tile.y * 32,
          value = SeedID
        })
        Sleep(DelayPT)
      end
    end
  end
end

function PTHT_Harvest()
  local W, H = getWorldSize()

  for x = 0, W do
    if not PTHTToggle or not HarvestToggle then return end

    local miss
    repeat
      miss = 0
      for y = 0, H do
        local tile = GetTile(x, y)
        if tile and tile.fg == CropID and tile.readyharvest then
          SendPacketRaw(false, {
            state = 32,
            px = x, py = y,
            x = x * 32, y = y * 32
          })
          SendPacketRaw(false, {
            type = 3,
            value = 18,
            px = x, py = y,
            x = x * 32, y = y * 32
          })
          Sleep(DelayHT)

          tile = GetTile(x, y)
          if tile and tile.fg == CropID and tile.readyharvest then
            miss = miss + 1
          end
        end
      end
    until miss == 0
  end
end

runThread(function()
  while true do
    if not PTHTToggle then
      Sleep(300)
    else
takeRemote(TileRemote.x, TileRemote.y)
      local W, H = getWorldSize()
      

      -- 1️⃣ PLANT
      if PlantToggle then
        PTHT_Plant()

        -- 2️⃣ CHECK MISS (WAJIB SETELAH PLANT)
        local miss
        repeat
          miss = checkMissPlant(W, H)
        until miss == 0
      end

      -- 3️⃣ UWS (OPTIONAL VIA TOGGLE)
      if UWSToggle then
        useUWS()
      end

      -- 4️⃣ HARVEST
      if HarvestToggle then
        PTHT_Harvest()
      end

      Sleep(500)
    end
  end
end)

----------------------------------
-- PTHT LAMA
------------------------------------



local function Ret(x, y)
  local pkt = string.format([[action|dialog_return
dialog_name|itemremovedfromsucker
tilex|%d|
tiley|%d|
itemtoremove|200
]], x, y)
  SendPacket(2, pkt)
end

local function Drop(itemID)
  if not itemID or tonumber(itemID) == 0 then return end
  local pkt = string.format([[action|dialog_return
dialog_name|drop_item
itemID|%d|
count|200
]], itemID)
  SendPacket(2, pkt)
end

AddHook(function(pkt)

    -- kita filter dulu packet punch
    if pkt.type == 3 and pkt.value == 18 then
        local tileX = pkt.px
        local tileY = pkt.py

        -- =========================
        -- CEK KOOR (SAVE MAG)
        -- =========================
        if CekKoor then
            if growtopia and growtopia.notify then
                growtopia.notify("`9[SaveMag] `cX:" .. tileX .. "`w|`cY:" .. tileY)
            end

            MagTile.x = tileX
            MagTile.y = tileY
            Mag_X = tileX
            Mag_Y = tileY

            LogToConsole("`9[MAG] `wMag_X=" .. Mag_X .. " Mag_Y=" .. Mag_Y)

            if AutoSaveMag then
                save("MagTile_x", tostring(MagTile.x))
                save("MagTile_y", tostring(MagTile.y))
            end
        end

        -- =========================
        -- LIHAT KOOR (HANYA DISPLAY)
        -- =========================
        if LihatKoor then
            if growtopia and growtopia.notify then
                growtopia.notify("`5[Lihat] `cX:" .. tileX .. "`w|`cY:" .. tileY)
            end
        end
    end

end, "OnSendPacketRaw")

runThread(function()
  while true do
    if not MAGToggle then
      Sleep(300)
    else
      local x = MagTile.x or Mag_X or 0
      local y = MagTile.y or Mag_Y or 0
      local itemID = tonumber(MagDrop) or 0
      local delay = tonumber(DelayMAG) or 250

      if x == 0 and y == 0 then
        
        Sleep(1000)
      else
       
        pcall(function() Ret(x, y) end)
        Sleep(delay)
        if itemID > 0 then
          pcall(function() Drop(itemID) end)
          Sleep(delay)
        end
      end
    end
  end
end)


AddHook(function(ev)
  if ev.v1 == "OnSpawn" and AutoLeaveEnabled then
    local data = ev.v2 or ""
    if data:find("spawn|avatar") then
      local name = data:match("name|(.-)|") or "Unknown"
      LogToConsole("`b[AutoLeave] `4Keluar Karena Ada `w" .. name .. " `4Join World")
      SendPacket(3, "action|quit_to_exit")
      CSleep(200)
    end
  end
end, "OnVariant")

