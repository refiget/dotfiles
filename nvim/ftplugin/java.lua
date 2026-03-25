local ok_jdtls, jdtls = pcall(require, "jdtls")
if not ok_jdtls then
  return
end

local root_dir = vim.fs.dirname(vim.fs.find({ ".git", "proj.iml" }, { upward = true })[1])
if not root_dir or root_dir == "" then
  root_dir = vim.fn.getcwd()
end

jdtls.start_or_attach({
  root_dir = root_dir,
  settings = {
    java = {
      project = {
        sourcePaths = { "src", "tests" },
        outputPath = "out",
        referencedLibraries = {
          "/Users/mac/Desktop/cs61b/library-sp24/*.jar",
        },
      },
    },
  },
})
