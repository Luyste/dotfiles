local git = {}

-- Ask git for the repo, branch and worktree (runs in the background)
local function refresh_git()
    vim.system({
        "git",
        "rev-parse",
        "--path-format=absolute",
        "--show-toplevel",
        "--git-dir",
        "--git-common-dir",
        "--abbrev-ref",
        "HEAD",
    }, { text = true, cwd = vim.fn.getcwd() }, function(res)
        vim.schedule(function()
            if res.code ~= 0 then
                git = {}
            else
                local top, gitdir, common, branch = unpack(vim.split(vim.trim(res.stdout), "\n"))
                local repo = vim.fn.fnamemodify(common, ":t") == ".git" and vim.fn.fnamemodify(common, ":h:t")
                    or (vim.fn.fnamemodify(common, ":t"):gsub("%.git$", ""))
                git = {
                    repo = repo,
                    branch = branch,
                    -- a linked worktree has its own git dir, separate from the shared one
                    worktree = gitdir ~= common and vim.fn.fnamemodify(top, ":t") or nil,
                }
            end
            vim.cmd("redrawstatus!")
        end)
    end)
end

-- Diagnostic colors on the statusline background, and the "where am I" badges
local badges = {
    FILE = "Directory",
    TREE = "String",
    AGENT = "DiagnosticWarn",
    YARD = "Keyword",
    TERM = "Keyword",
}

local function set_highlights()
    local bg = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false }).bg
    for group, source in pairs({
        StlError = "DiagnosticError",
        StlWarn = "DiagnosticWarn",
        StlInfo = "DiagnosticInfo",
        StlHint = "DiagnosticHint",
    }) do
        local fg = vim.api.nvim_get_hl(0, { name = source, link = false }).fg
        vim.api.nvim_set_hl(0, group, { fg = fg, bg = bg })
    end
    -- Badge: dark text (the statusline background) on a light theme color
    for kind, source in pairs(badges) do
        local color = vim.api.nvim_get_hl(0, { name = source, link = false }).fg
        vim.api.nvim_set_hl(0, "StlBadge" .. kind, { fg = bg, bg = color, bold = true })
    end
end

local sev = vim.diagnostic.severity
local diag_parts = {
    { sev.ERROR, "StlError", "✘" },
    { sev.WARN, "StlWarn", "▲" },
    { sev.INFO, "StlInfo", "●" },
    { sev.HINT, "StlHint", "»" },
}

-- The linked agent from switchyard, or "" if there's none (or switchyard isn't available)
local function agent_status()
    local ok, agent = pcall(function()
        return require("switchyard").status()
    end)
    if ok and type(agent) == "string" then
        return agent
    end
    return ""
end

-- What has focus right now: FILE, TREE, AGENT (switchyard viewer), YARD, TERM
local function kind_of(buf)
    local ft = vim.bo[buf].filetype
    if ft == "NvimTree" then
        return "TREE"
    elseif ft == "switchyard" then
        return "YARD"
    elseif vim.api.nvim_buf_get_name(buf):match("^switchyard://") then
        return "AGENT"
    elseif vim.bo[buf].buftype == "terminal" then
        return "TERM"
    end
    return "FILE"
end

-- One statusline for the whole editor (laststatus=3), about the focused window
function _G.Statusline()
    local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
    local kind = kind_of(buf)
    local s = ("%%#StlBadge%s# %s %%*"):format(kind, kind)

    -- Where: repo · branch
    if git.repo then
        s = s .. " " .. git.repo .. " · \u{e725} " .. git.branch
    end

    -- What: the file, or the agent the viewer shows
    local name = vim.api.nvim_buf_get_name(buf)
    if kind == "FILE" then
        name = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":~:.")
        s = s .. "   " .. name:gsub("%%", "%%%%")
        if vim.bo[buf].modified then
            s = s .. " ●"
        end
    elseif kind == "AGENT" then
        s = s .. "   viewing " .. name:gsub("^switchyard://", ""):gsub("%%", "%%%%")
    end

    s = s .. "%=" -- everything after this is right-aligned

    -- A prompt draft waiting in the (hidden) prompt builder
    local ok_draft, draft = pcall(function()
        return require("switchyard").draft_status()
    end)
    if ok_draft and draft ~= "" then
        s = s .. "%#StlBadgeYARD# " .. draft .. " %* "
    end

    -- Linked agent (safe: a missing or failing switchyard just shows nothing)
    local agent = agent_status()
    if agent ~= "" then
        s = s .. "\u{f0c1} " .. agent:gsub("%%", "%%%%") .. "  "
    end

    if kind == "FILE" then
        local counts = vim.diagnostic.count(buf)
        for _, d in ipairs(diag_parts) do
            local n = counts[d[1]]
            if n and n > 0 then
                s = s .. ("%%#%s#%s %d "):format(d[2], d[3], n)
            end
        end
        s = s .. "%* %l:%c "
    end
    return s
end

vim.o.laststatus = 3 -- one statusline for the whole editor
vim.o.statusline = "%!v:lua.Statusline()"

set_highlights()
refresh_git()

vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })
vim.api.nvim_create_autocmd({ "DirChanged", "FocusGained", "BufWritePost" }, {
    callback = refresh_git,
})
vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function()
        vim.cmd("redrawstatus!")
    end,
})
