-- =============================================================================
-- Flow Deep Icon Theme for Minimal (Authentic port of Flow Icons - Deep variant)
-- Palette & semantic file/folder mappings tailored for Neovim / Neovide
-- =============================================================================

local M = {}

-- Exact Flow Icons "Deep" 14-color palette
M.palette = {
  white = "#bfbdb6",
  black = "#0d1017",
  blue = "#59c2ff",
  brown = "#e6c08a",
  gray = "#667381",
  gray_open = "#808e9c",
  gray_empty = "#525d69",
  green = "#aad94c",
  lime = "#c0e76e",
  orange = "#ff8f40",
  pink = "#f6adae",
  purple = "#d2a6ff",
  red = "#f07178",
  sky = "#39bae6",
  teal = "#95e6cb",
  yellow = "#ffcb8f",
}

local P = M.palette

-- Chromatic + neutral anchors used to harmonize all remaining built-in devicons
local QUANTIZE_TARGETS = {
  { hex = P.white, r = 0xbf, g = 0xbd, b = 0xb6 },
  { hex = P.gray, r = 0x66, g = 0x73, b = 0x81 },
  { hex = P.blue, r = 0x59, g = 0xc2, b = 0xff },
  { hex = P.sky, r = 0x39, g = 0xba, b = 0xe6 },
  { hex = P.teal, r = 0x95, g = 0xe6, b = 0xcb },
  { hex = P.green, r = 0xaa, g = 0xd9, b = 0x4c },
  { hex = P.lime, r = 0xc0, g = 0xe7, b = 0x6e },
  { hex = P.yellow, r = 0xff, g = 0xcb, b = 0x8f },
  { hex = P.orange, r = 0xff, g = 0x8f, b = 0x40 },
  { hex = P.red, r = 0xf0, g = 0x71, b = 0x78 },
  { hex = P.pink, r = 0xf6, g = 0xad, b = 0xae },
  { hex = P.purple, r = 0xd2, g = 0xa6, b = 0xff },
  { hex = P.brown, r = 0xe6, g = 0xc0, b = 0x8a },
}

local function hex_to_rgb(hex)
  if type(hex) ~= "string" then return nil end
  local clean = hex:gsub("^#", "")
  if #clean ~= 6 then return nil end
  local r = tonumber(clean:sub(1, 2), 16)
  local g = tonumber(clean:sub(3, 4), 16)
  local b = tonumber(clean:sub(5, 6), 16)
  if not r or not g or not b then return nil end
  return r, g, b
end

---Map an arbitrary built-in hex color onto its closest Flow Deep palette color.
local function snap_to_flow_deep(hex)
  local r, g, b = hex_to_rgb(hex)
  if not r then return P.gray end
  local max_c = math.max(r, g, b)
  local min_c = math.min(r, g, b)
  -- Very dark colors in raw devicons become unreadable on dark backgrounds; lift to Flow Deep gray
  if max_c < 72 then
    return P.gray
  end
  -- Low-saturation grays map to Flow Deep gray or white based on lightness
  if (max_c - min_c) < 22 then
    return (max_c >= 165) and P.white or P.gray
  end
  local best_hex = P.blue
  local best_dist = math.huge
  for _, cand in ipairs(QUANTIZE_TARGETS) do
    if cand.hex ~= P.white and cand.hex ~= P.gray then
      local dr = r - cand.r
      local dg = g - cand.g
      local db = b - cand.b
      local dist = (dr * dr * 0.30) + (dg * dg * 0.59) + (db * db * 0.11)
      if dist < best_dist then
        best_dist = dist
        best_hex = cand.hex
      end
    end
  end
  return best_hex
end

