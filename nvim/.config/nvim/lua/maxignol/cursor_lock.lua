local M = {}

M.state = {
  locked = false,
  target_row = nil,
  busy = false,
  augroup = nil, -- store the current augroup id
}

local function clamp(n, lo, hi)
  if n < lo then return lo end
  if n > hi then return hi end
  return n
end

local function adjust_view_to_target_row()
  if not M.state.locked or M.state.busy then return end
  M.state.busy = true

  local height = vim.api.nvim_win_get_height(0)
  M.state.target_row = clamp(M.state.target_row or 1, 1, height)

  local cur_row = vim.fn.winline()
  local delta = cur_row - M.state.target_row
  if delta ~= 0 then
    local view = vim.fn.winsaveview()
    view.topline = math.max(1, (view.topline or 1) + delta)
    vim.schedule(function()
      -- protect against window going away
      if vim.api.nvim_get_current_win() ~= nil then
        pcall(vim.fn.winrestview, view)
      end
      M.state.busy = false
    end)
  else
    M.state.busy = false
  end
end

function M.lock()
  if M.state.locked then return end
  M.state.target_row = vim.fn.winline()
  M.state.locked = true

  -- Create a fresh augroup each time we lock
  M.state.augroup = vim.api.nvim_create_augroup("CursorLock", { clear = true })

  vim.api.nvim_create_autocmd(
    { "CursorMoved", "CursorMovedI", "WinScrolled", "VimResized", "WinEnter" },
    {
      group = M.state.augroup,
      callback = function()
        local height = vim.api.nvim_win_get_height(0)
        M.state.target_row = clamp(M.state.target_row, 1, height)
        adjust_view_to_target_row()
      end,
      desc = "Keep cursor at fixed screen row",
    }
  )

  vim.notify("Cursor lock: ON (row " .. M.state.target_row .. ")", vim.log.levels.INFO)
end

function M.unlock()
  if not M.state.locked then return end
  M.state.locked = false
  M.state.target_row = nil

  -- Delete the current augroup by ID (if it still exists)
  if M.state.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, M.state.augroup)
    M.state.augroup = nil
  end

  vim.notify("Cursor lock: OFF", vim.log.levels.INFO)
end

function M.toggle()
  if M.state.locked then
    M.unlock()
  else
    M.lock()
  end
end

return M
