require "nvchad.autocmds"

vim.cmd [[
autocmd VimEnter * cd $code
]]

vim.api.nvim_create_user_command("Compile", function()
    local filetype = vim.fn.expand("%:e")

    if filetype == "cpp" then compile_cpp()
    elseif filetype == "py" then compile_python()
    else end

end, {nargs=0})

function compile_cpp()
    vim.cmd("cd %:h")
    vim.cmd("compiler gcc")
    vim.bo.makeprg = "g++ -std=c++26 -Wall -Wextra -Wpedantic -Werror -ggdb % -o %<"
    vim.cmd("make")
    vim.cmd("copen")
end

function compile_python()
    vim.cmd("cd %:h")
    vim.cmd("compiler pyright")
    vim.bo.makeprg = "python -m %<"
    vim.cmd("make")
    vim.cmd("copen")
end

vim.api.nvim_create_user_command("Run", function()
    if vim.fn.expand("%:e") ~= "cpp" then
      return
    end

    vim.cmd("cd %:h")
    vim.cmd("split | term ./%<")
end, {nargs=0})

-- Quick-review files: zf every "> [!answer]" paragraph on open (no spoilers); za reveals it.
vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*-quick.md",
    callback = function()
        vim.opt_local.foldmethod = "manual"
        vim.opt_local.foldenable = true
        vim.opt_local.foldtext = "'  ▸ answer'"
        vim.cmd("silent! normal! zE")
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local i = 1
        while i <= #lines do
            if lines[i]:match("^> %[!answer%]") then
                local j = i
                while j < #lines and lines[j + 1]:match("^>") do j = j + 1 end
                vim.cmd(i .. "," .. j .. "fold")
                i = j
            end
            i = i + 1
        end
    end,
})