-- Curated Flow Deep file extension definitions (glyphs verified from Nerd Fonts v3)
M.extension_overrides = {
  -- TypeScript & JavaScript ecosystem
  ts = { icon = "", color = P.blue, name = "TypeScript" },
  mts = { icon = "", color = P.blue, name = "TypeScript" },
  cts = { icon = "", color = P.blue, name = "TypeScript" },
  tsx = { icon = "", color = P.blue, name = "Tsx" },
  ["d.ts"] = { icon = "", color = P.purple, name = "TypeScriptDef" },
  js = { icon = "", color = P.yellow, name = "Js" },
  mjs = { icon = "", color = P.yellow, name = "Js" },
  cjs = { icon = "", color = P.yellow, name = "Js" },
  jsx = { icon = "", color = P.sky, name = "Jsx" },
  ["test.ts"] = { icon = "", color = P.green, name = "TestTs" },
  ["test.tsx"] = { icon = "", color = P.green, name = "TestTsx" },
  ["test.js"] = { icon = "", color = P.green, name = "TestJs" },
  ["test.jsx"] = { icon = "", color = P.green, name = "TestJsx" },
  ["spec.ts"] = { icon = "", color = P.green, name = "SpecTs" },
  ["spec.tsx"] = { icon = "", color = P.green, name = "SpecTsx" },
  ["spec.js"] = { icon = "", color = P.green, name = "SpecJs" },
  ["spec.jsx"] = { icon = "", color = P.green, name = "SpecJsx" },

  -- Web / UI Frameworks & Styling
  html = { icon = "", color = P.orange, name = "Html" },
  htm = { icon = "", color = P.orange, name = "Html" },
  css = { icon = "", color = P.blue, name = "Css" },
  scss = { icon = "", color = P.pink, name = "Scss" },
  sass = { icon = "", color = P.pink, name = "Sass" },
  less = { icon = "", color = P.purple, name = "Less" },
  vue = { icon = "", color = P.green, name = "Vue" },
  svelte = { icon = "", color = P.orange, name = "Svelte" },
  astro = { icon = "", color = P.orange, name = "Astro" },
  graphql = { icon = "", color = P.pink, name = "GraphQL" },
  gql = { icon = "", color = P.pink, name = "GraphQL" },
  prisma = { icon = "", color = P.teal, name = "Prisma" },
  wasm = { icon = "", color = P.purple, name = "Wasm" },

  -- Backend & Systems Languages
  py = { icon = "", color = P.blue, name = "Python" },
  python = { icon = "", color = P.blue, name = "Python" },
  pyi = { icon = "", color = P.sky, name = "Python" },
  ipynb = { icon = "", color = P.orange, name = "Jupyter" },
  go = { icon = "", color = P.sky, name = "Go" },
  mod = { icon = "", color = P.blue, name = "GoMod" },
  sum = { icon = "", color = P.pink, name = "GoSum" },
  rs = { icon = "", color = P.orange, name = "Rs" },
  lua = { icon = "", color = P.blue, name = "Lua" },
  c = { icon = "", color = P.blue, name = "C" },
  h = { icon = "", color = P.purple, name = "H" },
  cpp = { icon = "", color = P.blue, name = "Cpp" },
  hpp = { icon = "", color = P.purple, name = "Hpp" },
  cc = { icon = "", color = P.blue, name = "Cpp" },
  cs = { icon = "󰌛", color = P.purple, name = "Cs" },
  java = { icon = "", color = P.red, name = "Java" },
  kt = { icon = "", color = P.purple, name = "Kotlin" },
  kts = { icon = "", color = P.purple, name = "KotlinScript" },
  swift = { icon = "", color = P.orange, name = "Swift" },
  dart = { icon = "", color = P.sky, name = "Dart" },
  rb = { icon = "", color = P.red, name = "Rb" },
  php = { icon = "", color = P.purple, name = "Php" },
  ex = { icon = "", color = P.purple, name = "Elixir" },
  exs = { icon = "", color = P.purple, name = "Elixir" },
  zig = { icon = "", color = P.yellow, name = "Zig" },
  nim = { icon = "", color = P.yellow, name = "Nim" },
  nix = { icon = "", color = P.sky, name = "Nix" },

  -- Shell, DevOps & Infra
  sh = { icon = "", color = P.green, name = "Sh" },
  bash = { icon = "", color = P.green, name = "Bash" },
  zsh = { icon = "", color = P.lime, name = "Zsh" },
  fish = { icon = "", color = P.teal, name = "Fish" },
  ps1 = { icon = "󰨊", color = P.blue, name = "Ps1" },
  psm1 = { icon = "󰨊", color = P.blue, name = "Psm1" },
  psd1 = { icon = "󰨊", color = P.sky, name = "Psd1" },
  bat = { icon = "", color = P.yellow, name = "Bat" },
  cmd = { icon = "", color = P.yellow, name = "Cmd" },
  tf = { icon = "", color = P.purple, name = "Terraform" },
  tfvars = { icon = "", color = P.purple, name = "Terraform" },
  dockerfile = { icon = "󰡨", color = P.sky, name = "Dockerfile" },

  -- Data, Config & Docs
  json = { icon = "", color = P.yellow, name = "Json" },
  jsonc = { icon = "", color = P.yellow, name = "Jsonc" },
  json5 = { icon = "", color = P.yellow, name = "Json5" },
  yaml = { icon = "", color = P.red, name = "Yaml" },
  yml = { icon = "", color = P.red, name = "Yml" },
  toml = { icon = "", color = P.orange, name = "Toml" },
  xml = { icon = "󰗀", color = P.orange, name = "Xml" },
  sql = { icon = "", color = P.teal, name = "Sql" },
  db = { icon = "", color = P.teal, name = "Db" },
  sqlite = { icon = "", color = P.sky, name = "Sqlite" },
  csv = { icon = "", color = P.green, name = "Csv" },
  env = { icon = "", color = P.yellow, name = "Env" },
  ini = { icon = "", color = P.gray, name = "Ini" },
  conf = { icon = "", color = P.gray, name = "Conf" },
  cfg = { icon = "", color = P.gray, name = "Cfg" },
  lock = { icon = "", color = P.gray, name = "Lock" },
  log = { icon = "󰌱", color = P.brown, name = "Log" },
  md = { icon = "", color = P.blue, name = "Md" },
  markdown = { icon = "", color = P.blue, name = "Markdown" },
  mdx = { icon = "", color = P.purple, name = "Mdx" },
  txt = { icon = "󰈙", color = P.white, name = "Txt" },
  pdf = { icon = "", color = P.red, name = "Pdf" },
  makefile = { icon = "", color = P.yellow, name = "Makefile" },

  -- Media & Archives
  png = { icon = "", color = P.purple, name = "Png" },
  jpg = { icon = "", color = P.purple, name = "Jpg" },
  jpeg = { icon = "", color = P.purple, name = "Jpeg" },
  webp = { icon = "", color = P.purple, name = "Webp" },
  gif = { icon = "", color = P.pink, name = "Gif" },
  ico = { icon = "", color = P.yellow, name = "Ico" },
  svg = { icon = "󰜡", color = P.yellow, name = "Svg" },
  ttf = { icon = "", color = P.pink, name = "Ttf" },
  otf = { icon = "", color = P.pink, name = "Otf" },
  woff = { icon = "", color = P.pink, name = "Woff" },
  woff2 = { icon = "", color = P.pink, name = "Woff2" },
  zip = { icon = "", color = P.brown, name = "Zip" },
  tar = { icon = "", color = P.brown, name = "Tar" },
  gz = { icon = "", color = P.brown, name = "Gz" },
}

