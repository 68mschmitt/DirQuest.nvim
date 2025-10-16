local M = {}

M.directory_templates = {
  small = {
    art = {
      "╔═══════╗",
      "║ name  ║",
      "║       ║",
      "╚═══════╝"
    },
    entrance = { x = 4, y = 3 }
  },
  
  medium = {
    art = {
      "╔═══════════╗",
      "║   name    ║",
      "║           ║",
      "║           ║",
      "╚═══════════╝"
    },
    entrance = { x = 6, y = 4 }
  },
  
  large = {
    art = {
      "╔═══════════════╗",
      "║     name      ║",
      "║               ║",
      "║               ║",
      "║               ║",
      "╚═══════════════╝"
    },
    entrance = { x = 8, y = 5 }
  },
  
  hidden = {
    art = {
      "┌─────────┐",
      "│  name   │",
      "│ (hide)  │",
      "└─────────┘"
    },
    entrance = { x = 5, y = 3 }
  }
}

M.file_sprites = {
  lua = "📜",
  txt = "📄",
  md = "📝",
  js = "📘",
  py = "🐍",
  rb = "💎",
  go = "🐹",
  rs = "🦀",
  java = "☕",
  cpp = "⚙️",
  c = "⚙️",
  png = "🖼️",
  jpg = "🖼️",
  gif = "🖼️",
  json = "📋",
  yaml = "📋",
  yml = "📋",
  xml = "📋",
  sh = "📜",
  default = "📦"
}

M.interaction_radius = 1

function M.get_directory_art(name, size, is_hidden)
  local template
  
  if is_hidden then
    template = M.directory_templates.hidden
  elseif size < 5 then
    template = M.directory_templates.small
  elseif size < 15 then
    template = M.directory_templates.medium
  else
    template = M.directory_templates.large
  end
  
  local art = {}
  for i, line in ipairs(template.art) do
    table.insert(art, line)
  end
  
  local name_line = 2
  art = M.embed_text(art, name, name_line)
  
  return art, template.entrance
end

function M.embed_text(art, text, line_num)
  if line_num < 1 or line_num > #art then
    return art
  end
  
  local line = art[line_num]
  local width = #line
  local text_width = #text
  
  if text_width > width - 4 then
    text = text:sub(1, width - 4)
    text_width = #text
  end
  
  local start_pos = math.floor((width - text_width) / 2)
  
  local new_line = line:sub(1, start_pos) .. text .. line:sub(start_pos + text_width + 1)
  art[line_num] = new_line
  
  return art
end

function M.get_file_sprite(filename)
  local ext = filename:match("%.([^%.]+)$")
  
  if ext and M.file_sprites[ext:lower()] then
    return M.file_sprites[ext:lower()]
  end
  
  return M.file_sprites.default
end

return M
