-- =============================================================================
-- Minimal Signature Icon Theme (Bespoke Noir-Luminous Edition)
-- Unique to Minimal Editor:
--   * Airy hollow architectural folders ( / ) with domain glyphs by name
--   * Name-first + role-pattern + extension-color resolution for all files
--   * Full-size Nerd Font glyphs consistent across Sidebar and Top Tabs
-- =============================================================================

local M = {}

M.palette = {
  starlight = "#c0caf5",
  slate = "#788296",
  slate_open = "#a9b1d6",
  muted = "#565f89",
  azure = "#7aa2f7",
  aurora = "#7dcfff",
  mint = "#73daca",
  emerald = "#9ece6a",
  lime = "#b9f27c",
  amber = "#e0af68",
  coral = "#ff9e64",
  rose = "#f7768e",
  blossom = "#f5c2e7",
  iris = "#bb9af7",
  sand = "#cfa87a",
}

local P = M.palette

local QUANTIZE_TARGETS = {
  { hex = P.starlight, r = 0xc0, g = 0xca, b = 0xf5 },
  { hex = P.slate, r = 0x78, g = 0x82, b = 0x96 },
  { hex = P.azure, r = 0x7a, g = 0xa2, b = 0xf7 },
  { hex = P.aurora, r = 0x7d, g = 0xcf, b = 0xff },
  { hex = P.mint, r = 0x73, g = 0xda, b = 0xca },
  { hex = P.emerald, r = 0x9e, g = 0xce, b = 0x6a },
  { hex = P.lime, r = 0xb9, g = 0xf2, b = 0x7c },
  { hex = P.amber, r = 0xe0, g = 0xaf, b = 0x68 },
  { hex = P.coral, r = 0xff, g = 0x9e, b = 0x64 },
  { hex = P.rose, r = 0xf7, g = 0x76, b = 0x8e },
  { hex = P.blossom, r = 0xf5, g = 0xc2, b = 0xe7 },
  { hex = P.iris, r = 0xbb, g = 0x9a, b = 0xf7 },
  { hex = P.sand, r = 0xcf, g = 0xa8, b = 0x7a },
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

local function snap_to_palette(hex)
  local r, g, b = hex_to_rgb(hex)
  if not r then return P.slate end
  local max_c = math.max(r, g, b)
  local min_c = math.min(r, g, b)
  if max_c < 72 then return P.slate end
  if (max_c - min_c) < 22 then
    return (max_c >= 165) and P.starlight or P.slate
  end
  local best_hex = P.azure
  local best_dist = math.huge
  for _, cand in ipairs(QUANTIZE_TARGETS) do
    if cand.hex ~= P.starlight and cand.hex ~= P.slate then
      local dr, dg, db = r - cand.r, g - cand.g, b - cand.b
      local dist = (dr * dr * 0.30) + (dg * dg * 0.59) + (db * db * 0.11)
      if dist < best_dist then
        best_dist = dist
        best_hex = cand.hex
      end
    end
  end
  return best_hex
end

M.extension_overrides = {
  ts = { icon = "", color = P.azure, name = "TypeScript" },
  mts = { icon = "", color = P.azure, name = "TypeScript" },
  cts = { icon = "", color = P.azure, name = "TypeScript" },
  tsx = { icon = "", color = P.aurora, name = "Tsx" },
  ["d.ts"] = { icon = "", color = P.iris, name = "TypeScriptDef" },
  js = { icon = "", color = P.amber, name = "Js" },
  mjs = { icon = "", color = P.amber, name = "Js" },
  cjs = { icon = "", color = P.amber, name = "Js" },
  jsx = { icon = "", color = P.aurora, name = "Jsx" },

  html = { icon = "", color = P.coral, name = "Html" },
  htm = { icon = "", color = P.coral, name = "Html" },
  css = { icon = "", color = P.azure, name = "Css" },
  scss = { icon = "", color = P.blossom, name = "Scss" },
  sass = { icon = "", color = P.blossom, name = "Sass" },
  less = { icon = "", color = P.iris, name = "Less" },
  vue = { icon = "", color = P.emerald, name = "Vue" },
  svelte = { icon = "", color = P.coral, name = "Svelte" },
  astro = { icon = "", color = P.coral, name = "Astro" },
  graphql = { icon = "", color = P.blossom, name = "GraphQL" },
  gql = { icon = "", color = P.blossom, name = "GraphQL" },
  prisma = { icon = "", color = P.mint, name = "Prisma" },
  wasm = { icon = "", color = P.iris, name = "Wasm" },

  py = { icon = "", color = P.azure, name = "Python" },
  python = { icon = "", color = P.azure, name = "Python" },
  pyi = { icon = "", color = P.aurora, name = "Python" },
  ipynb = { icon = "", color = P.coral, name = "Jupyter" },
  go = { icon = "", color = P.aurora, name = "Go" },
  mod = { icon = "", color = P.azure, name = "GoMod" },
  sum = { icon = "", color = P.blossom, name = "GoSum" },
  rs = { icon = "", color = P.coral, name = "Rs" },
  lua = { icon = "", color = P.azure, name = "Lua" },
  c = { icon = "", color = P.azure, name = "C" },
  h = { icon = "", color = P.iris, name = "H" },
  cpp = { icon = "", color = P.azure, name = "Cpp" },
  hpp = { icon = "", color = P.iris, name = "Hpp" },
  cc = { icon = "", color = P.azure, name = "Cpp" },
  cs = { icon = "", color = P.iris, name = "Cs" },
  java = { icon = "", color = P.rose, name = "Java" },
  kt = { icon = "", color = P.iris, name = "Kotlin" },
  kts = { icon = "", color = P.iris, name = "KotlinScript" },
  swift = { icon = "", color = P.coral, name = "Swift" },
  dart = { icon = "", color = P.aurora, name = "Dart" },
  rb = { icon = "", color = P.rose, name = "Rb" },
  php = { icon = "", color = P.iris, name = "Php" },
  ex = { icon = "", color = P.iris, name = "Elixir" },
  exs = { icon = "", color = P.iris, name = "Elixir" },
  zig = { icon = "", color = P.amber, name = "Zig" },
  nim = { icon = "", color = P.amber, name = "Nim" },
  nix = { icon = "", color = P.aurora, name = "Nix" },

  sh = { icon = "", color = P.emerald, name = "Sh" },
  bash = { icon = "", color = P.emerald, name = "Bash" },
  zsh = { icon = "", color = P.lime, name = "Zsh" },
  fish = { icon = "", color = P.mint, name = "Fish" },
  ps1 = { icon = "", color = P.azure, name = "Ps1" },
  psm1 = { icon = "", color = P.azure, name = "Psm1" },
  psd1 = { icon = "", color = P.aurora, name = "Psd1" },
  bat = { icon = "", color = P.amber, name = "Bat" },
  cmd = { icon = "", color = P.amber, name = "Cmd" },
  tf = { icon = "", color = P.iris, name = "Terraform" },
  tfvars = { icon = "", color = P.iris, name = "Terraform" },
  dockerfile = { icon = "", color = P.aurora, name = "Dockerfile" },

  json = { icon = "", color = P.amber, name = "Json" },
  jsonc = { icon = "", color = P.amber, name = "Jsonc" },
  json5 = { icon = "", color = P.amber, name = "Json5" },
  yaml = { icon = "", color = P.rose, name = "Yaml" },
  yml = { icon = "", color = P.rose, name = "Yml" },
  toml = { icon = "", color = P.coral, name = "Toml" },
  xml = { icon = "", color = P.coral, name = "Xml" },
  sql = { icon = "", color = P.mint, name = "Sql" },
  db = { icon = "", color = P.mint, name = "Db" },
  sqlite = { icon = "", color = P.aurora, name = "Sqlite" },
  csv = { icon = "", color = P.emerald, name = "Csv" },
  env = { icon = "", color = P.amber, name = "Env" },
  ini = { icon = "", color = P.slate, name = "Ini" },
  conf = { icon = "", color = P.slate, name = "Conf" },
  cfg = { icon = "", color = P.slate, name = "Cfg" },
  lock = { icon = "", color = P.slate, name = "Lock" },
  log = { icon = "", color = P.sand, name = "Log" },
  md = { icon = "", color = P.azure, name = "Md" },
  markdown = { icon = "", color = P.azure, name = "Markdown" },
  mdx = { icon = "", color = P.iris, name = "Mdx" },
  txt = { icon = "", color = P.starlight, name = "Txt" },
  pdf = { icon = "", color = P.rose, name = "Pdf" },
  makefile = { icon = "", color = P.amber, name = "Makefile" },

  png = { icon = "", color = P.blossom, name = "Png" },
  jpg = { icon = "", color = P.blossom, name = "Jpg" },
  jpeg = { icon = "", color = P.blossom, name = "Jpeg" },
  webp = { icon = "", color = P.blossom, name = "Webp" },
  gif = { icon = "", color = P.rose, name = "Gif" },
  ico = { icon = "", color = P.amber, name = "Ico" },
  svg = { icon = "", color = P.amber, name = "Svg" },
  ttf = { icon = "", color = P.blossom, name = "Ttf" },
  otf = { icon = "", color = P.blossom, name = "Otf" },
  woff = { icon = "", color = P.blossom, name = "Woff" },
  woff2 = { icon = "", color = P.blossom, name = "Woff2" },
  zip = { icon = "", color = P.sand, name = "Zip" },
  tar = { icon = "", color = P.sand, name = "Tar" },
  gz = { icon = "", color = P.sand, name = "Gz" },
}

M.filename_overrides = {
  [".gitignore"] = { icon = "", color = P.coral, name = "GitIgnore" },
  [".gitattributes"] = { icon = "", color = P.coral, name = "GitAttributes" },
  [".gitmodules"] = { icon = "", color = P.coral, name = "GitModules" },
  [".editorconfig"] = { icon = "", color = P.slate, name = "EditorConfig" },
  [".env"] = { icon = "", color = P.amber, name = "Env" },
  [".env.local"] = { icon = "", color = P.amber, name = "EnvLocal" },
  [".env.development"] = { icon = "", color = P.amber, name = "EnvDev" },
  [".env.production"] = { icon = "", color = P.amber, name = "EnvProd" },
  [".env.example"] = { icon = "", color = P.slate, name = "EnvExample" },
  ["package.json"] = { icon = "", color = P.rose, name = "PackageJson" },
  ["package-lock.json"] = { icon = "", color = P.sand, name = "PackageLockJson" },
  ["yarn.lock"] = { icon = "", color = P.azure, name = "YarnLock" },
  ["pnpm-lock.yaml"] = { icon = "", color = P.amber, name = "PnpmLock" },
  ["bun.lock"] = { icon = "", color = P.sand, name = "BunLock" },
  ["bun.lockb"] = { icon = "", color = P.sand, name = "BunLockb" },
  ["tsconfig.json"] = { icon = "", color = P.azure, name = "TSConfig" },
  ["jsconfig.json"] = { icon = "", color = P.amber, name = "JSConfig" },
  ["go.mod"] = { icon = "", color = P.azure, name = "GoMod" },
  ["go.sum"] = { icon = "", color = P.blossom, name = "GoSum" },
  ["Cargo.toml"] = { icon = "", color = P.coral, name = "CargoToml" },
  ["cargo.toml"] = { icon = "", color = P.coral, name = "CargoToml" },
  ["Cargo.lock"] = { icon = "", color = P.sand, name = "CargoLock" },
  ["pyproject.toml"] = { icon = "", color = P.amber, name = "PyprojectToml" },
  ["requirements.txt"] = { icon = "", color = P.aurora, name = "RequirementsTxt" },
  ["Dockerfile"] = { icon = "", color = P.aurora, name = "Dockerfile" },
  ["dockerfile"] = { icon = "", color = P.aurora, name = "Dockerfile" },
  ["docker-compose.yml"] = { icon = "", color = P.aurora, name = "DockerCompose" },
  ["docker-compose.yaml"] = { icon = "", color = P.aurora, name = "DockerCompose" },
  ["compose.yml"] = { icon = "", color = P.aurora, name = "DockerCompose" },
  ["compose.yaml"] = { icon = "", color = P.aurora, name = "DockerCompose" },
  [".dockerignore"] = { icon = "", color = P.slate, name = "DockerIgnore" },
  ["Makefile"] = { icon = "", color = P.amber, name = "Makefile" },
  ["makefile"] = { icon = "", color = P.amber, name = "Makefile" },
  ["CMakeLists.txt"] = { icon = "", color = P.azure, name = "CMakeLists" },
  ["README.md"] = { icon = "", color = P.azure, name = "Readme" },
  ["readme.md"] = { icon = "", color = P.azure, name = "Readme" },
  ["README"] = { icon = "", color = P.azure, name = "Readme" },
  ["LICENSE"] = { icon = "", color = P.amber, name = "License" },
  ["license"] = { icon = "", color = P.amber, name = "License" },
  ["LICENSE.md"] = { icon = "", color = P.amber, name = "LicenseMd" },
  ["CHANGELOG.md"] = { icon = "", color = P.mint, name = "ChangelogMd" },
}

M.folder_specs = {
  src = { closed = "", open = "", hl = "MinimalFolderAzure" },
  source = { closed = "", open = "", hl = "MinimalFolderAzure" },
  sources = { closed = "", open = "", hl = "MinimalFolderAzure" },
  app = { closed = "", open = "", hl = "MinimalFolderAzure" },
  apps = { closed = "", open = "", hl = "MinimalFolderAzure" },
  core = { closed = "", open = "", hl = "MinimalFolderAzure" },
  cmd = { closed = "", open = "", hl = "MinimalFolderAzure" },
  pkg = { closed = "", open = "", hl = "MinimalFolderAzure" },
  internal = { closed = "", open = "", hl = "MinimalFolderAzure" },
  packages = { closed = "", open = "", hl = "MinimalFolderAzure" },

  components = { closed = "", open = "", hl = "MinimalFolderMint" },
  component = { closed = "", open = "", hl = "MinimalFolderMint" },
  ui = { closed = "", open = "", hl = "MinimalFolderMint" },
  views = { closed = "", open = "", hl = "MinimalFolderMint" },
  view = { closed = "", open = "", hl = "MinimalFolderMint" },
  layouts = { closed = "", open = "", hl = "MinimalFolderMint" },
  layout = { closed = "", open = "", hl = "MinimalFolderMint" },
  widgets = { closed = "", open = "", hl = "MinimalFolderMint" },
  templates = { closed = "", open = "", hl = "MinimalFolderMint" },
  db = { closed = "", open = "", hl = "MinimalFolderMint" },
  database = { closed = "", open = "", hl = "MinimalFolderMint" },
  databases = { closed = "", open = "", hl = "MinimalFolderMint" },
  prisma = { closed = "", open = "", hl = "MinimalFolderMint" },
  supabase = { closed = "", open = "", hl = "MinimalFolderMint" },
  migrations = { closed = "", open = "", hl = "MinimalFolderMint" },
  schema = { closed = "", open = "", hl = "MinimalFolderMint" },
  schemas = { closed = "", open = "", hl = "MinimalFolderMint" },
  models = { closed = "", open = "", hl = "MinimalFolderMint" },
  model = { closed = "", open = "", hl = "MinimalFolderMint" },
  data = { closed = "", open = "", hl = "MinimalFolderMint" },

  pages = { closed = "", open = "", hl = "MinimalFolderAurora" },
  page = { closed = "", open = "", hl = "MinimalFolderAurora" },
  routes = { closed = "", open = "", hl = "MinimalFolderAurora" },
  route = { closed = "", open = "", hl = "MinimalFolderAurora" },
  router = { closed = "", open = "", hl = "MinimalFolderAurora" },
  docs = { closed = "", open = "", hl = "MinimalFolderAurora" },
  doc = { closed = "", open = "", hl = "MinimalFolderAurora" },
  documentation = { closed = "", open = "", hl = "MinimalFolderAurora" },
  docker = { closed = "", open = "", hl = "MinimalFolderAurora" },
  [".docker"] = { closed = "", open = "", hl = "MinimalFolderAurora" },
  k8s = { closed = "", open = "", hl = "MinimalFolderAurora" },
  kubernetes = { closed = "", open = "", hl = "MinimalFolderAurora" },
  deploy = { closed = "", open = "", hl = "MinimalFolderAurora" },

  api = { closed = "", open = "", hl = "MinimalFolderCoral" },
  apis = { closed = "", open = "", hl = "MinimalFolderCoral" },
  server = { closed = "", open = "", hl = "MinimalFolderCoral" },
  backend = { closed = "", open = "", hl = "MinimalFolderCoral" },
  controllers = { closed = "", open = "", hl = "MinimalFolderCoral" },
  controller = { closed = "", open = "", hl = "MinimalFolderCoral" },
  handlers = { closed = "", open = "", hl = "MinimalFolderCoral" },
  handler = { closed = "", open = "", hl = "MinimalFolderCoral" },
  [".git"] = { closed = "", open = "", hl = "MinimalFolderCoral" },
  [".github"] = { closed = "", open = "", hl = "MinimalFolderIris" },
  [".gitlab"] = { closed = "", open = "", hl = "MinimalFolderCoral" },

  hooks = { closed = "", open = "", hl = "MinimalFolderIris" },
  hook = { closed = "", open = "", hl = "MinimalFolderIris" },
  utils = { closed = "", open = "", hl = "MinimalFolderIris" },
  util = { closed = "", open = "", hl = "MinimalFolderIris" },
  helpers = { closed = "", open = "", hl = "MinimalFolderIris" },
  lib = { closed = "", open = "", hl = "MinimalFolderIris" },
  libs = { closed = "", open = "", hl = "MinimalFolderIris" },
  shared = { closed = "", open = "", hl = "MinimalFolderIris" },
  common = { closed = "", open = "", hl = "MinimalFolderIris" },
  services = { closed = "", open = "", hl = "MinimalFolderIris" },
  service = { closed = "", open = "", hl = "MinimalFolderIris" },
  middleware = { closed = "", open = "", hl = "MinimalFolderIris" },
  store = { closed = "", open = "", hl = "MinimalFolderIris" },
  state = { closed = "", open = "", hl = "MinimalFolderIris" },
  context = { closed = "", open = "", hl = "MinimalFolderIris" },
  providers = { closed = "", open = "", hl = "MinimalFolderIris" },
  types = { closed = "", open = "", hl = "MinimalFolderIris" },
  interfaces = { closed = "", open = "", hl = "MinimalFolderIris" },
  modules = { closed = "", open = "", hl = "MinimalFolderIris" },
  plugins = { closed = "", open = "", hl = "MinimalFolderIris" },
  lua = { closed = "", open = "", hl = "MinimalFolderAzure" },
  scripts = { closed = "", open = "", hl = "MinimalFolderEmerald" },
  script = { closed = "", open = "", hl = "MinimalFolderEmerald" },
  bin = { closed = "", open = "", hl = "MinimalFolderIris" },
  [".vscode"] = { closed = "", open = "", hl = "MinimalFolderAzure" },

  test = { closed = "", open = "", hl = "MinimalFolderEmerald" },
  tests = { closed = "", open = "", hl = "MinimalFolderEmerald" },
  ["__tests__"] = { closed = "", open = "", hl = "MinimalFolderEmerald" },
  spec = { closed = "", open = "", hl = "MinimalFolderEmerald" },
  specs = { closed = "", open = "", hl = "MinimalFolderEmerald" },
  e2e = { closed = "", open = "", hl = "MinimalFolderEmerald" },
  cypress = { closed = "", open = "", hl = "MinimalFolderEmerald" },
  playwright = { closed = "", open = "", hl = "MinimalFolderEmerald" },
  ["__mocks__"] = { closed = "", open = "", hl = "MinimalFolderLime" },
  mocks = { closed = "", open = "", hl = "MinimalFolderLime" },
  fixtures = { closed = "", open = "", hl = "MinimalFolderLime" },
  node_modules = { closed = "", open = "", hl = "MinimalFolderSlate" },

  assets = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  images = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  img = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  imgs = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  icons = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  icon = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  media = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  fonts = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  font = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  svg = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  styles = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  style = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  css = { closed = "", open = "", hl = "MinimalFolderAzure" },
  scss = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  themes = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  theme = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  colors = { closed = "", open = "", hl = "MinimalFolderBlossom" },
  desktop = { closed = "", open = "", hl = "MinimalFolderBlossom" },

  config = { closed = "", open = "", hl = "MinimalFolderAmber" },
  configs = { closed = "", open = "", hl = "MinimalFolderAmber" },
  conf = { closed = "", open = "", hl = "MinimalFolderAmber" },
  settings = { closed = "", open = "", hl = "MinimalFolderAmber" },
  public = { closed = "", open = "", hl = "MinimalFolderAmber" },
  static = { closed = "", open = "", hl = "MinimalFolderAmber" },
  dist = { closed = "", open = "", hl = "MinimalFolderSand" },
  build = { closed = "", open = "", hl = "MinimalFolderSand" },
  out = { closed = "", open = "", hl = "MinimalFolderSand" },
  output = { closed = "", open = "", hl = "MinimalFolderSand" },
  target = { closed = "", open = "", hl = "MinimalFolderSand" },
  logs = { closed = "", open = "", hl = "MinimalFolderSand" },
  log = { closed = "", open = "", hl = "MinimalFolderSand" },
  vendor = { closed = "", open = "", hl = "MinimalFolderSlate" },
  [".venv"] = { closed = "", open = "", hl = "MinimalFolderSlate" },
  venv = { closed = "", open = "", hl = "MinimalFolderSlate" },
  [".cache"] = { closed = "", open = "", hl = "MinimalFolderSlate" },
  tmp = { closed = "", open = "", hl = "MinimalFolderSlate" },
  temp = { closed = "", open = "", hl = "MinimalFolderSlate" },

  auth = { closed = "", open = "", hl = "MinimalFolderRose" },
  security = { closed = "", open = "", hl = "MinimalFolderRose" },
  keys = { closed = "", open = "", hl = "MinimalFolderRose" },
  certs = { closed = "", open = "", hl = "MinimalFolderRose" },
}

local FOLDER_NAME_PATTERNS = {
  { pat = "test", closed = "", open = "", hl = "MinimalFolderEmerald" },
  { pat = "spec", closed = "", open = "", hl = "MinimalFolderEmerald" },
  { pat = "mock", closed = "", open = "", hl = "MinimalFolderLime" },
  { pat = "handler", closed = "", open = "", hl = "MinimalFolderCoral" },
  { pat = "control", closed = "", open = "", hl = "MinimalFolderCoral" },
  { pat = "rout", closed = "", open = "", hl = "MinimalFolderAurora" },
  { pat = "service", closed = "", open = "", hl = "MinimalFolderIris" },
  { pat = "hook", closed = "", open = "", hl = "MinimalFolderIris" },
  { pat = "util", closed = "", open = "", hl = "MinimalFolderIris" },
  { pat = "helper", closed = "", open = "", hl = "MinimalFolderIris" },
  { pat = "config", closed = "", open = "", hl = "MinimalFolderAmber" },
  { pat = "setting", closed = "", open = "", hl = "MinimalFolderAmber" },
  { pat = "component", closed = "", open = "", hl = "MinimalFolderMint" },
  { pat = "model", closed = "", open = "", hl = "MinimalFolderMint" },
  { pat = "schema", closed = "", open = "", hl = "MinimalFolderMint" },
  { pat = "migrat", closed = "", open = "", hl = "MinimalFolderMint" },
  { pat = "style", closed = "", open = "", hl = "MinimalFolderBlossom" },
  { pat = "theme", closed = "", open = "", hl = "MinimalFolderBlossom" },
  { pat = "asset", closed = "", open = "", hl = "MinimalFolderBlossom" },
  { pat = "image", closed = "", open = "", hl = "MinimalFolderBlossom" },
  { pat = "font", closed = "", open = "", hl = "MinimalFolderBlossom" },
  { pat = "doc", closed = "", open = "", hl = "MinimalFolderAurora" },
  { pat = "script", closed = "", open = "", hl = "MinimalFolderEmerald" },
  { pat = "auth", closed = "", open = "", hl = "MinimalFolderRose" },
  { pat = "docker", closed = "", open = "", hl = "MinimalFolderAurora" },
}

local FILE_NAME_ROLES = {
  { pat = "^test_", icon = "", fixed_color = P.emerald },
  { pat = "_test%.", icon = "", fixed_color = P.emerald },
  { pat = "%.test%.", icon = "", fixed_color = P.emerald },
  { pat = "%.spec%.", icon = "", fixed_color = P.emerald },
  { pat = "^spec_", icon = "", fixed_color = P.emerald },
  { pat = "%.d%.ts$", icon = "", fixed_color = P.iris },
  { pat = "^%.env", icon = "", fixed_color = P.amber },
  { pat = "^dockerfile", icon = "", fixed_color = P.aurora },
  { pat = "compose%.ya?ml$", icon = "", fixed_color = P.aurora },
  { pat = "^readme", icon = "", fixed_color = P.azure },
  { pat = "^license", icon = "", fixed_color = P.amber },
  { pat = "^changelog", icon = "", fixed_color = P.mint },
  { pat = "^contributing", icon = "", fixed_color = P.mint },
  { pat = "^security", icon = "", fixed_color = P.rose },
  { pat = "%.config%.", icon = "", use_lang_color = true },
  { pat = "^config%.", icon = "", use_lang_color = true },
  { pat = "_config%.", icon = "", use_lang_color = true },
  { pat = "^settings?%.", icon = "", use_lang_color = true },
  { pat = "^vite%.config", icon = "", fixed_color = P.iris },
  { pat = "^tailwind%.config", icon = "", fixed_color = P.mint },
  { pat = "^eslint", icon = "", fixed_color = P.iris },
  { pat = "^%.?prettier", icon = "", fixed_color = P.mint },
  { pat = "^main%.", icon = "", use_lang_color = true },
  { pat = "^index%.", icon = "", use_lang_color = true },
  { pat = "^app%.", icon = "", use_lang_color = true },
  { pat = "router", icon = "", use_lang_color = true },
  { pat = "routes?", icon = "", use_lang_color = true },
  { pat = "handler", icon = "", use_lang_color = true },
  { pat = "controller", icon = "", use_lang_color = true },
  { pat = "service", icon = "", use_lang_color = true },
  { pat = "worker", icon = "", use_lang_color = true },
  { pat = "middleware", icon = "", use_lang_color = true },
  { pat = "schema", icon = "", use_lang_color = true },
  { pat = "model", icon = "", use_lang_color = true },
  { pat = "migrat", icon = "", use_lang_color = true },
  { pat = "hook", icon = "", use_lang_color = true },
  { pat = "util", icon = "", use_lang_color = true },
  { pat = "helper", icon = "", use_lang_color = true },
  { pat = "auth", icon = "", use_lang_color = true },
  { pat = "secret", icon = "", fixed_color = P.rose },
}

local HL_COLOR_GROUPS = {
  MinimalFolderSlate = P.slate,
  MinimalFolderSlateOpen = P.slate_open,
  MinimalFolderMuted = P.muted,
  MinimalFolderStarlight = P.starlight,
  MinimalFolderAzure = P.azure,
  MinimalFolderAurora = P.aurora,
  MinimalFolderMint = P.mint,
  MinimalFolderEmerald = P.emerald,
  MinimalFolderLime = P.lime,
  MinimalFolderAmber = P.amber,
  MinimalFolderCoral = P.coral,
  MinimalFolderRose = P.rose,
  MinimalFolderBlossom = P.blossom,
  MinimalFolderIris = P.iris,
  MinimalFolderSand = P.sand,
}

local dynamic_color_hl = {}
local function get_hl_for_hex(hex)
  local c = (type(hex) == "string" and hex:match("^#%x%x%x%x%x%x$")) and hex:lower() or P.starlight:lower()
  local grp = dynamic_color_hl[c]
  if not grp then
    grp = "MinimalIconHex_" .. c:sub(2)
    dynamic_color_hl[c] = grp
    vim.api.nvim_set_hl(0, grp, { fg = c })
  else
    local cur = vim.api.nvim_get_hl(0, { name = grp })
    if not cur or not cur.fg then
      vim.api.nvim_set_hl(0, grp, { fg = c })
    end
  end
  return grp
end

function M.apply_highlights()
  for group, fg in pairs(HL_COLOR_GROUPS) do
    vim.api.nvim_set_hl(0, group, { fg = fg })
  end
  for hex, grp in pairs(dynamic_color_hl) do
    vim.api.nvim_set_hl(0, grp, { fg = hex })
  end

  vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = P.slate })
  vim.api.nvim_set_hl(0, "NvimTreeClosedFolderIcon", { fg = P.slate })
  vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderIcon", { fg = P.slate_open })
  vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderIcon", { fg = P.muted })
  vim.api.nvim_set_hl(0, "NvimTreeSymlinkFolderIcon", { fg = P.aurora })
  vim.api.nvim_set_hl(0, "NvimTreeFolderArrowClosed", { fg = P.muted })
  vim.api.nvim_set_hl(0, "NvimTreeFolderArrowOpen", { fg = P.slate })
  vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = "#4b5263" })

  vim.api.nvim_set_hl(0, "NvimTreeFileIcon", { fg = P.starlight })
  vim.api.nvim_set_hl(0, "DevIconDefault", { fg = P.starlight })
  vim.api.nvim_set_hl(0, "NvimTreeGitDirtyIcon", { fg = P.amber })
  vim.api.nvim_set_hl(0, "NvimTreeGitStagedIcon", { fg = P.emerald })
  vim.api.nvim_set_hl(0, "NvimTreeGitNewIcon", { fg = P.emerald })
  vim.api.nvim_set_hl(0, "NvimTreeGitDeletedIcon", { fg = P.rose })
  vim.api.nvim_set_hl(0, "NvimTreeGitRenamedIcon", { fg = P.iris })
  vim.api.nvim_set_hl(0, "NvimTreeGitIgnoredIcon", { fg = P.muted })
  vim.api.nvim_set_hl(0, "NvimTreeGitDirty", { fg = P.amber, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitStaged", { fg = P.emerald, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitNew", { fg = P.emerald, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", { fg = P.rose })
  vim.api.nvim_set_hl(0, "NvimTreeGitRenamed", { fg = P.iris })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticErrorFileHLGroup", { fg = P.rose, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticWarnFileHLGroup", { fg = P.amber, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticInfoFileHLGroup", { fg = P.azure, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticHintFileHLGroup", { fg = P.mint, bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticErrorIconHLGroup", { fg = P.rose })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticWarnIconHLGroup", { fg = P.amber })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticInfoIconHLGroup", { fg = P.azure })
  vim.api.nvim_set_hl(0, "NvimTreeDiagnosticHintIconHLGroup", { fg = P.mint })
end

function M.setup_devicons()
  local ok_dev, devicons = pcall(require, "nvim-web-devicons")
  if not ok_dev then return end

  local existing_icons = devicons.get_icons()
  local harmonized = {}
  for key, meta in pairs(existing_icons or {}) do
    if type(meta) == "table" and meta.icon and meta.name then
      harmonized[key] = {
        icon = meta.icon,
        color = snap_to_palette(meta.color),
        name = meta.name,
      }
    end
  end
  for ext, meta in pairs(M.extension_overrides) do
    harmonized[ext] = meta
  end

  devicons.setup({
    default = true,
    color_icons = true,
    override = harmonized,
    override_by_extension = M.extension_overrides,
    override_by_filename = M.filename_overrides,
    default_icon = { icon = "", color = P.starlight, name = "Default" },
  })
  pcall(devicons.set_default_icon, "", P.starlight, 75)
  M.apply_highlights()
end

function M.resolve_file_icon(fname, ext, filetype)
  local ok_dev, d = pcall(require, "nvim-web-devicons")
  local name_str = fname or ""
  local ext_str = ext or ""
  if ext_str == "" and name_str:find("%.") then
    ext_str = name_str:match("%.([^%.]+)$") or ""
  end
  local lower_name = name_str:lower()
  local lower_ext = ext_str:lower()

  local exact = M.filename_overrides[name_str] or M.filename_overrides[lower_name]
  if exact then
    return exact.icon, get_hl_for_hex(exact.color)
  end

  local lang_meta = M.extension_overrides[lower_ext]
  local dev_icon, dev_hl, dev_color
  if ok_dev then
    dev_icon, dev_color = d.get_icon_color(name_str, ext_str, { default = false })
    if not dev_icon and filetype and filetype ~= "" then
      dev_icon, dev_color = d.get_icon_color_by_filetype(filetype, { default = false })
    end
    dev_icon, dev_hl = d.get_icon(name_str, ext_str, { default = false })
    if not dev_icon and filetype and filetype ~= "" then
      dev_icon, dev_hl = d.get_icon_by_filetype(filetype, { default = false })
    end
  end
  local lang_hex = (lang_meta and lang_meta.color) or (dev_color and snap_to_palette(dev_color)) or P.starlight

  if lower_name ~= "" then
    for _, rule in ipairs(FILE_NAME_ROLES) do
      if lower_name:find(rule.pat) then
        local color_hex = rule.fixed_color or lang_hex
        return rule.icon, get_hl_for_hex(color_hex)
      end
    end
  end

  if lang_meta then
    return lang_meta.icon, get_hl_for_hex(lang_meta.color)
  end
  if dev_icon and dev_hl then
    return dev_icon, dev_hl
  end
  return "", get_hl_for_hex(P.starlight)
end

function M.resolve_folder_icon(folder_name, is_open, is_empty)
  local key = (folder_name or ""):lower()
  local spec = M.folder_specs[key]
  if not spec and key ~= "" then
    for _, rule in ipairs(FOLDER_NAME_PATTERNS) do
      if key:find(rule.pat, 1, true) then
        spec = rule
        break
      end
    end
  end
  if spec then
    return (is_open and spec.open or spec.closed), spec.hl
  end
  if is_open then
    return "", "MinimalFolderSlateOpen"
  end
  if is_empty then
    return "", "MinimalFolderMuted"
  end
  return "", "MinimalFolderSlate"
end

function M.create_decorator(api)
  if not api or not api.Decorator then return nil end
  local MinimalIconDecorator = api.Decorator:extend()

  function MinimalIconDecorator:new()
    self.enabled = true
    self.highlight_range = "none"
    self.icon_placement = "none"
  end

  function MinimalIconDecorator:icon_node(node)
    if not node then return nil end
    if node.type == "directory" then
      local is_empty = (node.has_children == false) and (#(node.nodes or {}) == 0)
      local icon_str, hl_grp = M.resolve_folder_icon(node.name, node.open, is_empty)
      return { str = icon_str, hl = { hl_grp } }
    elseif node.type == "file" then
      local icon_str, hl_grp = M.resolve_file_icon(node.name, node.extension, nil)
      return { str = icon_str, hl = { hl_grp } }
    end
    return nil
  end

  return MinimalIconDecorator
end

return M