-- Exact Flow Deep filename associations
M.filename_overrides = {
  [".gitignore"] = { icon = "", color = P.orange, name = "GitIgnore" },
  [".gitattributes"] = { icon = "", color = P.orange, name = "GitAttributes" },
  [".gitmodules"] = { icon = "", color = P.orange, name = "GitModules" },
  [".env"] = { icon = "", color = P.yellow, name = "Env" },
  [".env.local"] = { icon = "", color = P.yellow, name = "EnvLocal" },
  [".env.development"] = { icon = "", color = P.yellow, name = "EnvDev" },
  [".env.production"] = { icon = "", color = P.yellow, name = "EnvProd" },
  [".env.example"] = { icon = "", color = P.gray, name = "EnvExample" },
  ["package.json"] = { icon = "", color = P.red, name = "PackageJson" },
  ["package-lock.json"] = { icon = "", color = P.brown, name = "PackageLockJson" },
  ["yarn.lock"] = { icon = "", color = P.blue, name = "YarnLock" },
  ["pnpm-lock.yaml"] = { icon = "", color = P.yellow, name = "PnpmLock" },
  ["bun.lock"] = { icon = "", color = P.brown, name = "BunLock" },
  ["bun.lockb"] = { icon = "", color = P.brown, name = "BunLockb" },
  ["tsconfig.json"] = { icon = "", color = P.blue, name = "TSConfig" },
  ["jsconfig.json"] = { icon = "", color = P.yellow, name = "JSConfig" },
  ["vite.config.js"] = { icon = "", color = P.purple, name = "ViteConfig" },
  ["vite.config.mjs"] = { icon = "", color = P.purple, name = "ViteConfig" },
  ["vite.config.ts"] = { icon = "", color = P.purple, name = "ViteConfig" },
  ["vite.config.mts"] = { icon = "", color = P.purple, name = "ViteConfig" },
  ["tailwind.config.js"] = { icon = "󱏿", color = P.teal, name = "TailwindConfig" },
  ["tailwind.config.mjs"] = { icon = "󱏿", color = P.teal, name = "TailwindConfig" },
  ["tailwind.config.ts"] = { icon = "󱏿", color = P.teal, name = "TailwindConfig" },
  ["eslint.config.js"] = { icon = "", color = P.purple, name = "Eslintrc" },
  ["eslint.config.mjs"] = { icon = "", color = P.purple, name = "Eslintrc" },
  ["eslint.config.ts"] = { icon = "", color = P.purple, name = "Eslintrc" },
  [".eslintrc"] = { icon = "", color = P.purple, name = "Eslintrc" },
  [".eslintrc.json"] = { icon = "", color = P.purple, name = "Eslintrc" },
  ["prettier.config.js"] = { icon = "", color = P.teal, name = "PrettierConfig" },
  ["prettier.config.mjs"] = { icon = "", color = P.teal, name = "PrettierConfig" },
  ["prettier.config.ts"] = { icon = "", color = P.teal, name = "PrettierConfig" },
  [".prettierrc"] = { icon = "", color = P.teal, name = "PrettierConfig" },
  ["go.mod"] = { icon = "", color = P.blue, name = "GoMod" },
  ["go.sum"] = { icon = "", color = P.pink, name = "GoSum" },
  ["cargo.toml"] = { icon = "", color = P.orange, name = "CargoToml" },
  ["Cargo.toml"] = { icon = "", color = P.orange, name = "CargoToml" },
  ["Cargo.lock"] = { icon = "", color = P.brown, name = "CargoLock" },
  ["pyproject.toml"] = { icon = "", color = P.yellow, name = "PyprojectToml" },
  ["requirements.txt"] = { icon = "", color = P.sky, name = "RequirementsTxt" },
  ["dockerfile"] = { icon = "󰡨", color = P.sky, name = "Dockerfile" },
  ["Dockerfile"] = { icon = "󰡨", color = P.sky, name = "Dockerfile" },
  ["docker-compose.yml"] = { icon = "󰡨", color = P.sky, name = "DockerCompose" },
  ["docker-compose.yaml"] = { icon = "󰡨", color = P.sky, name = "DockerCompose" },
  ["compose.yml"] = { icon = "󰡨", color = P.sky, name = "DockerCompose" },
  ["compose.yaml"] = { icon = "󰡨", color = P.sky, name = "DockerCompose" },
  [".dockerignore"] = { icon = "󰡨", color = P.gray, name = "DockerIgnore" },
  ["makefile"] = { icon = "", color = P.yellow, name = "Makefile" },
  ["Makefile"] = { icon = "", color = P.yellow, name = "Makefile" },
  ["CMakeLists.txt"] = { icon = "", color = P.blue, name = "CMakeLists" },
  ["README.md"] = { icon = "󰂺", color = P.blue, name = "Readme" },
  ["readme.md"] = { icon = "󰂺", color = P.blue, name = "Readme" },
  ["README"] = { icon = "󰂺", color = P.blue, name = "Readme" },
  ["LICENSE"] = { icon = "", color = P.yellow, name = "License" },
  ["license"] = { icon = "", color = P.yellow, name = "License" },
  ["LICENSE.md"] = { icon = "", color = P.yellow, name = "LicenseMd" },
  ["CHANGELOG.md"] = { icon = "󰂺", color = P.teal, name = "ChangelogMd" },
}

