-- 在 BufEnter 触发的时候，也就是进入一个 buffer 的时候，执行 callback
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(args)
        local buf = args.buf -- 获取 buffer id

        local function on_exit()
            -- global_var 是我们要检测的全局变量
            if global_var == nil then
                vim.schedule(on_exit)
                return
            end

            out = global_var
            if out.code == 0 then
                local indent = out.stdout -- python 脚本输出结果因为是打印出来的，所以可以通过 stdout 获取
                if indent ~= "unknown" and indent ~= "tabs" and indent ~= "" then
                    -- 使用之前获取的 buffer id 定位到目标 buffer，设置其 tabstop 属性
                    vim.api.nvim_set_option_value("tabstop", indent + 0, { scope = "local", buf = buf })
                end
            end
        end
        vim.schedule(on_exit)

        vim.system({
            "python3",
            "detect-indent.py", -- 为什么这里不写完整路径，因为下面设置了 cwd
            vim.fn.resolve(vim.fn.expand("%:p", true)), -- 获取当前 buffer 文件名
        }, {
            cwd = vim.fn.stdpath "config",
            text = true,
        }, function(out)
            global_var = out
        end)
    end,
})

