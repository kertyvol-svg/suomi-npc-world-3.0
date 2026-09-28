local Cases = {}
local Evidence = {}

local function createCase(data)
  local case = {
    id = data.id or ('case_' .. tostring(os.time()) .. '_' .. tostring(math.random(1000, 9999))),
    caseNumber = data.caseNumber or ('2026-' .. tostring(math.random(10000, 99999))),
    title = data.title or 'Untitled Case',
    description = data.description or '',
    crimeType = data.crimeType or 'unknown',
    location = data.location or 'Unknown',
    suspect = data.suspect or nil,
    witnesses = data.witnesses or {},
    evidence = data.evidence or {},
    status = data.status or 'open',
    createdAt = os.date('%Y-%m-%d %H:%M:%S'),
    createdBy = data.createdBy or 'Officer',
    priority = data.priority or 'medium'
  }

  Cases[case.id] = case

  if Config.debug then
    print(('[evidence_system] Created case %s | %s | Status: %s'):format(case.caseNumber, case.title, case.status))
  end

  return case
end

local function createEvidence(data)
  local evidence = {
    id = data.id or ('evidence_' .. tostring(os.time()) .. '_' .. tostring(math.random(1000, 9999))),
    caseId = data.caseId,
    type = data.type or 'unknown',
    description = data.description or '',
    foundAt = data.foundAt or 'Unknown',
    foundBy = data.foundBy or 'Officer',
    collectedAt = os.date('%Y-%m-%d %H:%M:%S'),
    analysisStatus = data.analysisStatus or 'pending',
    result = data.result or nil,
    linkedTo = data.linkedTo or {}
  }

  Evidence[evidence.id] = evidence

  if Cases[data.caseId] then
    table.insert(Cases[data.caseId].evidence, evidence.id)
  end

  if Config.debug then
    print(('[evidence_system] Created evidence %s | Type: %s | Case: %s'):format(evidence.id, evidence.type, data.caseId))
  end

  return evidence
end

local function addEvidenceToCase(caseId, evidenceId)
  if Cases[caseId] and Evidence[evidenceId] then
    table.insert(Cases[caseId].evidence, evidenceId)
    Evidence[evidenceId].caseId = caseId
    return true
  end
  return false
end

local function linkEvidenceToWitness(evidenceId, witnessId)
  if Evidence[evidenceId] then
    table.insert(Evidence[evidenceId].linkedTo, { type = 'witness', id = witnessId })
    return true
  end
  return false
end

local function linkEvidenceToSuspect(evidenceId, suspectId)
  if Evidence[evidenceId] then
    table.insert(Evidence[evidenceId].linkedTo, { type = 'suspect', id = suspectId })
    return true
  end
  return false
end

local function getCase(caseId)
  return Cases[caseId]
end

local function getCases()
  local list = {}
  for _, case in pairs(Cases) do
    table.insert(list, case)
  end
  return list
end

local function getEvidence(evidenceId)
  return Evidence[evidenceId]
end

local function updateCaseStatus(caseId, status)
  if Cases[caseId] then
    Cases[caseId].status = status
    return true
  end
  return false
end

local function analyzeEvidence(evidenceId, result)
  if Evidence[evidenceId] then
    Evidence[evidenceId].analysisStatus = 'complete'
    Evidence[evidenceId].result = result
    return true
  end
  return false
end

RegisterNetEvent('evidence_system:server:createCase', function(data)
  local src = source
  local case = createCase(data)
  TriggerClientEvent('evidence_system:client:caseCreated', src, case)
end)

RegisterNetEvent('evidence_system:server:createEvidence', function(data)
  local src = source
  local evidence = createEvidence(data)
  TriggerClientEvent('evidence_system:client:evidenceCreated', src, evidence)
end)

RegisterNetEvent('evidence_system:server:addEvidenceToCase', function(caseId, evidenceId)
  addEvidenceToCase(caseId, evidenceId)
end)

RegisterNetEvent('evidence_system:server:linkEvidenceToWitness', function(evidenceId, witnessId)
  linkEvidenceToWitness(evidenceId, witnessId)
end)

RegisterNetEvent('evidence_system:server:linkEvidenceToSuspect', function(evidenceId, suspectId)
  linkEvidenceToSuspect(evidenceId, suspectId)
end)

RegisterNetEvent('evidence_system:server:getCase', function(caseId)
  local src = source
  local case = getCase(caseId)
  TriggerClientEvent('evidence_system:client:caseData', src, case)
end)

RegisterNetEvent('evidence_system:server:getCases', function()
  local src = source
  local cases = getCases()
  TriggerClientEvent('evidence_system:client:casesData', src, cases)
end)

RegisterNetEvent('evidence_system:server:updateCaseStatus', function(caseId, status)
  updateCaseStatus(caseId, status)
end)

exports('createCase', createCase)
exports('createEvidence', createEvidence)
exports('addEvidenceToCase', addEvidenceToCase)
exports('linkEvidenceToWitness', linkEvidenceToWitness)
exports('linkEvidenceToSuspect', linkEvidenceToSuspect)
exports('getCase', getCase)
exports('getCases', getCases)
exports('getEvidence', getEvidence)
exports('updateCaseStatus', updateCaseStatus)
exports('analyzeEvidence', analyzeEvidence)