-- Semantic folder styles matching Flow Icons Deep (`specificFolders = true`, base `folderColor = "gray"`)
-- Keyed by lowercase folder name -> { closed, open, hl, fg }
M.folder_specs = {
  -- Source & Core (Blue)
  src = { closed = "󰉋", open = "󰝰", hl = "FlowFolderBlue" },
  source = { closed = "󰉋", open = "󰝰", hl = "FlowFolderBlue" },
  sources = { closed = "󰉋", open = "󰝰", hl = "FlowFolderBlue" },
  app = { closed = "󰉋", open = "󰝰", hl = "FlowFolderBlue" },
  apps = { closed = "󰉋", open = "󰝰", hl = "FlowFolderBlue" },
  core = { closed = "󰉋", open = "󰝰", hl = "FlowFolderBlue" },
  cmd = { closed = "󰉒", open = "󰝰", hl = "FlowFolderBlue" },
  pkg = { closed = "󰉋", open = "󰝰", hl = "FlowFolderBlue" },
  internal = { closed = "󰉋", open = "󰝰", hl = "FlowFolderBlue" },
  packages = { closed = "󰉋", open = "󰝰", hl = "FlowFolderBlue" },

  -- Components, Views & Databases (Teal)
  components = { closed = "󱂵", open = "󰝰", hl = "FlowFolderTeal" },
  component = { closed = "󱂵", open = "󰝰", hl = "FlowFolderTeal" },
  ui = { closed = "󱂵", open = "󰝰", hl = "FlowFolderTeal" },
  views = { closed = "󱂵", open = "󰝰", hl = "FlowFolderTeal" },
  view = { closed = "󱂵", open = "󰝰", hl = "FlowFolderTeal" },
  layouts = { closed = "󱂵", open = "󰝰", hl = "FlowFolderTeal" },
  layout = { closed = "󱂵", open = "󰝰", hl = "FlowFolderTeal" },
  widgets = { closed = "󱂵", open = "󰝰", hl = "FlowFolderTeal" },
  templates = { closed = "󱂵", open = "󰝰", hl = "FlowFolderTeal" },
  db = { closed = "󰆼", open = "󰝰", hl = "FlowFolderTeal" },
  database = { closed = "󰆼", open = "󰝰", hl = "FlowFolderTeal" },
  databases = { closed = "󰆼", open = "󰝰", hl = "FlowFolderTeal" },
  prisma = { closed = "󰆼", open = "󰝰", hl = "FlowFolderTeal" },
  supabase = { closed = "󰆼", open = "󰝰", hl = "FlowFolderTeal" },
  migrations = { closed = "󰆼", open = "󰝰", hl = "FlowFolderTeal" },
  schema = { closed = "󰆼", open = "󰝰", hl = "FlowFolderTeal" },
  schemas = { closed = "󰆼", open = "󰝰", hl = "FlowFolderTeal" },
  models = { closed = "󰆼", open = "󰝰", hl = "FlowFolderTeal" },
  data = { closed = "󰆼", open = "󰝰", hl = "FlowFolderTeal" },

  -- Pages, Routes, Docs & Cloud/Containers (Sky)
  pages = { closed = "󰉋", open = "󰝰", hl = "FlowFolderSky" },
  page = { closed = "󰉋", open = "󰝰", hl = "FlowFolderSky" },
  routes = { closed = "󰉋", open = "󰝰", hl = "FlowFolderSky" },
  route = { closed = "󰉋", open = "󰝰", hl = "FlowFolderSky" },
  router = { closed = "󰉋", open = "󰝰", hl = "FlowFolderSky" },
  docs = { closed = "󰂺", open = "󰝰", hl = "FlowFolderSky" },
  doc = { closed = "󰂺", open = "󰝰", hl = "FlowFolderSky" },
  documentation = { closed = "󰂺", open = "󰝰", hl = "FlowFolderSky" },
  docker = { closed = "󰡨", open = "󰝰", hl = "FlowFolderSky" },
  [".docker"] = { closed = "󰡨", open = "󰝰", hl = "FlowFolderSky" },
  k8s = { closed = "󰡨", open = "󰝰", hl = "FlowFolderSky" },
  kubernetes = { closed = "󰡨", open = "󰝰", hl = "FlowFolderSky" },
  deploy = { closed = "󰡨", open = "󰝰", hl = "FlowFolderSky" },

  -- API, Server, Controllers & Git (Orange)
  api = { closed = "󰉋", open = "󰝰", hl = "FlowFolderOrange" },
  apis = { closed = "󰉋", open = "󰝰", hl = "FlowFolderOrange" },
  server = { closed = "󰉋", open = "󰝰", hl = "FlowFolderOrange" },
  backend = { closed = "󰉋", open = "󰝰", hl = "FlowFolderOrange" },
  controllers = { closed = "󰉋", open = "󰝰", hl = "FlowFolderOrange" },
  controller = { closed = "󰉋", open = "󰝰", hl = "FlowFolderOrange" },
  handlers = { closed = "󰉋", open = "󰝰", hl = "FlowFolderOrange" },
  [".git"] = { closed = "", open = "", hl = "FlowFolderOrange" },
  [".github"] = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  [".gitlab"] = { closed = "󰉒", open = "󰝰", hl = "FlowFolderOrange" },

  -- Hooks, Utils, Lib, Services, Store, Lua & Scripts (Purple)
  hooks = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  hook = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  utils = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  util = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  helpers = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  lib = { closed = "󰉋", open = "󰝰", hl = "FlowFolderPurple" },
  libs = { closed = "󰉋", open = "󰝰", hl = "FlowFolderPurple" },
  shared = { closed = "󰉋", open = "󰝰", hl = "FlowFolderPurple" },
  common = { closed = "󰉋", open = "󰝰", hl = "FlowFolderPurple" },
  services = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  service = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  middleware = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  store = { closed = "󰉋", open = "󰝰", hl = "FlowFolderPurple" },
  state = { closed = "󰉋", open = "󰝰", hl = "FlowFolderPurple" },
  context = { closed = "󰉋", open = "󰝰", hl = "FlowFolderPurple" },
  providers = { closed = "󰉋", open = "󰝰", hl = "FlowFolderPurple" },
  types = { closed = "󰉋", open = "󰝰", hl = "FlowFolderPurple" },
  interfaces = { closed = "󰉋", open = "󰝰", hl = "FlowFolderPurple" },
  modules = { closed = "󰉋", open = "󰝰", hl = "FlowFolderPurple" },
  plugins = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  lua = { closed = "", open = "󰝰", hl = "FlowFolderBlue" },
  scripts = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  script = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  bin = { closed = "󰉒", open = "󰝰", hl = "FlowFolderPurple" },
  [".vscode"] = { closed = "󰉒", open = "󰝰", hl = "FlowFolderBlue" },

  -- Tests & Mocks (Green)
  test = { closed = "󰙨", open = "󰝰", hl = "FlowFolderGreen" },
  tests = { closed = "󰙨", open = "󰝰", hl = "FlowFolderGreen" },
  ["__tests__"] = { closed = "󰙨", open = "󰝰", hl = "FlowFolderGreen" },
  spec = { closed = "󰙨", open = "󰝰", hl = "FlowFolderGreen" },
  specs = { closed = "󰙨", open = "󰝰", hl = "FlowFolderGreen" },
  e2e = { closed = "󰙨", open = "󰝰", hl = "FlowFolderGreen" },
  cypress = { closed = "󰙨", open = "󰝰", hl = "FlowFolderGreen" },
  playwright = { closed = "󰙨", open = "󰝰", hl = "FlowFolderGreen" },
  ["__mocks__"] = { closed = "󰙨", open = "󰝰", hl = "FlowFolderLime" },
  mocks = { closed = "󰙨", open = "󰝰", hl = "FlowFolderLime" },
  fixtures = { closed = "󰙨", open = "󰝰", hl = "FlowFolderLime" },
  node_modules = { closed = "󰉋", open = "󰝰", hl = "FlowFolderGray" },

  -- Assets, Media & Styles (Pink)
  assets = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  images = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  img = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  imgs = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  icons = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  icon = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  media = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  fonts = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  font = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  svg = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  styles = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  style = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  css = { closed = "󰉏", open = "󰝰", hl = "FlowFolderBlue" },
  scss = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  themes = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  theme = { closed = "󰉏", open = "󰝰", hl = "FlowFolderPink" },
  desktop = { closed = "󰉋", open = "󰝰", hl = "FlowFolderPink" },

  -- Config, Public & Build Outputs (Yellow / Brown / Gray)
  config = { closed = "󰉒", open = "󰝰", hl = "FlowFolderYellow" },
  configs = { closed = "󰉒", open = "󰝰", hl = "FlowFolderYellow" },
  conf = { closed = "󰉒", open = "󰝰", hl = "FlowFolderYellow" },
  settings = { closed = "󰉒", open = "󰝰", hl = "FlowFolderYellow" },
  public = { closed = "󰉐", open = "󰝰", hl = "FlowFolderYellow" },
  static = { closed = "󰉐", open = "󰝰", hl = "FlowFolderYellow" },
  dist = { closed = "󰉐", open = "󰝰", hl = "FlowFolderBrown" },
  build = { closed = "󰉐", open = "󰝰", hl = "FlowFolderBrown" },
  out = { closed = "󰉐", open = "󰝰", hl = "FlowFolderBrown" },
  output = { closed = "󰉐", open = "󰝰", hl = "FlowFolderBrown" },
  target = { closed = "󰉐", open = "󰝰", hl = "FlowFolderBrown" },
  logs = { closed = "󰉋", open = "󰝰", hl = "FlowFolderBrown" },
  log = { closed = "󰉋", open = "󰝰", hl = "FlowFolderBrown" },
  vendor = { closed = "󰉋", open = "󰝰", hl = "FlowFolderGray" },
  [".venv"] = { closed = "󰉋", open = "󰝰", hl = "FlowFolderGray" },
  venv = { closed = "󰉋", open = "󰝰", hl = "FlowFolderGray" },
  [".cache"] = { closed = "󰉋", open = "󰝰", hl = "FlowFolderGray" },
  tmp = { closed = "󰉋", open = "󰝰", hl = "FlowFolderGray" },
  temp = { closed = "󰉋", open = "󰝰", hl = "FlowFolderGray" },

  -- Security & Auth (Red)
  auth = { closed = "󰚝", open = "󰝰", hl = "FlowFolderRed" },
  security = { closed = "󰚝", open = "󰝰", hl = "FlowFolderRed" },
  keys = { closed = "󰚝", open = "󰝰", hl = "FlowFolderRed" },
  certs = { closed = "󰚝", open = "󰝰", hl = "FlowFolderRed" },
}

