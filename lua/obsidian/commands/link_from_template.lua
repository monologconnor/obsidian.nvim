local util = require "obsidian.util"
local log = require "obsidian.log"

---@param client obsidian.Client
return function(client, data)
  if not client:templates_dir() then
    log.err "Templates folder is not defined or does not exist"
    return
  end

  local picker = client:picker()
  if not picker then
    log.err "No picker configured"
    return
  end

  picker:find_templates {
    callback = function(name)
      local template_name = vim.fn.fnamemodify(name, ':t:r')
      local sub_dir = vim.fs.joinpath(client.dir.filename, template_name)

      ---@type obsidian.Note
      local note
      if data.args and data.args:len() > 0 then
        note = client:create_note { title = data.args, no_write = true }
      else
        local title = util.input("Enter title or path (optional): ", { completion = "file" })
        if not title then
          log.warn "Aborted"
          return
        elseif title == "" then
          title = nil
        end
        note = client:create_note { title = title, no_write = true, dir=sub_dir}
        util.insert_text(client:format_link(note, { label = title }))
      end

      -- Open the note in a new buffer.
      client:open_note(note, { sync = true })

      client:write_note_to_buffer(note, { template = name })
    end,
  }
end
