local M = {}

M.directory_templates = {
  small = {
    "  ___  ",
    " |   | ",
    " |   | ",
    " |___| ",
  },
  
  medium = {
    "   _____   ",
    "  |     |  ",
    "  |     |  ",
    "  |     |  ",
    "  |_____|  ",
  },
  
  large = {
    "    _______    ",
    "   |       |   ",
    "   |       |   ",
    "   |       |   ",
    "   |       |   ",
    "   |_______|   ",
  }
}

M.file_sprites = {
  lua = { "[L]" },
  txt = { "[T]" },
  md = { "[M]" },
  js = { "[J]" },
  py = { "[P]" },
  default = { "[F]" }
}

function M.get_directory_art(name, size)
  local template
  
  if size < 5 then
    template = M.directory_templates.small
  elseif size < 15 then
    template = M.directory_templates.medium
  else
    template = M.directory_templates.large
  end
  
  local art = {}
  for i, line in ipairs(template) do
    table.insert(art, line)
  end
  
  local name_line = math.floor(#art / 2) + 1
  art = M.embed_text(art, name, name_line)
  
  return art
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
  
  if ext and M.file_sprites[ext] then
    return M.file_sprites[ext]
  end
  
  return M.file_sprites.default
end

function M.generate_ground(width)
  local ground = ""
  for i = 1, width do
    ground = ground .. "="
  end
  return ground
end

return M
