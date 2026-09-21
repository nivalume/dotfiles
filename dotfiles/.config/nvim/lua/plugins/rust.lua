-- Keep rust-analyzer responsive in large Cargo workspaces. Project-specific
-- feature sets belong in a local Neovim config rather than this global default.
return {
  {
    "mrcjkb/rustaceanvim",
    opts = function(_, opts)
      local settings = opts.server.default_settings["rust-analyzer"]

      settings.cargo.allFeatures = false
      settings.cargo.allTargets = false
      -- Keep editor-driven checks separate from terminal/CI Cargo invocations.
      settings.cargo.targetDir = true

      settings.check = settings.check or {}
      settings.check.allFeatures = false
      settings.check.allTargets = false
      settings.check.workspace = false

      settings.files.exclude = settings.files.exclude or {}
      local excluded = {
        ".cache",
        "bazel-out",
        "buck-out",
        "build",
        "coverage",
        "dist",
        "generated",
        "target-ra",
        "vendor",
      }
      for _, path in ipairs(excluded) do
        if not vim.tbl_contains(settings.files.exclude, path) then
          table.insert(settings.files.exclude, path)
        end
      end
    end,
  },
}
