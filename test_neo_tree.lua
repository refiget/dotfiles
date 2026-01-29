-- Test script to check neo-tree availability
local ok, neo_tree = pcall(require, "neo-tree")
if ok then
  print("Neo-tree is available!")
  print("Version:", neo_tree.version or "unknown")
else
  print("Neo-tree is not available:", neo_tree)
end

-- Test command module
local ok_cmd, neo_tree_cmd = pcall(require, "neo-tree.command")
if ok_cmd then
  print("Neo-tree command module is available!")
else
  print("Neo-tree command module is not available:", neo_tree_cmd)
end
