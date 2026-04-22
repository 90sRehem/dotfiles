-- Utilitário centralizado para detecção inteligente de linters (ESLint vs Biome)
-- Otimizado para monorepos e projetos complexos

local M = {}

-- Debug logging (pode ser desabilitado via vim.g.linter_detection_debug = false)
local function debug_log(message, data)
  if vim and vim.g and vim.g.linter_detection_debug then
    local log_data = data and vim.inspect(data) or ""
    if vim.notify then
      vim.notify(string.format("[LinterDetection] %s %s", message, log_data), vim.log.levels.DEBUG)
    end
  end
end

-- Cache para evitar múltiplas detecções do mesmo arquivo
local detection_cache = {}

-- Limpar cache quando necessário
function M.clear_cache()
  detection_cache = {}
  debug_log("Cache cleared")
end

-- Função para verificar se um arquivo existe e ler seu conteúdo
local function read_file_content(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return nil
  end
  local content = file:read("*all")
  file:close()
  return content
end

-- Função para verificar se um package.json contém ESLint
local function has_eslint_in_package_json(package_json_path)
  local content = read_file_content(package_json_path)
  if not content then
    return false
  end
  
  -- Verificar se contém eslint em dependencies, devDependencies ou scripts
  local has_eslint = content:match('"eslint"') 
    or content:match('"@eslint/') 
    or content:match('"eslint:') 
    or content:match('"lint":[^}]*eslint')
  
  debug_log("Checking package.json for ESLint", {
    path = package_json_path,
    has_eslint = has_eslint,
  })
  
  return has_eslint ~= nil
end

-- Função para verificar se um biome.json está configurado para ser usado
local function is_biome_config_active(biome_json_path)
  local content = read_file_content(biome_json_path)
  if not content then
    return false
  end
  
  -- Parse básico para verificar se linter está habilitado
  local has_linter = content:match('"linter"[^}]*"enabled"[^}]*true') 
    or content:match('"enabled"[^}]*true[^}]*"linter"')
    or not content:match('"linter"[^}]*"enabled"[^}]*false') -- Default é true
  
  debug_log("Checking biome.json config", {
    path = biome_json_path,
    has_linter = has_linter,
  })
  
  return has_linter
end

-- Função para normalizar caminhos
local function normalize_path(path)
  if vim and vim.fn then
    return vim.fn.fnamemodify(path, ":p")
  else
    -- Fallback básico para testes
    if not string.sub(path, 1, 1) == "/" then
      path = "/" .. path
    end
    return path
  end
end

-- Função para obter diretório pai
local function get_parent_dir(file_path)
  if vim and vim.fn then
    return vim.fn.fnamemodify(file_path, ":h")
  else
    -- Fallback básico
    return string.match(file_path, "(.*/)")
  end
end

-- Função para verificar se string começa com prefixo
local function starts_with(str, prefix)
  if vim and vim.startswith then
    return vim.startswith(str, prefix)
  else
    return string.sub(str, 1, #prefix) == prefix
  end
end

-- Função para calcular a distância entre dois diretórios
local function calculate_distance(file_path, config_root)
  if not config_root or not file_path then
    return math.huge
  end
  
  local file_dir = get_parent_dir(file_path)
  local config_normalized = normalize_path(config_root)
  local file_normalized = normalize_path(file_dir)
  
  -- Se o arquivo não está dentro do config root, retorna infinito
  if not starts_with(file_normalized, config_normalized) then
    return math.huge
  end
  
  local relative_path = string.sub(file_normalized, #config_normalized + 1)
  local distance = select(2, string.gsub(relative_path, "/", "")) + 1
  
  debug_log("Distance calculation", {
    file_path = file_normalized,
    config_root = config_normalized,
    relative_path = relative_path,
    distance = distance,
  })
  
  return distance
end

-- Função para encontrar root pattern (fallback para quando não tem lspconfig.util)
local function find_root_pattern(patterns, start_path)
  if not start_path then
    return nil
  end
  
  if vim and vim.fn then
    -- No contexto do Neovim, usar lspconfig.util
    local ok, util = pcall(require, "lspconfig.util")
    if ok then
      return util.root_pattern(unpack(patterns))(start_path)
    end
  end
  
  -- Fallback básico para teste fora do Neovim
  local current_dir = get_parent_dir(start_path)
  while current_dir and current_dir ~= "/" do
    for _, pattern in ipairs(patterns) do
      local config_path = current_dir .. "/" .. pattern
      local file = io.open(config_path, "r")
      if file then
        file:close()
        return current_dir
      end
    end
    
    local parent = string.match(current_dir, "^(.*/)[^/]+/?$")
    if parent == current_dir then break end
    current_dir = parent and parent:gsub("/$", "") or nil
  end
  
  return nil
end

-- Função principal para encontrar configurações de linter
function M.find_linter_config(file_path)
  if not file_path then
    return { use_biome = false, use_eslint = false }
  end
  
  -- Verificar cache primeiro
  local cache_key = file_path
  if detection_cache[cache_key] then
    debug_log("Using cached result", { file_path = file_path, result = detection_cache[cache_key] })
    return detection_cache[cache_key]
  end
  
  -- Padrões de configuração ESLint (ordem de prioridade)
  local eslint_patterns = {
    ".eslintrc.json",
    ".eslintrc.js", 
    ".eslintrc.cjs",
    ".eslintrc.mjs",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc",
    "eslint.config.js",
    "eslint.config.mjs", 
    "eslint.config.cjs",
  }
  
  -- Padrões de configuração Biome
  local biome_patterns = {
    "biome.json",
    "biome.jsonc",
  }
  
  -- Encontrar todas as configurações ESLint
  local eslint_configs = {}
  for _, pattern in ipairs(eslint_patterns) do
    local root = find_root_pattern({pattern}, file_path)
    if root then
      table.insert(eslint_configs, {
        root = root,
        config_file = root .. "/" .. pattern,
        distance = calculate_distance(file_path, root),
        pattern = pattern,
      })
    end
  end
  
  -- Verificar package.json como fallback para ESLint
  local package_json_root = find_root_pattern({"package.json"}, file_path)
  if package_json_root and has_eslint_in_package_json(package_json_root .. "/package.json") then
    table.insert(eslint_configs, {
      root = package_json_root,
      config_file = package_json_root .. "/package.json",
      distance = calculate_distance(file_path, package_json_root),
      pattern = "package.json",
    })
  end
  
  -- Encontrar todas as configurações Biome
  local biome_configs = {}
  for _, pattern in ipairs(biome_patterns) do
    local root = find_root_pattern({pattern}, file_path)
    if root then
      local config_path = root .. "/" .. pattern
      if is_biome_config_active(config_path) then
        table.insert(biome_configs, {
          root = root,
          config_file = config_path,
          distance = calculate_distance(file_path, root),
          pattern = pattern,
        })
      end
    end
  end
  
  -- Ordenar por distância (mais próximo primeiro)
  table.sort(eslint_configs, function(a, b) return a.distance < b.distance end)
  table.sort(biome_configs, function(a, b) return a.distance < b.distance end)
  
  local result = { use_biome = false, use_eslint = false }
  
  -- Determinar qual usar baseado em prioridade e distância
  local closest_eslint = eslint_configs[1]
  local closest_biome = biome_configs[1]
  
  if closest_eslint and closest_biome then
    -- Ambos encontrados - usar o mais próximo, com preferência para ESLint em caso de empate
    if closest_eslint.distance <= closest_biome.distance then
      result.use_eslint = true
      result.eslint_root = closest_eslint.root
      result.eslint_config = closest_eslint.config_file
    else
      result.use_biome = true
      result.biome_root = closest_biome.root
      result.biome_config = closest_biome.config_file
    end
  elseif closest_eslint then
    -- Apenas ESLint encontrado
    result.use_eslint = true
    result.eslint_root = closest_eslint.root
    result.eslint_config = closest_eslint.config_file
  elseif closest_biome then
    -- Apenas Biome encontrado
    result.use_biome = true
    result.biome_root = closest_biome.root
    result.biome_config = closest_biome.config_file
  end
  
  debug_log("Linter detection result", {
    file_path = file_path,
    eslint_configs_found = #eslint_configs,
    biome_configs_found = #biome_configs,
    result = result,
  })
  
  -- Armazenar no cache
  detection_cache[cache_key] = result
  return result
end

-- Função de conveniência para verificar se deve usar Biome
function M.should_use_biome(file_path)
  local config = M.find_linter_config(file_path)
  return config.use_biome
end

-- Função de conveniência para verificar se deve usar ESLint
function M.should_use_eslint(file_path)
  local config = M.find_linter_config(file_path)
  return config.use_eslint
end

-- Função para obter root directory do Biome
function M.get_biome_root(file_path)
  local config = M.find_linter_config(file_path)
  return config.use_biome and config.biome_root or nil
end

-- Função para obter root directory do ESLint
function M.get_eslint_root(file_path)
  local config = M.find_linter_config(file_path)
  return config.use_eslint and config.eslint_root or nil
end

-- Comandos para debug (somente quando no contexto do Neovim)
if vim and vim.api then
  -- Comando para debug da detecção
  vim.api.nvim_create_user_command("LinterDetectionDebug", function()
    local file_path = vim.fn.expand("%:p")
    if file_path == "" then
      vim.notify("No file open", vim.log.levels.WARN)
      return
    end
    
    vim.g.linter_detection_debug = true
    M.clear_cache()
    
    local config = M.find_linter_config(file_path)
    
    vim.notify(string.format(
      "Linter Detection for %s:\n" ..
      "Use Biome: %s (root: %s)\n" ..
      "Use ESLint: %s (root: %s)",
      file_path,
      config.use_biome and "YES" or "NO",
      config.biome_root or "N/A",
      config.use_eslint and "YES" or "NO", 
      config.eslint_root or "N/A"
    ), vim.log.levels.INFO)
    
    vim.g.linter_detection_debug = false
  end, { desc = "Debug linter detection for current file" })

  -- Comando para limpar cache
  vim.api.nvim_create_user_command("LinterDetectionClearCache", function()
    M.clear_cache()
    vim.notify("Linter detection cache cleared", vim.log.levels.INFO)
  end, { desc = "Clear linter detection cache" })
end

return M