local HL_COLOR_GROUPS = {
  FlowFolderGray = P.gray,
  FlowFolderGrayOpen = P.gray_open,
  FlowFolderGrayEmpty = P.gray_empty,
  FlowFolderWhite = P.white,
  FlowFolderBlue = P.blue,
  FlowFolderSky = P.sky,
  FlowFolderTeal = P.teal,
  FlowFolderGreen = P.green,
  FlowFolderLime = P.lime,
  FlowFolderYellow = P.yellow,
  FlowFolderOrange = P.orange,
  FlowFolderRed = P.red,
  FlowFolderPink = P.pink,
  FlowFolderPurple = P.purple,
  FlowFolderBrown = P.brown,
}

function M.apply_highlights()
  for group, fg in pairs(HL_COLOR_GROUPS) do
    vim.api.nvim_set_hl(0, group, { fg = fg })
  end

  -- Flow Deep generic folder highlights (muted slate-gray with lighter open state)
  vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = P.gray })
  vim.api.nvim_set_hl(0, "NvimTreeClosedFolderIcon", { fg = P.gray })
  vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderIcon", { fg = P.gray_open })
  vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderIcon", { fg = P.gray_empty })
  vim.api.nvim_set_hl(0, "NvimTreeSymlinkFolderIcon", { fg = P.sky })
  vim.api.nvim_set_hl(0, "NvimTreeFolderArrowClosed", { fg = P.gray_empty })
  vim.api.nvim_set_hl(0, "NvimTreeFolderArrowOpen", { fg = P.gray })
  vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = "#2a313c" })

  -- File defaults & Git/Diagnostic icon highlights harmonized with Flow Deep
  vim.api.nvim_set_hl(0, "NvimTreeFileIcon", { fg = P.white })
  vim.api.nvim_set_hl(0, "DevIconDefault", { fg = P.white })
  vim.api.nvim_set_hl(0, "NvimTreeGitDirtyIcon", { fg = P.yellow })
  vim.api.nvim_set_hl(0, "NvimTreeGitStagedIcon", { fg = P.green })
  vim.api.nvim_set_hl(0, "NvimTreeGitNewIcon", { fg = P.green })
  vim.api.nvim_set_hl(0, "NvimTreeGitDeletedIcon", { fg = P.red })
  vim.api.nvim_set_hl(0, "NvimTreeGitRenamedIcon", { fg = P.purple })
  vim.api.nvim_set_hl(0, "NvimTreeGitIgnoredIcon", { fg = P.gray_empty })
  vim.api.nvim_set_hl(0, "NvimTreeGitDirty", { fg = P.yellow, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitStaged", { fg = P.green, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitNew", { fg = P.green, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", { fg = P.red })
  vim.api.nvim_set_hl(0, "NvimTreeGitRenamed", { fg = P.purple })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticErrorFileHLGroup", { fg = P.red, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticWarnFileHLGroup", { fg = P.yellow, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticInfoFileHLGroup", { fg = P.blue, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticHintFileHLGroup", { fg = P.teal, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticErrorIconHLGroup", { fg = P.red })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticWarnIconHLGroup", { fg = P.yellow })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticInfoIconHLGroup", { fg = P.blue })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticHintIconHLGroup", { fg = P.teal })
end

function M.setup_devicons()
  local ok_dev, devicons = pcall(require, "nvim-web-devicons")
  if not ok_dev then return end

  -- First pass: harmonize all ~500 built-in devicon colors onto Flow Deep's 14-color palette
  local existing_icons = devicons.get_icons()
  local harmonized_overrides = {}
  for key, meta in pairs(existing_icons or {}) do
    if type(meta) == "table" and meta.icon and meta.name then
      harmonized_overrides[key] = {
        icon = meta.icon,
        color = snap_to_flow_deep(meta.color),
        name = meta.name,
      }
    end
  end

  -- Second pass: apply exact Flow Deep curated overrides on top
  for ext, meta in pairs(M.extension_overrides) do
    harmonized_overrides[ext] = meta
  end

  devicons.setup({
    default = true,
    color_icons = true,
    override = harmonized_overrides,
    override_by_extension = M.extension_overrides,
    override_by_filename = M.filename_overrides,
    default_icon = { icon = "󰈙", color = P.white, name = "Default" },
  })
  pcall(devicons.set_default_icon, "󰈙", P.white, 75)
  M.apply_highlights()
end

function M.create_folder_decorator(api)
  if not api or not api.Decorator then return nil end
  local FlowFolderDecorator = api.Decorator:extend()

  function FlowFolderDecorator:new()
    self.enabled = true
    self.highlight_range = "none"
    self.icon_placement = "none"
  end

  function FlowFolderDecorator:icon_node(node)
    if not node or node.type ~= "directory" then
      return nil
    end
    local key = (node.name or ""):lower()
    local spec = M.folder_specs[key]
    if spec then
      local str = node.open and spec.open or spec.closed
      return { str = str, hl = { spec.hl } }
    end
    if node.open then
      return { str = "󰝰", hl = { "FlowFolderGrayOpen" } }
    end
    if node.has_children == false and (#(node.nodes or {}) == 0) then
      return { str = "󰉖", hl = { "FlowFolderGrayEmpty" } }
    end
    return { str = "󰉋", hl = { "FlowFolderGray" } }
  end

  return FlowFolderDecorator
end

return M
