-- ===================================================================
-- Minimal High-Definition Icon Theme
-- Curated, context-aware, large & related icons with vibrant palette
-- Flow & Zed design aesthetic: modern Nerd Font v3 glyphs
-- ===================================================================

local M = {}

M.opts = {
  style = "glyph",
  default = {
    file = { glyph = "󰈔 ", hl = "MiniIconsGrey" },
    directory = { glyph = "󰉍 ", hl = "MiniIconsBlue" },
    extension = { glyph = "󰈔 ", hl = "MiniIconsGrey" },
  },
  directory = {
    -- Core & Source Architecture
    src            = { glyph = "󰉍 ", hl = "MiniIconsAzure" },
    app            = { glyph = "󰉍 ", hl = "MiniIconsAzure" },
    core           = { glyph = "󰉍 ", hl = "MiniIconsAzure" },
    pkg            = { glyph = "󰉍 ", hl = "MiniIconsAzure" },
    cmd            = { glyph = "󰉍 ", hl = "MiniIconsAzure" },
    internal       = { glyph = "󰉍 ", hl = "MiniIconsAzure" },
    main           = { glyph = "󰉍 ", hl = "MiniIconsAzure" },

    -- UI, Components & Views
    components     = { glyph = "󰉍 ", hl = "MiniIconsCyan" },
    ui             = { glyph = "󰉍 ", hl = "MiniIconsCyan" },
    views          = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    pages          = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    screens        = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    routes         = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    layouts        = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    widgets        = { glyph = "󰉍 ", hl = "MiniIconsCyan" },

    -- Backend, APIs & Network
    api            = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    server         = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    services       = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    controllers    = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    handlers       = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    middleware     = { glyph = "󰉍 ", hl = "MiniIconsYellow" },
    models         = { glyph = "󰉍 ", hl = "MiniIconsOrange" },
    database       = { glyph = "󰉍 ", hl = "MiniIconsOrange" },
    db             = { glyph = "󰉍 ", hl = "MiniIconsOrange" },
    migrations     = { glyph = "󰉍 ", hl = "MiniIconsOrange" },

    -- Static, Public & Assets
    public         = { glyph = "󰉍 ", hl = "MiniIconsGreen" },
    assets         = { glyph = "󰉍 ", hl = "MiniIconsGreen" },
    static         = { glyph = "󰉍 ", hl = "MiniIconsGreen" },
    images         = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    img            = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    icons          = { glyph = "󰉍 ", hl = "MiniIconsYellow" },
    fonts          = { glyph = "󰉍 ", hl = "MiniIconsOrange" },
    media          = { glyph = "󰉍 ", hl = "MiniIconsPurple" },

    -- Styling & Design Systems
    styles         = { glyph = "󰉍 ", hl = "MiniIconsAzure" },
    css            = { glyph = "󰉍 ", hl = "MiniIconsAzure" },
    scss           = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    sass           = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    themes         = { glyph = "󰉍 ", hl = "MiniIconsPurple" },

    -- Utilities, Helpers & State
    utils          = { glyph = "󰉍 ", hl = "MiniIconsYellow" },
    util           = { glyph = "󰉍 ", hl = "MiniIconsYellow" },
    lib            = { glyph = "󰉍 ", hl = "MiniIconsAzure" },
    libs           = { glyph = "󰉍 ", hl = "MiniIconsAzure" },
    helpers        = { glyph = "󰉍 ", hl = "MiniIconsYellow" },
    common         = { glyph = "󰉍 ", hl = "MiniIconsYellow" },
    shared         = { glyph = "󰉍 ", hl = "MiniIconsYellow" },
    hooks          = { glyph = "󰉍 ", hl = "MiniIconsCyan" },
    state          = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    store          = { glyph = "󰉍 ", hl = "MiniIconsPurple" },
    context        = { glyph = "󰉍 ", hl = "MiniIconsPurple" },

    -- Quality Assurance & Testing
    test           = { glyph = "󰉍 ", hl = "MiniIconsRed" },
    tests          = { glyph = "󰉍 ", hl = "MiniIconsRed" },
    spec           = { glyph = "󰉍 ", hl = "MiniIconsRed" },
    specs          = { glyph = "󰉍 ", hl = "MiniIconsRed" },
    __tests__      = { glyph = "󰉍 ", hl = "MiniIconsRed" },
    coverage       = { glyph = "󰉍 ", hl = "MiniIconsGreen" },

    -- Tooling, Config & CI/CD
    config         = { glyph = "󰉍 ", hl = "MiniIconsCyan" },
    configs        = { glyph = "󰉍 ", hl = "MiniIconsCyan" },
    [".config"]    = { glyph = "󰉍 ", hl = "MiniIconsCyan" },
    [".github"]    = { glyph = "󰉍 ", hl = "MiniIconsAzure" },
    [".gitlab"]    = { glyph = "󰉍 ", hl = "MiniIconsOrange" },
    [".vscode"]    = { glyph = "󰉍 ", hl = "MiniIconsBlue" },
    [".husky"]     = { glyph = "󰉍 ", hl = "MiniIconsGrey" },
    [".git"]       = { glyph = "󰊢 ", hl = "MiniIconsOrange" },
    scripts        = { glyph = "󰉍 ", hl = "MiniIconsGreen" },
    tools          = { glyph = "󰉍 ", hl = "MiniIconsYellow" },
    docs           = { glyph = "󰉍 ", hl = "MiniIconsBlue" },
    documentation  = { glyph = "󰉍 ", hl = "MiniIconsBlue" },

    -- Output & Dependency Caches
    dist           = { glyph = "󰉍 ", hl = "MiniIconsGrey" },
    build          = { glyph = "󰉍 ", hl = "MiniIconsGrey" },
    out            = { glyph = "󰉍 ", hl = "MiniIconsGrey" },
    target         = { glyph = "󰉍 ", hl = "MiniIconsGrey" },
    bin            = { glyph = "󰉍 ", hl = "MiniIconsGrey" },
    node_modules   = { glyph = "󰉍 ", hl = "MiniIconsGrey" },
    vendor         = { glyph = "󰉍 ", hl = "MiniIconsGrey" },
    [".cache"]     = { glyph = "󰉍 ", hl = "MiniIconsGrey" },
    [".next"]      = { glyph = "󰉍 ", hl = "MiniIconsGrey" },
    [".nuxt"]      = { glyph = "󰉍 ", hl = "MiniIconsGrey" },
    [".output"]    = { glyph = "󰉍 ", hl = "MiniIconsGrey" },
  },

  file = {
    -- Special Dotfiles & Configurations
    [".keep"]               = { glyph = "󰊢 ", hl = "MiniIconsGrey" },
    ["devcontainer.json"]   = { glyph = " ", hl = "MiniIconsAzure" },
    [".env"]                = { glyph = " ", hl = "MiniIconsYellow" },
    [".env.local"]          = { glyph = " ", hl = "MiniIconsYellow" },
    [".env.development"]    = { glyph = " ", hl = "MiniIconsYellow" },
    [".env.production"]     = { glyph = " ", hl = "MiniIconsYellow" },
    [".env.staging"]        = { glyph = " ", hl = "MiniIconsYellow" },
    [".env.test"]           = { glyph = " ", hl = "MiniIconsYellow" },
    [".env.example"]        = { glyph = " ", hl = "MiniIconsYellow" },
    [".gitignore"]          = { glyph = " ", hl = "MiniIconsOrange" },
    [".gitmodules"]         = { glyph = " ", hl = "MiniIconsOrange" },
    [".gitattributes"]      = { glyph = " ", hl = "MiniIconsOrange" },

    -- Docker & Containers
    ["docker-compose.yml"]  = { glyph = "󰡨 ", hl = "MiniIconsAzure" },
    ["docker-compose.yaml"] = { glyph = "󰡨 ", hl = "MiniIconsAzure" },
    ["compose.yml"]         = { glyph = "󰡨 ", hl = "MiniIconsAzure" },
    ["compose.yaml"]        = { glyph = "󰡨 ", hl = "MiniIconsAzure" },
    ["Dockerfile"]          = { glyph = "󰡨 ", hl = "MiniIconsAzure" },
    ["dockerfile"]          = { glyph = "󰡨 ", hl = "MiniIconsAzure" },
    [".dockerignore"]       = { glyph = "󰡨 ", hl = "MiniIconsGrey" },

    -- Node, JS & TS Project Badges
    ["package.json"]        = { glyph = " ", hl = "MiniIconsGreen" },
    ["package-lock.json"]   = { glyph = " ", hl = "MiniIconsRed" },
    ["pnpm-lock.yaml"]      = { glyph = " ", hl = "MiniIconsRed" },
    ["yarn.lock"]           = { glyph = " ", hl = "MiniIconsRed" },
    ["bun.lockb"]           = { glyph = " ", hl = "MiniIconsRed" },
    ["bun.lock"]            = { glyph = " ", hl = "MiniIconsRed" },
    ["tsconfig.json"]       = { glyph = "󰛦 ", hl = "MiniIconsAzure" },
    ["tsconfig.node.json"]  = { glyph = "󰛦 ", hl = "MiniIconsAzure" },
    ["jsconfig.json"]       = { glyph = "󰌞 ", hl = "MiniIconsYellow" },
    ["vite.config.ts"]      = { glyph = "󱐋 ", hl = "MiniIconsYellow" },
    ["vite.config.js"]      = { glyph = "󱐋 ", hl = "MiniIconsYellow" },
    ["vite.config.mjs"]     = { glyph = "󱐋 ", hl = "MiniIconsYellow" },
    ["tailwind.config.js"]  = { glyph = "󱏿 ", hl = "MiniIconsCyan" },
    ["tailwind.config.ts"]  = { glyph = "󱏿 ", hl = "MiniIconsCyan" },
    ["next.config.js"]      = { glyph = " ", hl = "MiniIconsGrey" },
    ["next.config.mjs"]     = { glyph = " ", hl = "MiniIconsGrey" },
    ["next.config.ts"]      = { glyph = " ", hl = "MiniIconsGrey" },
    ["astro.config.mjs"]    = { glyph = " ", hl = "MiniIconsOrange" },
    ["svelte.config.js"]    = { glyph = " ", hl = "MiniIconsOrange" },

    -- Polyglot Package Manifests
    ["go.mod"]              = { glyph = " ", hl = "MiniIconsCyan" },
    ["go.sum"]              = { glyph = " ", hl = "MiniIconsCyan" },
    ["go.work"]             = { glyph = " ", hl = "MiniIconsCyan" },
    ["Cargo.toml"]          = { glyph = "󰏗 ", hl = "MiniIconsOrange" },
    ["Cargo.lock"]          = { glyph = "󰏗 ", hl = "MiniIconsGrey" },
    ["requirements.txt"]    = { glyph = "󰌠 ", hl = "MiniIconsYellow" },
    ["Pipfile"]             = { glyph = "󰌠 ", hl = "MiniIconsYellow" },
    ["Pipfile.lock"]        = { glyph = "󰌠 ", hl = "MiniIconsGrey" },
    ["pyproject.toml"]      = { glyph = "󰌠 ", hl = "MiniIconsYellow" },
    ["Makefile"]            = { glyph = " ", hl = "MiniIconsOrange" },
    ["makefile"]            = { glyph = " ", hl = "MiniIconsOrange" },
    ["GNUmakefile"]         = { glyph = " ", hl = "MiniIconsOrange" },
    ["CMakeLists.txt"]      = { glyph = " ", hl = "MiniIconsBlue" },

    -- Documentation & Meta
    ["README.md"]           = { glyph = "󰍔 ", hl = "MiniIconsCyan" },
    ["README"]              = { glyph = "󰍔 ", hl = "MiniIconsCyan" },
    ["CHANGELOG.md"]        = { glyph = "󰞋 ", hl = "MiniIconsGreen" },
    ["CHANGELOG"]           = { glyph = "󰞋 ", hl = "MiniIconsGreen" },
    ["LICENSE"]             = { glyph = "󰌆 ", hl = "MiniIconsYellow" },
    ["LICENSE.md"]          = { glyph = "󰌆 ", hl = "MiniIconsYellow" },
    ["LICENSE.txt"]         = { glyph = "󰌆 ", hl = "MiniIconsYellow" },
  },

  extension = {
    -- Web Core
    ts         = { glyph = "󰛦 ", hl = "MiniIconsAzure" },
    tsx        = { glyph = " ", hl = "MiniIconsBlue" },
    js         = { glyph = "󰌞 ", hl = "MiniIconsYellow" },
    jsx        = { glyph = " ", hl = "MiniIconsBlue" },
    mjs        = { glyph = "󰌞 ", hl = "MiniIconsYellow" },
    cjs        = { glyph = "󰌞 ", hl = "MiniIconsYellow" },
    html       = { glyph = "󰌝 ", hl = "MiniIconsOrange" },
    htm        = { glyph = "󰌝 ", hl = "MiniIconsOrange" },
    css        = { glyph = "󰌜 ", hl = "MiniIconsAzure" },
    scss       = { glyph = " ", hl = "MiniIconsPurple" },
    sass       = { glyph = " ", hl = "MiniIconsPurple" },
    less       = { glyph = " ", hl = "MiniIconsBlue" },

    -- Frontend Frameworks
    vue        = { glyph = "󰡄 ", hl = "MiniIconsGreen" },
    svelte     = { glyph = " ", hl = "MiniIconsOrange" },
    astro      = { glyph = " ", hl = "MiniIconsOrange" },

    -- Systems & Compilers
    go         = { glyph = " ", hl = "MiniIconsCyan" },
    py         = { glyph = "󰌠 ", hl = "MiniIconsYellow" },
    pyi        = { glyph = "󰌠 ", hl = "MiniIconsYellow" },
    rs         = { glyph = "󱘗 ", hl = "MiniIconsOrange" },
    c          = { glyph = " ", hl = "MiniIconsBlue" },
    cpp        = { glyph = " ", hl = "MiniIconsBlue" },
    cc         = { glyph = " ", hl = "MiniIconsBlue" },
    cxx        = { glyph = " ", hl = "MiniIconsBlue" },
    h          = { glyph = " ", hl = "MiniIconsPurple" },
    hpp        = { glyph = " ", hl = "MiniIconsPurple" },
    java       = { glyph = " ", hl = "MiniIconsRed" },
    kt         = { glyph = " ", hl = "MiniIconsPurple" },
    kts        = { glyph = " ", hl = "MiniIconsPurple" },
    cs         = { glyph = "󰌛 ", hl = "MiniIconsGreen" },
    fs         = { glyph = " ", hl = "MiniIconsCyan" },
    swift      = { glyph = " ", hl = "MiniIconsOrange" },
    zig        = { glyph = " ", hl = "MiniIconsOrange" },
    lua        = { glyph = " ", hl = "MiniIconsAzure" },

    -- Shell & Scripts
    sh         = { glyph = " ", hl = "MiniIconsGreen" },
    bash       = { glyph = " ", hl = "MiniIconsGreen" },
    zsh        = { glyph = " ", hl = "MiniIconsGreen" },
    fish       = { glyph = " ", hl = "MiniIconsGreen" },
    ps1        = { glyph = "󰨊 ", hl = "MiniIconsAzure" },
    bat        = { glyph = " ", hl = "MiniIconsGrey" },
    cmd        = { glyph = " ", hl = "MiniIconsGrey" },

    -- Structured Data & Configs
    json       = { glyph = " ", hl = "MiniIconsYellow" },
    jsonc      = { glyph = " ", hl = "MiniIconsYellow" },
    json5      = { glyph = " ", hl = "MiniIconsYellow" },
    yaml       = { glyph = "󰋽 ", hl = "MiniIconsPurple" },
    yml        = { glyph = "󰋽 ", hl = "MiniIconsPurple" },
    toml       = { glyph = " ", hl = "MiniIconsOrange" },
    xml        = { glyph = "󰗀 ", hl = "MiniIconsOrange" },
    csv        = { glyph = "󰈙 ", hl = "MiniIconsGreen" },
    tsv        = { glyph = "󰈙 ", hl = "MiniIconsGreen" },

    -- Database & Schemas
    sql        = { glyph = "󰆼 ", hl = "MiniIconsOrange" },
    prisma     = { glyph = " ", hl = "MiniIconsBlue" },
    graphql    = { glyph = "󰡷 ", hl = "MiniIconsRed" },
    gql        = { glyph = "󰡷 ", hl = "MiniIconsRed" },
    proto      = { glyph = "󰚩 ", hl = "MiniIconsAzure" },

    -- Documentation
    md         = { glyph = "󰍔 ", hl = "MiniIconsCyan" },
    markdown   = { glyph = "󰍔 ", hl = "MiniIconsCyan" },
    mdx        = { glyph = "󰍔 ", hl = "MiniIconsYellow" },
    pdf        = { glyph = "󰈦 ", hl = "MiniIconsRed" },
    txt        = { glyph = "󰈙 ", hl = "MiniIconsGrey" },

    -- Graphics & Media
    svg        = { glyph = "󰜡 ", hl = "MiniIconsOrange" },
    png        = { glyph = "󰉏 ", hl = "MiniIconsPurple" },
    jpg        = { glyph = "󰉏 ", hl = "MiniIconsPurple" },
    jpeg       = { glyph = "󰉏 ", hl = "MiniIconsPurple" },
    gif        = { glyph = "󰉏 ", hl = "MiniIconsPurple" },
    webp       = { glyph = "󰉏 ", hl = "MiniIconsPurple" },
    ico        = { glyph = "󰉏 ", hl = "MiniIconsYellow" },
    mp4        = { glyph = "󰈫 ", hl = "MiniIconsPurple" },
    mp3        = { glyph = "󰎆 ", hl = "MiniIconsPurple" },
    wav        = { glyph = "󰎆 ", hl = "MiniIconsPurple" },

    -- Archives & System
    zip        = { glyph = "󰛫 ", hl = "MiniIconsYellow" },
    tar        = { glyph = "󰛫 ", hl = "MiniIconsYellow" },
    gz         = { glyph = "󰛫 ", hl = "MiniIconsYellow" },
    ["7z"]     = { glyph = "󰛫 ", hl = "MiniIconsYellow" },
    lock       = { glyph = "󰌾 ", hl = "MiniIconsGrey" },
    wasm       = { glyph = "󰘚 ", hl = "MiniIconsPurple" },
  },

  filetype = {
    dotenv          = { glyph = " ", hl = "MiniIconsYellow" },
    typescript      = { glyph = "󰛦 ", hl = "MiniIconsAzure" },
    typescriptreact = { glyph = " ", hl = "MiniIconsBlue" },
    javascript      = { glyph = "󰌞 ", hl = "MiniIconsYellow" },
    javascriptreact = { glyph = " ", hl = "MiniIconsBlue" },
    go              = { glyph = " ", hl = "MiniIconsCyan" },
    python          = { glyph = "󰌠 ", hl = "MiniIconsYellow" },
    rust            = { glyph = "󱘗 ", hl = "MiniIconsOrange" },
    markdown        = { glyph = "󰍔 ", hl = "MiniIconsCyan" },
    sh              = { glyph = " ", hl = "MiniIconsGreen" },
    bash            = { glyph = " ", hl = "MiniIconsGreen" },
    zsh             = { glyph = " ", hl = "MiniIconsGreen" },
    json            = { glyph = " ", hl = "MiniIconsYellow" },
    yaml            = { glyph = "󰋽 ", hl = "MiniIconsPurple" },
    toml            = { glyph = " ", hl = "MiniIconsOrange" },
    html            = { glyph = "󰌝 ", hl = "MiniIconsOrange" },
    css             = { glyph = "󰌜 ", hl = "MiniIconsAzure" },
    lua             = { glyph = " ", hl = "MiniIconsAzure" },
  },
}

function M.setup()
  local ok, mini_icons = pcall(require, "mini.icons")
  if ok then
    mini_icons.setup(M.opts)
    mini_icons.mock_nvim_web_devicons()
  end
end

return M
