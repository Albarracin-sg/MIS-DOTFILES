-- Keymaps personalizados cargados con el evento VeryLazy
-- Este archivo complementa los keymaps por defecto de LazyVim:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Asigna la tecla líder (leader key) al espacio
vim.g.mapleader = " "

local keymap = vim.keymap -- Para simplificar el uso de keymap.set

--[[ 
Mover líneas hacia arriba o abajo en modo visual
J -> Mueve línea seleccionada hacia abajo
K -> Mueve línea seleccionada hacia arriba
]]
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

--[[
Eliminar los caracteres ^M generados por saltos de línea de Windows
<leader>cM -> Elimina todos los ^M en la línea actual
]]
keymap.set("n", "<leader>cM", ":s/^M//g<CR>", { noremap = true, silent = true, desc = "Delete blank spaces(^M)" })

--[[
Navegación entre delimitadores pareados como {}, [], ()
<leader>[ -> Mueve al delimitador de cierre o apertura correspondiente
]]
keymap.set("n", "<leader>[", "<S-$>%", { noremap = true, desc = "Move to end {([])}" })

--[[
Búsqueda de archivos incluyendo los ocultos
<leader><leader> -> Abre Telescope incluyendo archivos ocultos
]]
keymap.set("n", "<leader><leader>", function()
  require("telescope.builtin").find_files({ hidden = true })
end, { desc = "Buscar archivos (incluye ocultos)" })

--[[
Seleccionar todo el texto del archivo
Ctrl+A -> Selecciona todo en modo normal, insertar y visual
]]
keymap.set("n", "<C-a>", "ggVG", { noremap = true, silent = true })
keymap.set("i", "<C-a>", "<Esc>ggVG", { noremap = true, silent = true })
keymap.set("v", "<C-a>", "<Esc>ggVG", { noremap = true, silent = true })

--[[ Bookmarks (Plugin: vim-bookmarks) ]]
-- Comandos para gestión de marcadores
keymap.set("n", "<leader>B", "Vim-Bookmarks/Bracey", { noremap = true }) -- (posiblemente erróneo o placeholder)
keymap.set("n", "<leader>Bm", "<Plug>BookmarkToggle", { noremap = true }) -- Marcar/desmarcar línea
keymap.set("n", "<leader>Bi", "<Plug>BookmarkAnnotate", { noremap = true }) -- Agregar anotación al marcador
keymap.set("n", "<leader>Ba", "<Plug>BookmarkShowAll", { noremap = true }) -- Mostrar todos los marcadores
keymap.set("n", "<leader>Bn", "<Plug>BookmarkNext", { noremap = true }) -- Siguiente marcador
keymap.set("n", "<leader>Bp", "<Plug>BookmarkPrev", { noremap = true }) -- Marcador anterior
keymap.set("n", "<leader>Bc", "<Plug>BookmarkClear", { noremap = true }) -- Borrar marcador actual
keymap.set("n", "<leader>Bx", "<Plug>BookmarkClearAll", { noremap = true }) -- Borrar todos los marcadores
keymap.set("n", "<leader>Bk", "<Plug>BookmarkMoveUp", { noremap = true }) -- Mover marcador hacia arriba
keymap.set("n", "<leader>Bj", "<Plug>BookmarkMoveDown", { noremap = true }) -- Mover marcador hacia abajo
keymap.set("n", "<leader>Bg", "<Plug>BookmarkMoveToLine", { noremap = true }) -- Mover marcador a línea actual

--[[ Bracey (Live Server para HTML/CSS/JS) ]]
keymap.set("n", "<leader>Bs", ":Bracey<cr>", { noremap = true }) -- Iniciar servidor en vivo
keymap.set("n", "<leader>Bp", ":BraceyStop<cr>", { noremap = true }) -- Detener servidor

--[[ Markdown Preview (plugin: markdown-preview.nvim) ]]
keymap.set("n", "<leader>m", "MarkdownPreview", { noremap = true }) -- (posiblemente erróneo)
keymap.set("n", "<leader>mp", ":MarkdownPreview<cr>", { noremap = true }) -- Previsualizar markdown
keymap.set("n", "<leader>ms", ":MarkdownPreviewStop<cr>", { noremap = true }) -- Detener vista previa
keymap.set("n", "<leader>mt", ":MarkdownPreviewToggle<cr>", { noremap = true }) -- Alternar vista previa

--[[ Git Messenger ]]
keymap.set("n", "<leader>gm", ":GitMessenger<cr>", { noremap = true }) -- Mostrar mensaje del commit en línea actual

--[[ Refactor.nvim ]]
-- Atajos para diferentes operaciones de refactorización
keymap.set("x", "<leader>r", "Refactor") -- menú general
keymap.set("n", "<leader>r", "Refactor")
keymap.set("x", "<leader>re", ":Refactor extract ") -- extraer código seleccionado a función
keymap.set("x", "<leader>rf", ":Refactor extract_to_file ") -- extraer a nuevo archivo
keymap.set("x", "<leader>rv", ":Refactor extract_var ") -- extraer a variable
keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var") -- inline variable
keymap.set("n", "<leader>rI", ":Refactor inline_func") -- inline función
keymap.set("n", "<leader>rb", ":Refactor extract_block") -- extraer bloque
keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file") -- extraer bloque a archivo

--[[ ToggleTerm (terminal embebida) ]]
keymap.set("n", "<leader>T", "ToggleTerm", { noremap = true, desc = "ToggleTerm" }) -- Comando general
keymap.set("n", "<leader>Tt", ":ToggleTerm<cr>", { noremap = true, desc = "Toggle Terminal (default)" })
keymap.set("n", "<leader>Tr", ":ToggleTerm direction=tab<cr>", { noremap = true, desc = "Toggle Terminal (tab)" })
keymap.set("n", "<leader>Tf", ":ToggleTerm direction=float<cr>", { noremap = true, desc = "Toggle Terminal (float)" })
keymap.set(
  "n",
  "<leader>Th",
  ":ToggleTerm direction=horizontal<cr>",
  { noremap = true, desc = "Toggle Terminal (horizontal)" }
)
keymap.set(
  "n",
  "<leader>Tv",
  ":ToggleTerm direction=vertical<cr>",
  { noremap = true, desc = "Toggle Terminal (vertical)" }
)

--[[ Ejecutar archivos con TermExec (Terminal embebida) ]]
keymap.set("n", "<leader>j", "Execute Files", { noremap = true }) -- Etiqueta general
keymap.set(
  "n",
  "<leader>jp",
  ":w | :TermExec cmd='python3 \"%\"' size=50 direction=tab go_back=0<CR>",
  { noremap = true, desc = "Run Python File" }
) -- Ejecutar Python
keymap.set(
  "n",
  "<leader>jj",
  ":w | :TermExec cmd='java \"%\"' size=50 direction=tab go_back=0<CR>",
  { noremap = true, desc = "Run Java File" }
) -- Ejecutar Java
keymap.set(
  "n",
  "<leader>jr",
  ":w | :TermExec cmd='cr \"%\"' size=50 direction=tab go_back=0<CR>",
  { noremap = true, desc = "Compile and Run C++ File" }
) -- Correr C++
keymap.set(
  "n",
  "<leader>jd",
  ":w | :TermExec cmd='cr \"%\" -d' size=50 direction=tab go_back=0<CR>",
  { noremap = true, desc = "Compile and Run C++ File with Debug" }
) -- Correr C++ con debug
