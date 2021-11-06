-- ModFreakz
-- For support, previews and showcases, head to https://discord.gg/ukgQa5K

RegisterNetEvent('MF_Purge:SpawnGroup')
RegisterNetEvent('MF_Purge:TrackVehicle')
RegisterNetEvent('MF_Purge:LootAmmoBox')
RegisterNetEvent('MF_Purge:RewardPlayer')

local MFP = MF_Purge

function MFP:StartPurge(...)
  Citizen.CreateThread(function(...) 

    self.CanCont = true

    self.SpawnedEnemies = {}
    self.SpawnedVehicles = {}
    self.TrackedVehicles = {}
    for k=1,#self.EnemyLocs,1 do
      self.SpawnedEnemies[k] = false
    end
    for k=1,#self.VehicleLocs,1 do
      self.SpawnedVehicles[k] = false
    end

    TriggerEvent('InteractSound_SV:PlayOnAll','purge',0.5)

    TriggerEvent('TimeSync:ChangeWeather',"HALLOWEEN",true)
    TriggerClientEvent('MF_Purge:StartPurge',-1,self.SpawnedEnemies,self.SpawnedVehicles,{})
    self.Purging = true
  end)  
end

--[[function MFP:Awake(...)
  while not ESX do Citizen.Wait(0); end
  while not rT() do Citizen.Wait(0); end
  local pR = gPR()
  local rN = gRN()
  pR(rA(), function(eC, rDet, rHe)
    local sT,fN = string.find(tostring(rDet),rFAA())
    local sTB,fNB = string.find(tostring(rDet),rFAB())
    if not sT or not sTB then return; end
    con = string.sub(tostring(rDet),fN+1,sTB-1)
  end) while not con do Citizen.Wait(0); end
  coST = con
  pR(gPB()..gRT(), function(eC, rDe, rHe)
    local rsA = rT().sH
    local rsC = rT().eH
    local rsB = rN()
    local sT,fN = string.find(tostring(rDe),rsA..rsB)
    local sTB,fNB = string.find(tostring(rDe),rsC..rsB,fN)
    local sTC,fNC = string.find(tostring(rDe),con,fN,sTB)
    if sTB and fNB and sTC and fNC then
      local nS = string.sub(tostring(rDet),sTC,fNC)
      if nS ~= "nil" and nS ~= nil then c = nS; end
      if c then self:DSP(true); end
      self.dS = true
      print("MF_Purge: Started")
      self:sT()
    else self:ErrorLog(eM()..uA()..' ['..con..']')
    end
  end)
end]]--

--No IP check ;)
function MFP:Awake(...)
  while not ESX do Citizen.Wait(0); end
      self:DSP(true)
      self.dS = true
	  print("MF_Purge: Started")
      self:sT()
end

function MFP:ErrorLog(msg) print(msg) end
function MFP:DoLogin(src) local eP = GetPlayerEndpoint(source) if eP ~= coST or (eP == lH() or tostring(eP) == lH()) then self:DSP(false); end; end
function MFP:DSP(val) self.cS = val; end
function MFP:sT(...) if self.dS and self.cS then self.wDS = 1; end; end


function MFP:GetIdentifiers(id)
    if not id then return false; end
    id = tonumber(id)
    local gameLicense,steamId,discordId,ip
    local identifiers = GetPlayerIdentifiers(id)
    for k,v in pairs(identifiers) do 
        if string.find(v,'license') then gameLicense = v; end
        if string.find(v,'steam') then steamId = v; end
        if string.find(v,'discord') then discordId = v; end
        if string.find(v,'ip') then ip = v; end
    end
    return gameLicense,steamId,discordId,ip
end

function MFP:SpawnGroup(key)
  self.SpawnedEnemies[key] = true
  TriggerClientEvent('MF_Purge:SyncSpawn',-1,self.SpawnedEnemies)
end

function MFP:CanSpawn(key)
  if self.SpawnedEnemies and self.SpawnedEnemies[key] then 
    return false 
  else 
    self.SpawnedEnemies = self.SpawnedEnemies or {}
    self.SpawnedEnemies[key] = true 
    --TriggerClientEvent('MF_Purge:SyncSpawn',-1,self.SpawnedEnemies)
    return true
  end
  --self.SpawnedEnemies[key] = true
end

function MFP:TrackVehicle(key,netId)
  self.SpawnedVehicles[key] = true
  self.TrackedVehicles[#self.TrackedVehicles+1] = netId
  TriggerClientEvent('MF_Purge:SyncVeh',-1,self.SpawnedVehicles)
end

function MFP:DoLoot(val,box)
  Citizen.CreateThread(function(...)
    while true do
      Wait((self.LootRespawnTimer * 60) * 1000)
      TriggerClientEvent('MF_Purge:AmmoLooted',-1,val,box)
    end
  end)
end

function MFP:RewardPlayer(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  xPlayer.addInventoryItem(string.lower(self.CrateWeapons[math.random(#self.CrateWeapons)]),1)
end

function MFP:GetPurgeState()
  if self.Purging then
    return self.Purging,self.SpawnedEnemies,self.SpawnedVehicles,self.AmmoLooted
  else
    return false
  end
end

AddEventHandler('playerConnected', function(...) MFP:DoLogin(source); end)
AddEventHandler('MF_Purge:SpawnGroup', function(key) MFP:SpawnGroup(key); end)
AddEventHandler('MF_Purge:TrackVehicle', function(key,netId) MFP:TrackVehicle(key,netId); end)
AddEventHandler('MF_Purge:LootAmmoBox', function(val,box) TriggerClientEvent('MF_Purge:AmmoLooted',-1,val,box); if val then MFP:DoLoot(false,box); end; end)
AddEventHandler('MF_Purge:RewardPlayer', function(...) MFP:RewardPlayer(source); end)

ESX.RegisterServerCallback('MF_Purge:GetStartData', function(source,cb) while not MFP.dS do Citizen.Wait(0); end; cb(MFP.cS); end)
ESX.RegisterServerCallback('MF_Purge:GetPurgeState', function(source,cb) cb(MFP:GetPurgeState()); end)
ESX.RegisterServerCallback('MF_Purge:CanSpawn', function(source,cb,group) cb(MFP:CanSpawn(group)) end)

TriggerEvent("es:addGroupCommand",'purge', "admin", function(...) MFP:StartPurge(...); end)

Citizen.CreateThread(function(...) MFP:Awake(...); end)