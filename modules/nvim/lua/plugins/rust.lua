return {
  {
    "mrcjkb/rustaceanvim",
    opts = function(_, opts)
      local settings = opts.server.default_settings["rust-analyzer"]
      settings.cargo.allFeatures = nil
      settings.cargo.features = {}
      settings.cargo.allTargets = false
      settings.cargo.targetDir = true
      settings.check = vim.tbl_extend("force", settings.check or {}, {
        features = {},
        allTargets = false,
        workspace = false,
      })
      settings.files.exclude = settings.files.exclude or {}
      for _, path in ipairs({ ".cache", "bazel-out", "buck-out", "build", "coverage", "dist", "generated", "target-ra", "vendor" }) do
        if not vim.tbl_contains(settings.files.exclude, path) then
          table.insert(settings.files.exclude, path)
        end
      end
    end,
  },
}
